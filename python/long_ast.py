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

####################################
#  日志设置
####################################
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

def extract_code_from_markdown_block(markdown_block: str, logger) -> str:
    """从Markdown代码块中提取代码."""
    try:
        match = re.search(r'```(?:arkts|javascript|js|ts|json|typescript|cangjie|python|java|cpp|c|go|rust|swift|kotlin|scala|ruby|php|html|css|sql)\n(.*)\n```', markdown_block, re.DOTALL)
        if match is not None:
            logger.debug("Successfully extracted code from markdown block")
            return match.group(1)
        
        logger.warning("No code block found, returning original text")
        return markdown_block
    except Exception as e:
        logger.error(f"Error extracting code block: {str(e)}")
        raise

####################################
#  Step 0: 拆分大代码
####################################
def step_0_split_top_declarations(whole_code: str, logger) -> List[Dict[str, Any]]:
    """
    Step 0: 对大代码做解析,将顶层声明按行号拆分.
    
    Returns:
        每个块的 { "decl_name":..., "start_line":..., "end_line":..., "code":... }
    """
    try:
        logger.info("Starting Step 0: Splitting code into top-level declarations")
        
        code_lines = whole_code.split('\n')
        code_array = [{"line": i, "content": line} for i, line in enumerate(code_lines, 1)]
        
        prompt = """
You are a senior code analysis assistant. We have a potentially large cangjie code snippet.
Please split it into top-level declarations or blocks, returning a JSON array. 
Each element should have:
- "decl_name": an identifier or best guess of the block's name
- "start_line" and "end_line": line numbers in the original snippet

If there's top-level statements that aren't inside a class/function, group them as a block too.

Cangjie code (with line numbers):
""" + json.dumps(code_array, indent=2) + """

Requirements:
1) Return strictly valid JSON with an array of objects under "blocks".
2) Do not omit any line from the code. Every line should be in exactly one block.
3) "decl_name" can be something like "GlobalBlock", "FuncName", "ClassName", etc.
4) Only include start_line and end_line in response, do not include code content.

Your output should be like:
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
"""
        response = get_llm_answers(prompt, model_name="deepseek-chat", require_json=True)
        blocks_obj = json.loads(response)
        # 预防性检查
        if "blocks" not in blocks_obj or not isinstance(blocks_obj["blocks"], list):
            raise ValueError("LLM response doesn't contain 'blocks' as a list.")
        
        chunks = blocks_obj["blocks"]
        
        # 给每个块加 code
        for chunk in chunks:
            start_line = chunk["start_line"]
            end_line = chunk["end_line"]
            chunk["code"] = "\n".join(code_lines[start_line-1:end_line]) + "\n"
            
        logger.info(f"Successfully split code into {len(chunks)} top-level declarations")
        return chunks
    except Exception as e:
        logger.error(f"Error in step_0_split_top_declarations: {str(e)}")
        raise

####################################
#  token化逻辑（改成返回 idx->string）
####################################
def tokenize_code(code: str, start_index: int = 0) -> Dict[int, str]:
    """
    使用正则对代码进行分割，包括换行符等特殊字符，并给每个token标序号。
    返回: { (start_index+0): tokenStr0, (start_index+1): tokenStr1, ... }
    """
    # 将换行制表符替换为可见标记,再用正则分词
    code = code.replace('\n', ' \\n ').replace('\t', ' \\t ').replace('\r', ' \\r ')
    token_pattern = r'[A-Za-z_]\w*|[$$\{\}\;\,\=\+\-\*/]|[0-9]+|"[^"]*"|\'[^\']*\'|\\[ntr]|\S'
    raw_tokens = re.findall(token_pattern, code)
    
    token_objects = {}
    for idx, tk in enumerate(raw_tokens):
        if tk == '\\n':
            tk = '\n'
        elif tk == '\\t':
            tk = '\t'
        elif tk == '\\r':
            tk = '\r'
        token_objects[idx + start_index] = tk
    
    return token_objects

####################################
#  Prompt 1
####################################
def step1_prompt(token_list: Dict[int, str]) -> str:
    """
    让大模型识别顶层声明, 产出 partial AST node
    """
    # 把字典转成 [{"index":..., "token":...}, ...]
    
    prompt = """You are an AST analysis assistant. We are dealing with a custom programming language called "cangjie," 
which is different from Java or Rust. It may include special syntax or tokens (like semicolons, return types, etc.) 
that we must preserve in the AST.

We rely only on the following token list (each token has an index and its raw content). 
Please identify each top-level declaration (such as functions, classes, global variables, etc.) in "cangjie" code.

Token List is a dictionary, key is index, value is token.
""" + json.dumps(token_list, indent=2, ensure_ascii=False) + """

Task:
1. Identify top-level declarations (functions, classes, global variables, etc.) from the token list.
2. For each top-level declaration, produce a partial AST node in JSON format, ensuring the following structure:
   [
     {
       "type": "Program",
       "name": "someNameOrEmpty",
       "range": [startIndex, endIndex],
       "children": []
     },
     ...
   ]
3. Each returned object should represent exactly one top-level declaration. 
4. "range" should be the [startIndex, endIndex] in the token list. 
5. "name" can be the function/class name if applicable, or an empty string if not applicable.
6. We must preserve cangjie-specific tokens (e.g., semicolons, return types) if they are relevant to the declaration boundary or name.
7. Return only valid JSON, with no extra explanations.

Example output:
[
  {
    "type": "Program",
    "name": "foo",
    "range": [10, 50],
    "children": []
  }
]
"""
    return prompt

####################################
#  Prompt 2
####################################
def step2_prompt(token_list: Dict[int, str], step1_result: Any) -> str:
    prompt = f"""You are an AST analysis assistant. Below is "cangjie" code, tokenized with indexes, 
and a set of partial AST nodes representing top-level declarations from the previous step.

1. The complete token list (including indexes). Token List is a dictionary, key is index, value is token.
{json.dumps(token_list, indent=2, ensure_ascii=False)}

2. The partial AST nodes from the previous step (representing top-level declarations).
{json.dumps(step1_result, indent=2, ensure_ascii=False)}

Task:
1. For each top-level declaration, parse its inner content (the tokens within its [start, end] range).
2. Build a more detailed tree by populating the "children" array. 
3. Keep the cangjie language tokens (like semicolons, return type tokens, or any cangjie-specific keywords) that might define structure or meaning.
4. Each child node follows the same format:
   {{
     "type": "...",
     "name": "...",
     "range": [startIndex, endIndex],
     "children": [...]
   }}
5. This step focuses on creating a hierarchical structure of statements, expressions, or blocks if possible. 
6. Only return valid JSON, an array of these AST nodes.
"""
    return prompt

####################################
#  Prompt 3
####################################
def step3_prompt(token_list: Dict[int, str], step2_result: Any) -> str:
    prompt = f"""You are an AST analysis assistant. We have "cangjie" code tokens and a possibly verbose AST from the previous step. 
Following are: 
1. The complete token list. Token List is a dictionary, key is index, value is token.
{json.dumps(token_list, indent=2, ensure_ascii=False)}

2. The current (possibly verbose) AST from the previous step.
{json.dumps(step2_result, indent=2, ensure_ascii=False)}

Task:
1. Simplify or abstract the AST. Remove punctuation tokens (e.g., braces, commas) unless they represent a distinct syntax block node.
2. Keep important nodes (e.g., statements, expressions, identifiers, literals).
3. Retain the same JSON schema: 
   [
     {{
       "type": "...",
       "name": "...",
       "range": [startIndex, endIndex],
       "children": [ ... ]
     }},
     ...
   ]
4. Return the refined AST in valid JSON format only, with no extra text.
5. Carefully preserve any cangjie-specific tokens that define structure, 
   such as certain semicolons or return-type tokens that might be crucial for the AST correctness.
"""
    return prompt

####################################
#  Prompt 4
####################################
def step4_prompt(step3_result: Any) -> str:
    prompt = f"""You are an AST analysis assistant. The following JSON represents the current AST, but it may have inconsistent node types or missing standardization.
{json.dumps(step3_result, indent=2, ensure_ascii=False)}

Task:
1. Normalize the node types (e.g., use "IfStatement", "ForStatement", "WhileStatement", "FunctionDecl", "ClassDecl", etc.). 
2. If there are expression nodes, ensure they are consistently labeled (e.g., "BinaryExpression", "CallExpression", "Literal", "Identifier").
3. Preserve the schema:
   {{
     "type": "...",
     "name": "...",
     "range": [startIndex, endIndex],
     "children": [ ... ]
   }}
4. Return only the updated AST in JSON format, with no additional explanations.
"""
    return prompt

####################################
#  Prompt 5
####################################
def step5_prompt(step4_result: Any) -> str:
    prompt = f"""You are an AST analysis assistant. Below is the list of AST nodes for all top-level declarations. 
{json.dumps(step4_result, indent=2, ensure_ascii=False)}

Task:
1. Combine them into a single array of AST nodes, each having the structure:
   {{
     "type": "Program",
     "name": "...",
     "range": [start, end],
     "children": [...]
   }}
2. If you wish, you can have multiple top-level nodes in the array, or unify them under one "Program" node. 
3. Return only valid JSON. No explanations.

Example (the final shape we want):
[
  {{
    "type": "Program",
    "name": "MainOrSomething",
    "range": [0, 200],
    "children": [ ... ]
  }},
  ...
]
"""
    return prompt

####################################
#  从AST生成代码
####################################
def get_code_from_ast(ast: Dict[str, Any], logger) -> str:
    """
    从AST生成cangjie代码
    """
    try:
        logger.info("Starting code generation from AST")
        
        prompt = f"""
请根据给出的AST生成cangjie编程语言代码。
AST如下:
{json.dumps(ast, indent=4, ensure_ascii=False)}
输出请以```cangjie开头，```结尾。
"""

        # 如果 get_llm_answers 需要对话结构，可以自己封装
        res_step1 = get_llm_answers(prompt, model_name="deepseek-chat")
        code = extract_code_from_markdown_block(res_step1, logger)
        
        if not code:
            logger.warning("Generated empty code")
            return ""
            
        logger.info("Successfully generated code from AST")
        return code
    except Exception as e:
        logger.error(f"Error in get_code_from_ast: {str(e)}")
        return ""

####################################
#  静态相似度比较
####################################
def compare_code_similarity_static(original_code: str, code: str, logger) -> Dict[str, float]:
    """
    通过静态指标比较两段代码的相似度
    """
    try:
        logger.info("Starting static code similarity comparison")
        
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
        
        # 长度相似度
        len_ratio = min(len(code), len(original_code)) / max(len(code), len(original_code)) if max(len(code), len(original_code))>0 else 1.0
        
        # Token相似度
        orig_tokens = set(tokenize_code(original_code).values())
        gen_tokens  = set(tokenize_code(code).values())
        intersection = len(orig_tokens.intersection(gen_tokens))
        union = len(orig_tokens.union(gen_tokens))
        token_similarity = intersection / union if union > 0 else 0
        
        # 结构相似度 (缩进等)
        def get_indent_pattern(code_str: str) -> List[int]:
            lines = [line for line in code_str.split('\n') if line.strip()]
            if not lines:
                return []
            indents = [len(line) - len(line.lstrip()) for line in lines]
            indent_to_level = {}
            current_level = 0
            levels = []
            for ind in indents:
                if ind not in indent_to_level:
                    indent_to_level[ind] = current_level
                    current_level += 1
                levels.append(indent_to_level[ind])
            return levels
        
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
        
        orig_pattern = get_indent_pattern(original_code)
        gen_pattern = get_indent_pattern(code)
        structure_diff = levenshtein(orig_pattern, gen_pattern)
        max_diff = max(len(orig_pattern), len(gen_pattern))
        structure_similarity = 1 - (structure_diff / max_diff if max_diff > 0 else 0)
        
        # 简易的函数数量相似
        def count_functions(code_str: str) -> int:
            # 匹配 cangjie 的函数声明模式:
            # public func xxx(
            # private func xxx(
            # func xxx(
            return len(re.findall(r'\b(?:public\s+|private\s+)?func\s+\w+\s*\(', code_str))
        
        orig_funcs = count_functions(original_code)
        gen_funcs = count_functions(code)
        func_ratio = min(orig_funcs, gen_funcs)/max(orig_funcs, gen_funcs) if max(orig_funcs, gen_funcs)>0 else 1
        
        # 循环等复杂度
        def calc_cyclomatic_complexity(code_str: str) -> int:
            return len(re.findall(r'\b(if|while|for|match)\b', code_str)) + 1
        
        orig_complexity = calc_cyclomatic_complexity(original_code)
        gen_complexity = calc_cyclomatic_complexity(code)
        complexity_ratio = min(orig_complexity, gen_complexity)/max(orig_complexity, gen_complexity) if max(orig_complexity, gen_complexity)>0 else 1
        
        # 变量名相似
        def extract_variables(code_str: str) -> set:
            return set(re.findall(r'\blet\s+(\w+)\b', code_str))  # 同样可以改为cangjie的声明模式
        orig_vars = extract_variables(original_code)
        gen_vars  = extract_variables(code)
        var_intersection = len(orig_vars.intersection(gen_vars))
        var_union = len(orig_vars.union(gen_vars))
        var_similarity = var_intersection / var_union if var_union>0 else 1
        
        # 最终打分
        final_score = (
            len_ratio * 0.15 + 
            token_similarity * 0.3 + 
            structure_similarity * 0.25 +
            func_ratio * 0.1 +
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
        
        logger.info(f"Static similarity result: {result}")
        return result
    except Exception as e:
        logger.error(f"Error in compare_code_similarity_static: {str(e)}")
        raise

####################################
#  JSON修复流程 (示例)
####################################
def handle_output(res, logger):
    """处理JSON不合法的情况,让LLM修复"""
    try:
        logger.info("Starting to fix JSON output")
        res = get_llm_answers(
            f"Please fix the following JSON file: {res} so that it can be parsed by json.loads. "
            f"Don't output anything else except the fixed JSON.",
            model_name="gpt-4o-2024-11-20",
            require_json=True
        )
        res = extract_code_from_markdown_block(res, logger)
        logger.info(f"Fixed JSON:\n{res}")
        json_obj = json.loads(res)
        return json_obj
    except Exception as e:
        error_msg = f"处理结果失败: {str(e)}\n{traceback.format_exc()}"
        logger.error(error_msg)
        return []

####################################
#  主流程: 5步生成AST
####################################
def main_flow_for_ast(code: str, start_index: int = 0, logger=None) -> Dict:
    logger.info("Starting main AST analysis flow")
    model_name = "deepseek-chat"  # 你也可以外部传入
    
    # 1) token化
    tokens = tokenize_code(code, start_index)  # dict: {index: "token_str"}
    logger.info(f"Tokenized code into {len(tokens)} tokens")
    
    # Step1
    logger.info("Starting Step 1: Initial AST node identification")
    prompt1 = step1_prompt(tokens)
    response1 = get_llm_answers(prompt1, model_name=model_name, require_json=True)
    try:
        step1_result = json.loads(response1)
        logger.info(f"Step 1 result: {step1_result}")
    except:
        logger.error("Failed to parse Step 1 result")
        step1_result = {}
    
    # Step2
    logger.info("Starting Step 2: Detailed AST construction")
    prompt2 = step2_prompt(tokens, step1_result)
    response2 = get_llm_answers(prompt2, model_name=model_name, require_json=True)
    try:
        step2_result = json.loads(response2)
        logger.info(f"Step 2 result: {step2_result}")
    except:
        logger.error("Failed to parse Step 2 result")
        step2_result = {}
    
    # Step3
    logger.info("Starting Step 3: AST simplification")
    prompt3 = step3_prompt(tokens, step2_result)
    response3 = get_llm_answers(prompt3, model_name=model_name, require_json=True)
    try:
        step3_result = json.loads(response3)
        logger.info(f"Step 3 result: {step3_result}")
    except:
        logger.error("Failed to parse Step 3 result")
        step3_result = {}
    
    # Step4
    logger.info("Starting Step 4: AST normalization")
    prompt4 = step4_prompt(step3_result)
    response4 = get_llm_answers(prompt4, model_name=model_name, require_json=True)
    try:
        step4_result = json.loads(response4)
        logger.info(f"Step 4 result: {step4_result}")
    except:
        logger.error("Failed to parse Step 4 result")
        step4_result = {}
    
    # Step5
    logger.info("Starting Step 5: Final AST combination")
    prompt5 = step5_prompt(step4_result)
    response5 = get_llm_answers(prompt5, model_name=model_name, require_json=True)
    try:
        final_ast = json.loads(response5)
        logger.info(f"Step 5 result: {final_ast}")
    except:
        logger.error("Failed to parse Step 5 result")
        final_ast = {}
    
    logger.info("Completed main AST analysis flow")
    return final_ast

####################################
#  在chunk AST上添加 content
####################################
def add_content_to_ast(ast: Dict, token_dict: Dict[int, str]):
    """
    根据 token_dict 为AST节点添加 content属性 (拼接range内的所有token).
    ast: 形如 { "type":..., "range":[start,end], "children":[...] }
    token_dict: { index: "someToken" }
    """
    if not ast or not isinstance(ast, dict):
        return
    
    if "range" in ast and isinstance(ast["range"], list) and len(ast["range"]) == 2:
        start = ast["range"][0]
        end   = ast["range"][1]
        
        content_tokens = []
        for idx, tk in token_dict.items():
            if start <= idx <= end:
                content_tokens.append(tk)
        
        # 处理相邻token之间是否需要空格
        content = ""
        for i, token in enumerate(content_tokens):
            if i > 0:
                # 如果当前和前一个token都包含字母,则添加空格
                prev_has_alpha = any(c.isalpha() for c in content_tokens[i-1]) or content_tokens[i-1] == '_'
                curr_has_alpha = any(c.isalpha() for c in token) or token == '_'
                if prev_has_alpha and curr_has_alpha:
                    content += " "
            content += token
        ast["content"] = content

    # 递归处理子节点
    for key, value in ast.items():
        if isinstance(value, dict):
            add_content_to_ast(value, token_dict)
        elif isinstance(value, list):
            for item in value:
                if isinstance(item, dict):
                    add_content_to_ast(item, token_dict)

####################################
#  单个chunk -> AST
####################################
def process_single_chunk(chunk_code: str, start_index: int, logger) -> Dict:
    logger.info(f"Processing chunk with {len(chunk_code)} chars starting at index {start_index}")
    ast_result = main_flow_for_ast(chunk_code, start_index, logger)
    logger.info("Successfully processed chunk")
    return ast_result

####################################
#  合并多个chunk AST
####################################
def merge_chunk_asts(chunk_asts: List[Dict]) -> Dict:
    """
    将多个 chunk 的 AST 合并成一个全局 Program AST。
    格式: {"type": "Program", "name":"Global", "range":[start,end], "children":[...]}
    """
    children = []
    total_range = [float('inf'), 0]
    
    for ast_dict in chunk_asts:
        if ast_dict and "range" in ast_dict:
            total_range[0] = min(total_range[0], ast_dict["range"][0])
            total_range[1] = max(total_range[1], ast_dict["range"][1])
            if "children" in ast_dict:
                children.extend(ast_dict["children"])
    
    if total_range[0] == float('inf'):
        total_range = [0, 0]
    
    global_ast = {
        "type": "Program",
        "name": "Global",
        "range": total_range,
        "children": children
    }
    return global_ast

####################################
#  大文件流程
####################################
def process_large_file(large_code: str, logger) -> Dict:
    """
    将大文件分块，然后在每个块上执行 AST 流程，再合并。
    """
    # 1. 分块
    chunks = step_0_split_top_declarations(large_code, logger)
    
    # 2. 计算每个块的token起始序号
    current_index = 0
    for chunk in chunks:
        chunk["start_index"] = current_index
        chunk_tokens = tokenize_code(chunk["code"])
        current_index += len(chunk_tokens)
    
    # 3. 并发处理每个块
    from concurrent.futures import ThreadPoolExecutor
    
    chunk_asts = [None]*len(chunks)
    
    def process_chunk_item(args):
        i, chunk = args
        chunk_code = chunk["code"]
        start_index = chunk["start_index"]
        logger.info(f"Processing chunk #{i} (size={len(chunk_code)} chars, start_index={start_index})")
        return i, process_single_chunk(chunk_code, start_index, logger)
    
    with ThreadPoolExecutor(max_workers=cpu_count()) as executor:
        futures = list(executor.map(process_chunk_item, enumerate(chunks)))
        for i, ast_result in futures:
            chunk_asts[i] = ast_result
    
    # 4. 合并 AST
    final_ast = merge_chunk_asts(chunk_asts)
    return final_ast

####################################
#  Main 流程 (示例)
####################################
if __name__ == "__main__":
    model_name = "deepseek-chat"
    task_type = "llm_ast"
    os.makedirs(f"{task_type}/{model_name}", exist_ok=True)
    
    # 全局日志
    logger = setup_logging(log_dir=f"{task_type}/{model_name}/logs", index=None)

    datas = []
    for file in os.listdir("data"):
        if file.endswith(".py"):
            with open(os.path.join("data", file), "r", encoding="utf-8") as f:
                datas.append({"text": f.read()})

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    csv_file = f"{task_type}/{model_name}/chain_similarity_results.csv"
    if not os.path.exists(csv_file):
        os.makedirs(f"{task_type}/{model_name}", exist_ok=True)
        with open(csv_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['Index', 'Original Code', 'Generated Code', 'Static Similarity'])

    def process_single_code(i, original_code):
        """处理单个代码样本"""
        ast_file = f"{task_type}/{model_name}/ast/{i}.json"
        os.makedirs(os.path.dirname(ast_file), exist_ok=True)
        
        if os.path.exists(ast_file):
            # print(f"Skipping sample {i} as it already exists")
            return None, None
        
        print(f"Processing sample {i}")
        logger_i = setup_logging(f"{task_type}/{model_name}/logs", index=i)
        logger_i.info(f"Processing sample {i}")
        
        try:
            # 生成 AST
            ast_result = process_large_file(original_code, logger_i)
            
            # 为 AST 添加 content
            token_dict = tokenize_code(original_code)
            add_content_to_ast(ast_result, token_dict)

            # 保存 AST
            with open(ast_file, "w", encoding="utf-8") as f:
                json.dump(ast_result, f, indent=4, ensure_ascii=False)

            # 从 AST 生成代码
            code = get_code_from_ast(ast_result, logger_i)
            os.makedirs(f"{task_type}/{model_name}/code", exist_ok=True)
            with open(f"{task_type}/{model_name}/code/{i}.cj", "w", encoding="utf-8") as f:
                f.write(code)

            # 静态相似度比较
            static_similarity = compare_code_similarity_static(original_code, code, logger_i)
            
            print("Completed processing sample", i)
            return code, static_similarity
        
        except Exception as e:
            print(f"Error processing sample {i}: {str(e)}")
            logger_i.error(f"Error processing sample {i}: {str(e)}\n{traceback.format_exc()}")
            return None, None

    def process_and_save(i, data):
        """处理单个样本并保存结果到 CSV"""
        try:
            code, static_similarity = process_single_code(i, data["text"])
            if code is not None:
                with open(csv_file, 'a', newline='', encoding='utf-8') as f:
                    writer = csv.writer(f)
                    writer.writerow([i, data["text"], code, static_similarity])
                print(f"Completed processing sample {i}")
        except Exception as e:
            print(f"Error saving results for sample {i}: {str(e)}")

    with concurrent.futures.ThreadPoolExecutor(max_workers=64) as executor:
        futures = [executor.submit(process_and_save, i, data) for i, data in enumerate(datas)]
        for future in concurrent.futures.as_completed(futures):
            try:
                future.result()
            except Exception as e:
                print(f"Task execution failed: {str(e)}")
    
    print(f"All results saved to {csv_file}")