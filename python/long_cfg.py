import csv
from datetime import datetime
import logging
from multiprocessing import cpu_count
import re
import json
import concurrent.futures
import traceback
from typing import List, Dict, Any
from llm import get_llm_answers
import os

# 日志设置
def setup_logging(log_dir=None, index=None):
    """为每个样本设置独立的日志记录器"""
    os.makedirs(log_dir, exist_ok=True)
    log_file = os.path.join(log_dir, f"{index}.log") if index is not None else os.path.join(log_dir, "global.log")
    
    logger = logging.getLogger(f"logger_{index}")
    logger.setLevel(logging.INFO)
    
    if not logger.handlers:
        file_handler = logging.FileHandler(log_file, mode='w')
        file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
        logger.addHandler(file_handler)
    
    return logger

def init_conversations(logger) -> List[Dict[str, str]]:
    """初始化对话,给LLM一个系统提示,告诉它整体流程."""
    try:
        conversations = []
        
        system_prompt = """You are a Code CFG Analysis Assistant. 
We have a multi-step approach to build a Control Flow Graph (CFG):
- Step0: Split large code into top-level declarations. Return a JSON array, each item containing the code lines for one top-level block.
- Step1: Multi-level Code Segmentation (for each block).
- Step2: Fine-grained Semantic Labeling.
- Step3: Outline the control flow.
- Step4: Convert control flow to JSON CFG.
- Step5: Check CFG correctness, fix if needed (in JSON).
- Step6: Merge local CFGs into a global CFG.

We will explicitly call each step. Please follow the instructions at each step carefully."""
        
        conversations.append({"role": "system", "content": system_prompt})
        logger.info("Successfully initialized conversations")
        return conversations
    except Exception as e:
        logger.error(f"Failed to initialize conversations: {str(e)}")
        raise

def extract_code_from_markdown_block(markdown_block: str, logger) -> str:
    """从Markdown代码块中提取代码."""
    try:
        match = re.search(
            r'```(?:arkts|javascript|js|ts|json|typescript|cangjie|python|java|cpp|c|go|rust|swift|kotlin|scala|ruby|php|html|css|sql)\n(.*)\n```',
            markdown_block, re.DOTALL
        )
        if match is not None:
            logger.debug("Successfully extracted code from markdown block")
            return match.group(1)
        
        logger.warning("No code block found, returning original text")
        return markdown_block
    except Exception as e:
        logger.error(f"Error extracting code block: {str(e)}")
        raise

def step_0_split_top_declarations(whole_code: str, logger) -> List[Dict[str, Any]]:
    """
    Step 0: 对大代码做解析,将顶层声明按行号拆分.
    
    在此处明确要求：如果类/函数中出现嵌套函数/方法，也要拆分为独立块。
    """
    try:
        logger.info("Starting Step 0: Splitting code into top-level declarations")
        
        code_lines = whole_code.split('\n')
        code_array = [{"line": i, "content": line} for i, line in enumerate(code_lines)]
        
        # 修改提示，强调“嵌套函数/方法”也单独作为块，不与外层块有顺序关系
        prompt = """
You are a senior code analysis assistant. We have a potentially large python code snippet.
We want to split it into top-level declarations or blocks, returning a JSON array.

### Requirements:
1) Each element in the JSON array should be an object with:
   - "decl_name": an identifier or best guess of the block's name
   - "start_line" and "end_line": line numbers in the original snippet
   - No code content in this step.

2) Every line from the code must appear in exactly one block (covering the entire file).

3) If there's top-level statements not inside a class/function, group them as a block too 
   (like a 'GlobalBlock').

4) **Important**: 
   - If inside a class or function we detect a nested function/method, 
     treat that nested function/method as a separate top-level block.
   - This means in later steps, there should be no direct 'sequential' edges between the parent block 
     and the nested block.

5) The final response should be strictly valid JSON, e.g.:
{
  "blocks": [
    {
      "decl_name": "GlobalBlock",
      "start_line": 1,
      "end_line": 30
    },
    ...
  ]
}

6) Do not output any extra text or code besides the JSON.

Python code (with line numbers):
""" + json.dumps(code_array, indent=2)

        response = get_llm_answers(prompt, model_name="gpt-4o", require_json=True)
        chunks = json.loads(response)["blocks"]
        
        # 补充上各块的 code 内容
        for chunk in chunks:
            start_line = chunk["start_line"]
            end_line = chunk["end_line"]
            chunk["code"] = "\n".join(code_lines[start_line:end_line+1]) + "\n"
            
        logger.info(f"Successfully split code into {len(chunks)} top-level declarations")
        return chunks
    except Exception as e:
        logger.error(f"Error in step_0_split_top_declarations: {str(e)}")
        raise

def step_1_basic_block_segmentation(code: str, logger) -> List[Dict[str, Any]]:
    """
    Step 1: 对每个代码块做解析,将代码块按行号拆分.
    """
    try:
        logger.info("Starting Step 1: Basic block segmentation")
        
        code_lines = code.split('\n')
        code_array = [{"line": i, "content": line} for i, line in enumerate(code_lines)]

        prompt = """
Please analyze the following code and identify its basic blocks. 
Return the start and end line numbers for each basic block in JSON format.

Input code:
""" + json.dumps(code_array, indent=2) + """

Expected output format:
{
    "basic_blocks": [
        {
            "start_line": x,
            "end_line": y
        },
        ...
    ]
}

A basic block is a sequence of consecutive statements where:
- Flow of control enters at the beginning
- Flow of control leaves at the end
- No branching occurs except at the end
- No branching targets exist except at the beginning

Do not include any extra explanation, just the JSON.
"""
        response = get_llm_answers(prompt, model_name="deepseek-chat", require_json=True)
        basic_blocks = json.loads(response)["basic_blocks"]
        
        # 将分好的块加上实际code
        for block in basic_blocks:
            start_line = block["start_line"]
            end_line = block["end_line"]
            block["code"] = "\n".join(code_lines[start_line:end_line+1]) + "\n"
            
        logger.info(f"Successfully segmented code into {len(basic_blocks)} basic blocks")
        return basic_blocks
    except Exception as e:
        logger.error(f"Error in step_1_basic_block_segmentation: {str(e)}")
        raise

def step_2_determine_execution_order(basic_blocks: List[Dict[str, Any]], code: str, logger) -> List[Dict[str, Any]]:
    """
    Step 2: 根据基本块确定它们之间的控制流关系.
    
    在此处再度强调：如果块代表的是一个函数/方法与外层互为嵌套，则彼此不应当有顺序边。
    同一类下多个方法也不连边，除非显式调用。
    """
    try:
        logger.info("Starting Step 2: Determining execution order")
        
        blocks_content = [
            {"block_id": idx, "code": block["code"]} 
            for idx, block in enumerate(basic_blocks, 1)
        ]
        
        # 修改提示，强调嵌套函数/方法为独立块，不与外层连顺序边
        prompt = """
You are a senior code analysis assistant. Based on the provided basic blocks, determine the control flow between them.

Each basic block is identified by a unique "block_id" and has some code.

### Requirements:
1) If a block is recognized as a separate (nested) function/method, do NOT add a control flow edge 
   from the outer function/class to this block (nor vice versa).
2) Similarly, if multiple methods appear within the same class, do NOT have a direct execution flow 
   unless there's an explicit call or branching in the code.
3) For normal sequential blocks within the same function, link them accordingly in the typical order.

Return the result in strictly valid JSON:
{
    "control_flow": [
        {
            "block_id": 1,
            "successors": [2, 3]
        },
        ...
    ]
}

Do not include any extra text or explanations.

Original code:
""" + code + """

Basic Blocks:
""" + json.dumps(blocks_content, indent=2) + """
"""
        response = get_llm_answers(prompt, model_name="deepseek-chat", require_json=True)
        control_flow = json.loads(response)["control_flow"]
        logger.info(f"Successfully determined execution order for {len(control_flow)} blocks")
        return control_flow
    except Exception as e:
        logger.error(f"Error in step_2_determine_execution_order: {str(e)}")
        raise

def step_3_generate_cfg(basic_blocks: List[Dict[str, Any]], control_flow: List[Dict[str, Any]], decl_name: str, logger) -> Dict[str, Any]:
    """
    Step 3: 根据基本块和控制流关系生成CFG.
    """
    try:
        logger.info("Starting Step 3: Generating CFG")
        
        # 生成节点
        nodes = [
            {"id": f"{decl_name}_{idx}", "code": block["code"]}
            for idx, block in enumerate(basic_blocks, 1)
        ]
        
        # 生成边
        edges = []
        for flow in control_flow:
            from_id = f"{decl_name}_{flow['block_id']}"
            for to_id in flow["successors"]:
                edges.append({
                    "from": from_id,
                    "to": f"{decl_name}_{to_id}"
                })
        
        cfg = {"nodes": nodes, "edges": edges}
        logger.info(f"Successfully generated CFG with {len(nodes)} nodes and {len(edges)} edges")
        return cfg
    except Exception as e:
        logger.error(f"Error in step_3_generate_cfg: {str(e)}")
        raise

def step_4_merge_cfgs(top_level_cfgs: List[Dict[str, Any]], logger) -> Dict[str, Any]:
    """
    Step 4: 合并所有顶层声明块的CFG.
    """
    try:
        logger.info("Starting Step 4: Merging CFGs")
        
        global_cfg = {
            "nodes": [],
            "edges": []
        }
        
        for i, cfg in enumerate(top_level_cfgs):
            # 为每个节点添加chunk编号前缀
            for node in cfg["nodes"]:
                node["id"] = f"chunk_{i}_{node['id']}"
            
            for edge in cfg["edges"]:
                edge["from"] = f"chunk_{i}_{edge['from']}"
                edge["to"] = f"chunk_{i}_{edge['to']}"
                
            global_cfg["nodes"].extend(cfg["nodes"])
            global_cfg["edges"].extend(cfg["edges"])
            
        logger.info(f"Successfully merged {len(top_level_cfgs)} CFGs")
        return global_cfg
    except Exception as e:
        logger.error(f"Error in step_4_merge_cfgs: {str(e)}")
        raise

def get_code_from_cfg(cfg: Dict[str, Any], logger) -> str:
    """
    从CFG生成代码.
    """
    try:
        logger.info("Starting code generation from CFG")
        
        prompt =  """
请根据给出的程序控制流图生成python编程语言代码。
CFG如下:
""" + json.dumps(cfg, indent=4) + """
输出请以```python开头，```结尾。
"""

        conversations = [{"role": "user", "content": prompt}]
        res_step1 = get_llm_answers(conversations, model_name="gpt-4o")
        code = extract_code_from_markdown_block(res_step1, logger)
        
        if not code:
            logger.warning("Generated empty code")
            return ""
            
        logger.info("Successfully generated code from CFG")
        return code
    except Exception as e:
        logger.error(f"Error in get_code_from_cfg: {str(e)}")
        return ""

def compare_code_similarity_static(original_code: str, code: str, logger) -> Dict[str, float]:
    """
    通过静态指标比较两段代码的相似度.
    """
    try:
        logger.info("Starting static code similarity analysis")
        
        def remove_comments(code_str: str) -> str:
            if not isinstance(code_str, str):
                logger.error(f"Invalid code type: {type(code_str)}")
                return ""
            # 移除多行注释
            while True:
                start = code_str.find("/*")
                if start == -1:
                    break
                end = code_str.find("*/", start)
                if end == -1:
                    break
                code_str = code_str[:start] + code_str[end+2:]
            
            # 移除单行注释
            lines = []
            for line in code_str.split('\n'):
                comment_idx = line.find("//")
                if comment_idx != -1:
                    line = line[:comment_idx]
                if line.strip():
                    lines.append(line)
            return '\n'.join(lines)
        
        original_code = remove_comments(original_code)
        code = remove_comments(code)
        
        # 计算各种相似度指标
        len_ratio = (
            min(len(code), len(original_code)) / max(len(code), len(original_code))
            if max(len(code), len(original_code))>0 else 1
        )
        
        def get_tokens(code_str: str) -> set:
            if not isinstance(code_str, str):
                logger.error(f"Invalid code type: {type(code_str)}")
                return set()
            return set(code_str.replace('{',' { ').replace('}',' } ')
                             .replace('(',' ( ').replace(')',' ) ')
                             .replace(';',' ; ').split())
        
        orig_tokens = get_tokens(original_code)
        gen_tokens = get_tokens(code)
        
        intersection = len(orig_tokens.intersection(gen_tokens))
        union = len(orig_tokens.union(gen_tokens))
        token_similarity = intersection / union if union else 0
        
        def get_indent_pattern(code_str: str) -> List[int]:
            return [
                len(line) - len(line.lstrip()) 
                for line in code_str.split('\n') 
                if line.strip()
            ]
            
        orig_pattern = get_indent_pattern(original_code)
        gen_pattern = get_indent_pattern(code)
        
        def levenshtein(s1: List[int], s2: List[int]) -> int:
            if len(s1) < len(s2):
                return levenshtein(s2, s1)
            if len(s2) == 0:
                return len(s1)
            previous_row = range(len(s2) + 1)
            for i, c1 in enumerate(s1):
                current_row = [i + 1]
                for j, c2 in enumerate(s2):
                    insertions = previous_row[j + 1] + 1
                    deletions = current_row[j] + 1
                    substitutions = previous_row[j] + (c1 != c2)
                    current_row.append(min(insertions, deletions, substitutions))
                previous_row = current_row
            return previous_row[-1]
        
        structure_diff = levenshtein(orig_pattern, gen_pattern)
        max_diff = max(len(orig_pattern), len(gen_pattern))
        structure_similarity = 1 - (structure_diff / max_diff if max_diff else 0)
        
        def count_functions(code_str: str) -> int:
            return len(re.findall(r'\bfn\s+\w+\s*\(', code_str))
        
        orig_funcs = count_functions(original_code)
        gen_funcs = count_functions(code)
        func_ratio = (
            min(orig_funcs, gen_funcs) / max(orig_funcs, gen_funcs)
            if max(orig_funcs, gen_funcs) > 0 else 1
        )
        
        def calc_cyclomatic_complexity(code_str: str) -> int:
            return len(re.findall(r'\b(if|while|for|match)\b', code_str)) + 1
        
        orig_complexity = calc_cyclomatic_complexity(original_code)
        gen_complexity = calc_cyclomatic_complexity(code)
        complexity_ratio = (
            min(orig_complexity, gen_complexity) / max(orig_complexity, gen_complexity)
            if max(orig_complexity, gen_complexity) > 0 else 1
        )
        
        def extract_variables(code_str: str) -> set:
            return set(re.findall(r'\blet\s+(\w+)\b', code_str))
            
        orig_vars = extract_variables(original_code)
        gen_vars = extract_variables(code)
        var_intersection = len(orig_vars.intersection(gen_vars))
        var_union = len(orig_vars.union(gen_vars))
        var_similarity = var_intersection / var_union if var_union > 0 else 1
        
        final_score = (
            len_ratio * 0.15 + 
            token_similarity * 0.3 + 
            structure_similarity * 0.2 +
            func_ratio * 0.15 +
            complexity_ratio * 0.1 +
            var_similarity * 0.1
        ) * 100
        
        result = {
            'final_score': round(final_score, 2),
            'length_similarity': round(len_ratio * 100, 2),
            'token_similarity': round(token_similarity * 100, 2), 
            'structure_similarity': round(structure_similarity * 100, 2),
            'function_similarity': round(func_ratio * 100, 2),
            'complexity_similarity': round(complexity_ratio * 100, 2),
            'variable_similarity': round(var_similarity * 100, 2)
        }
        
        logger.info("Successfully completed static similarity analysis")
        logger.info(f"Static similarity result: {result}")
        return result
    except Exception as e:
        logger.error(f"Error in compare_code_similarity_static: {str(e)}")
        raise

def handle_output(cfg_res, logger):
    """处理CFG结果中出现的问题"""
    try:
        fix_prompt = (
            f"Please fix the following JSON file: {cfg_res} so that it can be parsed by json.loads. "
            "Before output, you should check whether the result can be parsed by json.loads(). "
            "Please output the fixed JSON. If the input is incomplete, please complete it by adding "
            "empty strings (\"\") or closing braces (}}). Don't output anything else except the fixed JSON, "
            "don't output the string like ```json."
        )
        res = get_llm_answers(fix_prompt, model_name="gpt-4o-2024-11-20", require_json=True)
        res = extract_code_from_markdown_block(res, logger)
        logger.info(f"Fixed JSON:\n{res}")
        json_obj = json.loads(res)
        return json_obj
    except Exception as e:
        error_msg = f"处理CFG结果失败: {str(e)}\n{traceback.format_exc()}"
        logger.error(error_msg)
        print(error_msg)
        return {"nodes": [], "edges": []}

def process_chunk(code: str, decl_name: str, index: int, logger) -> Dict[str, Any]:
    """处理单个代码块."""
    try:
        basic_block = step_1_basic_block_segmentation(code, logger)
        control_flow = step_2_determine_execution_order(basic_block, code, logger)
        cfg = step_3_generate_cfg(basic_block, control_flow, decl_name, logger)
        logger.info(f"Successfully processed chunk {index}")
        return cfg
    except Exception as e:
        logger.error(f"Error processing chunk {index}: {str(e)}")
        return {"nodes": [], "edges": []}

if __name__ == "__main__":
    model_name = "deepseek-chat"
    task_type = "llm_cfg"
    os.makedirs(f"{task_type}/{model_name}", exist_ok=True)
    
    # 初始化全局日志
    logger = setup_logging(log_dir=f"{task_type}/{model_name}/logs", index=None)
    
    # 初始化全局对话
    conversations = init_conversations(logger)

    datas = []
    os.makedirs("cfg", exist_ok=True)
    for i, file in enumerate(os.listdir("data")):
        if file.endswith(".py"):
            with open(os.path.join("data", file), "r", encoding="utf-8") as f:
                datas.append({"text": f.read()})

            json_file = f"cfg_output/{file.replace('.py', '.json')}"
            if os.path.exists(json_file):
                with open(json_file, "r") as f:
                    cfg_data = json.load(f)
                    output_file = f"cfg/{i}.json"
                    os.makedirs(os.path.dirname(output_file), exist_ok=True)
                    with open(output_file, "w") as f:
                        json.dump(cfg_data, f, indent=4)

    def process_single_code(i, original_code):
        """处理单个代码样本"""
        cfg_file = f"{task_type}/{model_name}/cfg/{i}.json"
        os.makedirs(os.path.dirname(cfg_file), exist_ok=True)  # 确保cfg目录存在
        
        if os.path.exists(cfg_file):
            return None, None
        
        print(f"Processing sample {i}")
            
        logger = setup_logging(f"{task_type}/{model_name}/logs", index=i)
        logger.info(f"Processing sample {i}")
        try:
            chunks = step_0_split_top_declarations(original_code, logger)
            if isinstance(chunks, dict):
                # 有时LLM可能返回{"declarations":[...]}，做个兼容
                chunks = chunks["declarations"]
            cfg_res = [None] * len(chunks)
            with concurrent.futures.ThreadPoolExecutor() as executor:
                futures_with_index = []
                for index, chunk in enumerate(chunks):
                    future = executor.submit(
                        process_chunk, chunk["code"], chunk["decl_name"], index, logger
                    )
                    futures_with_index.append((index, future))

                for index, future in futures_with_index:
                    result = future.result()
                    cfg_res[index] = result

            all_cfg = step_4_merge_cfgs(cfg_res, logger)
            code = get_code_from_cfg(all_cfg, logger)

            os.makedirs(f"{task_type}/{model_name}/cfg_to_code", exist_ok=True)
            with open(f"{task_type}/{model_name}/cfg_to_code/{i}.cj", "w") as f:
                f.write(code)
            
            with open(cfg_file, "w") as f:
                json.dump(all_cfg, f, indent=4)

            static_similarity = compare_code_similarity_static(original_code, code, logger)
            print("Completed processing sample", i)
            return code, static_similarity
        
        except Exception as e:
            logger.error(f"Error processing sample {i}: {str(e)}")
            return None, None
        
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    csv_file = f"{task_type}/{model_name}/chain_similarity_results.csv"
    if not os.path.exists(csv_file):
        os.makedirs(f"{task_type}/{model_name}", exist_ok=True)
        with open(csv_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['Index', 'Original Code', 'Generated Code', 'Static Similarity', 'LLM Similarity'])

    def process_and_save(i, data):
        """处理单个样本并保存结果"""
        try:
            code, static_similarity = process_single_code(i, data["text"])
            if code is not None:
                with open(csv_file, 'a', newline='', encoding='utf-8') as f:
                    writer = csv.writer(f)
                    writer.writerow([i, data["text"], code, static_similarity])
                print(f"Completed processing sample {i}")
        except Exception as e:
            print(f"Error saving results for sample {i}: {str(e)}")

    with concurrent.futures.ThreadPoolExecutor(max_workers=cpu_count()) as executor:
        futures = [executor.submit(process_and_save, i, data) for i, data in enumerate(datas)]
        for future in concurrent.futures.as_completed(futures):
            try:
                future.result()
            except Exception as e:
                print(f"Task execution failed: {str(e)}")
    
    print(f"All results saved to {csv_file}")