"""
Multi-threaded script where we separately:
1) Generate an LLM-based AST,
2) Generate a tree-sitter-based static AST,
3) Compare snippet-level labels,
4) Save both ASTs as JSON.

We split logic into two main functions:
- generate_llm_ast(code): returns LLM AST
- generate_static_ast(code): returns tree-sitter static AST

Then process_single_file() calls both, compares, and saves results.
Finally main() uses ThreadPoolExecutor to process multiple files in parallel.

Dependencies:
- pip install py-tree-sitter
- Ensure you have a valid llm.py with get_llm_answers()
- (Optional) pip install transformers, if using HF tokenizer
"""

import os
import sys
import json
from typing import Any, Dict, List, Tuple
import concurrent.futures
from multiprocessing import cpu_count

# LLM interface
from llm import get_llm_answers

# py-tree-sitter
import tree_sitter_python as tspython
from tree_sitter import Language, Parser

###############################################################################
#                          Tree-sitter initialization                         #
###############################################################################
PY_LANGUAGE = Language(tspython.language())
parser = Parser(PY_LANGUAGE)

###############################################################################
#                       Tokenization & Utility Functions                      #
###############################################################################
# 示例：用 Hugging Face 的 Tokenizer
from transformers import AutoTokenizer

# 加载分词器（请根据需要修改你的模型路径或名称）
tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct", cache_dir="/home/models")


def tokenize_code(code: str) -> List[Tuple[int, int, str]]:
    """
    使用 Transformers 的 tokenizer，对代码进行分词并返回一个列表：
        [(start_offset, end_offset, token_text), ...]
    注意：
      1) 可能会出现 sub-token 拆分，比如 'import' -> ['im', 'port']
      2) 如果需要语言级的分词（如 Python 关键字、标识符），
         可能要自己封装或直接用 tokenizer的分词结果再手动合并。
    
    为简化示例，这里不做合并，直接把 sub-token 也看做一个最小单元。
    """
    encoding = tokenizer(
        code,
        return_offsets_mapping=True,    # 关键：返回 (start_offset, end_offset)
        add_special_tokens=False        # 不加特殊符号（[CLS], [SEP] 等）
    )
    offsets = encoding["offset_mapping"]
    input_ids = encoding["input_ids"]

    # 构造 (start_offset, end_offset, token_text)
    tokens_with_offset = []
    for (start, end) in offsets:
        # 如果 start==end，说明是空token（可能是分隔符等），跳过
        if start < end:
            token_text = code[start:end]
            tokens_with_offset.append((start, end, token_text))
    return tokens_with_offset


def rebuild_label_llm(
    code: str,
    indexed_tokens: List[Tuple[int, int, str]],  # [(start_offset, end_offset, token_text), ...]
    start_token: int,
    end_token: int
) -> str:
    """
    根据 start_token / end_token 在 indexed_tokens 中查找首尾字符偏移，
    然后从源码中截取原始片段。
    
    - indexed_tokens[i] = (start_offset, end_offset, token_text)
    - start_offset, end_offset 是在 code 中的字符位置
    - 这样就能保留原本的空格或紧邻字符，不会出现硬插空格的问题。
    """
    if (start_token < 0 or end_token < 0
        or start_token >= len(indexed_tokens)
        or end_token >= len(indexed_tokens)
        or end_token < start_token):
        return ""

    # 取出区间内所有 tokens 的最小 start_offset 和最大 end_offset
    start_offset = indexed_tokens[start_token][0]  # 第一个token的start
    end_offset = indexed_tokens[end_token][1]      # 最后一个token的end

    if start_offset < 0 or end_offset > len(code):
        return ""

    snippet = code[start_offset:end_offset]
    return snippet


def collect_llm_labels(
    node: Dict[str, Any],
    code: str,
    indexed_tokens: List[Tuple[int, int, str]]
) -> None:
    """
    递归地给 LLM AST 中每个节点设置 node["label"]，
    使用 start_token / end_token 对应的 offset 在 code 中切片。
    """
    st = node.get("start_token", -1)
    et = node.get("end_token", -1)
    snippet = rebuild_label_llm(code, indexed_tokens, st, et)
    node["label"] = snippet

    for child in node.get("children", []):
        collect_llm_labels(child, code, indexed_tokens)

###############################################################################
#                         Compare: snippet-level text                         #
###############################################################################

def compare_ast_nodes(
    node1: Dict[str, Any],
    node2: Dict[str, Any],
    path: str = ""
):
    """
    Compare node["label"] text, plus child count, recursively.
    """
    if not node1 or not node2:
        return

    label1 = (node1.get("label", "") or "").strip()
    label2 = (node2.get("label", "") or "").strip()
    if label1 != label2:
        print(f"[Diff] label mismatch at {path}:")
        print(f"  1: {repr(label1)}")
        print(f"  2: {repr(label2)}")

    c1 = node1.get("children", [])
    c2 = node2.get("children", [])
    if len(c1) != len(c2):
        print(f"[Diff] Child count mismatch at {path}: {len(c1)} vs {len(c2)}")

    for i in range(min(len(c1), len(c2))):
        compare_ast_nodes(c1[i], c2[i], path + f".children[{i}]")

###############################################################################
#                        1) Generate LLM AST (chunk-based)                    #
###############################################################################


def llm_build_ast_from_tokens(tokens_with_offset: List[Tuple[int, int, str]]) -> Dict[str, Any]:
    """
    1) 把 tokens 列表转成可读字符串 token_info (index -> token_string)
    2) 调用 LLM, 返回 JSON AST
    - 这里 tokens_with_offset[i] = (start_offset, end_offset, token_string)
    - 我们只在 prompt 中打印 i 和 token_string 用于提示
    """
    indexed_tokens = [(i, t[2]) for i, t in enumerate(tokens_with_offset)]
    token_info = "\n".join(f"{i}: {text}" for (i, text) in indexed_tokens)

    prompt = (
        "Below is a list of tokens (index -> token_string) for a code snippet:\n"
        f"{token_info}\n\n"
        "Please create a JSON-based AST with fields:\n"
        "- type\n"
        "- start_token\n"
        "- end_token\n"
        "- children\n"
        "Ensure the output is valid JSON."
        "The leaf node should be a single token node. Each token which is an identifier, number, string, or essential keyword (e.g., if, else, do, while, for) should appear as its own leaf node. "
        "System or language-level symbols such as \\n, from, import, def, class, etc. can be omitted or merged into higher-level nodes, as they do not need to appear as leaf nodes."
    )

    try:
        llm_output = get_llm_answers(
            prompt,
            model_name="gpt-4o",  # 示例model名，可换
            require_json=True,
            temperature=0
        )
        ast_dict = json.loads(llm_output)
        return ast_dict
    except Exception as e:
        print(f"[Error] LLM build AST: {e}")
        return {
            "type": "ErrorNode",
            "start_token": -1,
            "end_token": -1,
            "children": []
        }


def llm_determine_chunk_boundaries(code: str) -> List[Tuple[int, int]]:
    """
    调用 LLM 来确定代码分块（分段）行号的示例。
    如果 LLM 出错或返回结果不合要求，就回退到整段处理。
    """
    lines = code.splitlines()
    numbered_code = "\n".join(f"{i+1}: {line}" for i, line in enumerate(lines))
    prompt = (
        f"Below is code with line numbers:\n{numbered_code}\n\n"
        "Please split this code into top-level sections by line range. Return JSON like:\n"
        "[[1, 10], [11, 30], ...]"
    )
    try:
        raw = get_llm_answers(
            prompt,
            model_name="gpt-4o",
            require_json=True,
            temperature=0
        )
        arr = json.loads(raw)
        boundaries = []
        for item in arr:
            if isinstance(item, list) and len(item) == 2:
                boundaries.append((item[0], item[1]))
        if not boundaries:
            return [(1, len(lines))]
        return boundaries
    except Exception as e:
        print(f"[Error] LLM chunk boundary: {e}")
        return [(1, len(lines))]


def extract_lines(code: str, start_line: int, end_line: int) -> str:
    """
    截取指定行区间的代码片段。
    """
    all_lines = code.splitlines(keepends=True)
    if start_line < 1:
        start_line = 1
    if end_line > len(all_lines):
        end_line = len(all_lines)
    return "".join(all_lines[start_line - 1:end_line])


def chunk_and_build_llm_ast(
    code: str,
    recursion_level=0,
    max_chunk_size=3000
) -> Dict[str, Any]:
    """
    先用 LLM 拆分成片段，再对每个片段进行分词(并记录offset)，生成AST。
    如果 chunk 依然太长，就递归拆分。
    """
    if recursion_level > 5:
        tokens_with_offset = tokenize_code(code)
        return llm_build_ast_from_tokens(tokens_with_offset)

    boundaries = llm_determine_chunk_boundaries(code)
    if len(boundaries) == 1:
        sl, el = boundaries[0]
        snippet = extract_lines(code, sl, el)
        if len(snippet) > max_chunk_size:
            half = (sl + el) // 2
            code1 = extract_lines(code, sl, half)
            code2 = extract_lines(code, half + 1, el)
            ast1 = chunk_and_build_llm_ast(code1, recursion_level + 1, max_chunk_size)
            ast2 = chunk_and_build_llm_ast(code2, recursion_level + 1, max_chunk_size)
            return {"type": "Module", "children": [ast1, ast2]}
        else:
            tokens_with_offset = tokenize_code(snippet)
            return llm_build_ast_from_tokens(tokens_with_offset)

    # 如果 LLM chunk boundary 返回多段
    partial = []
    for (sl, el) in boundaries:
        snippet = extract_lines(code, sl, el)
        if len(snippet) > max_chunk_size:
            sub_ast = chunk_and_build_llm_ast(snippet, recursion_level + 1, max_chunk_size)
            partial.append(sub_ast)
        else:
            tokens_with_offset = tokenize_code(snippet)
            sub_ast = llm_build_ast_from_tokens(tokens_with_offset)
            partial.append(sub_ast)

    return {"type": "Module", "children": partial}


def generate_llm_ast(code: str) -> Dict[str, Any]:
    """
    Public function to generate LLM-based AST from code,
    plus collecting snippet labels.
    """
    llm_ast = chunk_and_build_llm_ast(code)
    # 这里再次对整份 code 分词(带offset)，用来最终补充 label
    all_tokens_with_offset = tokenize_code(code)
    collect_llm_labels(llm_ast, code, all_tokens_with_offset)
    return llm_ast

###############################################################################
#              2) Generate Tree-sitter-based "static" Python AST             #
###############################################################################

class PyTreeSitterStaticHandler:
    """
    We'll produce an AST structure: {type, label, children},
    where label = node.text.decode("utf-8") for the entire node range.
    """
    def __init__(self):
        self.parser = parser

    def generate_static_ast(self, code: str) -> Dict[str, Any]:
        tree = self.parser.parse(code.encode("utf-8"))
        root_node = tree.root_node
        return self.ts_node_to_dict(root_node)

    def ts_node_to_dict(self, node) -> Dict[str, Any]:
        if not node.is_named:
            return None
        node_type = node.type
        node_text = (node.text or b"").decode("utf-8")
        custom = {
            "type": node_type,
            "label": node_text,
            "children": []
        }
        for i in range(node.child_count):
            child = node.child(i)
            sub = self.ts_node_to_dict(child)
            if sub:
                custom["children"].append(sub)
        return custom


def generate_tree_sitter_ast(code: str) -> Dict[str, Any]:
    """
    Public function to parse code with tree-sitter, returning {type, label, children}.
    """
    handler = PyTreeSitterStaticHandler()
    return handler.generate_static_ast(code)

###############################################################################
#                         process_single_file logic                           #
###############################################################################

def process_llm_ast(code: str, file_path: str) -> dict:
    """处理LLM AST生成和保存"""
    llm_ast = generate_llm_ast(code)
    llm_out_dir = "llm_ast"
    os.makedirs(llm_out_dir, exist_ok=True)
    llm_json_path = os.path.join(llm_out_dir, os.path.basename(file_path) + ".json")
    with open(llm_json_path, "w", encoding="utf-8") as fout:
        json.dump(llm_ast, fout, indent=4, ensure_ascii=False)
    print(f"[LLM AST] => {llm_json_path}")
    return llm_ast

def process_static_ast(code: str, file_path: str) -> dict:
    """处理静态AST生成和保存"""
    ts_ast = generate_tree_sitter_ast(code)
    ts_out_dir = "static_ast"
    os.makedirs(ts_out_dir, exist_ok=True)
    ts_json_path = os.path.join(ts_out_dir, os.path.basename(file_path) + ".json")
    with open(ts_json_path, "w", encoding="utf-8") as fout:
        json.dump(ts_ast, fout, indent=4, ensure_ascii=False)
    print(f"[TS AST] => {ts_json_path}")
    return ts_ast

def process_single_file(file_path: str):
    """
    1) read code
    2) generate LLM AST 
    3) generate static AST (tree-sitter)
    4) compare snippet-level label
    5) store as JSON
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            code = f.read()
    except Exception as e:
        print(f"[Error] reading {file_path}: {e}")
        return

    # 2) generate LLM AST
    # llm_ast = process_llm_ast(code, file_path)

    # 3) generate static AST
    ts_ast = process_static_ast(code, file_path)

    # 4) compare snippet-level label (可选)
    # compare_ast_nodes(llm_ast, ts_ast)

###############################################################################
#                                 main()                                      #
###############################################################################

def main():
    source_dir = "../source_code"
    if not os.path.isdir(source_dir):
        print(f"[Error] Directory {source_dir} does not exist.")
        return

    files = [f for f in os.listdir(source_dir) if f.endswith(".py")]
    # files = files[:1]  # 示例只处理1个文件

    # for file in files:
    #     # 测试某个特定文件
    #     file = "72.py"
    #     process_single_file(os.path.join(source_dir, file))

    # 并行示例(如果需要):
    with concurrent.futures.ThreadPoolExecutor(max_workers=cpu_count()) as executor:
        futures = []
        for fname in files:
            full_path = os.path.join(source_dir, fname)
            futures.append(executor.submit(process_single_file, full_path))
        concurrent.futures.wait(futures)

if __name__ == "__main__":
    main()
