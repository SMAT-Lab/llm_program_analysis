from dataclasses import dataclass
import os
from typing import List, Dict, Optional
import json
from pathlib import Path

from scalpel.cfg import CFGBuilder

from collections import defaultdict, deque


@dataclass
class CFGNode:
    id: str
    code: str
    order: int  # 添加order来保持顺序
    start_line: int = 0
    end_line: int = 0

@dataclass
class CFGEdge:
    from_node: str
    to_node: str

@dataclass
class CFGData:
    nodes: List[CFGNode]
    edges: List[CFGEdge]

@dataclass
class CodeBlock:
    decl_name: str
    start_line: int
    end_line: int
    children: List['CodeBlock']
    code: str
    cfg: Optional[CFGData] = None

def extract_calls_from_cfg(cfg_node: CFGNode) -> List[str]:
    """从CFG节点的代码中提取函数调用"""
    import ast
    
    class CallVisitor(ast.NodeVisitor):
        def __init__(self):
            self.calls = []
            
        def visit_Call(self, node):
            if isinstance(node.func, ast.Name):
                self.calls.append(node.func.id)
            elif isinstance(node.func, ast.Attribute):
                self.calls.append(node.func.attr)
            self.generic_visit(node)
    
    calls = []
    try:
        tree = ast.parse(cfg_node.code)
        visitor = CallVisitor()
        visitor.visit(tree)
        calls = visitor.calls
    except:
        pass
    
    return calls

@dataclass
class BlockWithCalls:
    """包含调用信息的代码块"""
    decl_name: str
    code: str
    calls: List[str]

def convert_to_blocks_with_calls(code_blocks: List[CodeBlock]) -> List[BlockWithCalls]:
    """将CodeBlock转换为包含调用信息的BlockWithCalls"""
    blocks_with_calls = []
    
    for block in code_blocks:
        calls = []
        if block.cfg:
            # 从所有CFG节点中收集调用
            for node in block.cfg.nodes:
                calls.extend(extract_calls_from_cfg(node))
        
        # 去重调用
        calls = list(set(calls))
        
        blocks_with_calls.append(BlockWithCalls(
            decl_name=block.decl_name,
            code=block.code,
            calls=calls
        ))
    
    return blocks_with_calls

class TopologicalBlockMatcher:
    def __init__(self):
        self.similarity_threshold = 0.7

    def blocks_to_graph(self, blocks: List[BlockWithCalls]) -> Dict[str, List[str]]:
        """将代码块列表转换为邻接表表示的图"""
        graph = defaultdict(list)
        for block in blocks:
            graph[block.decl_name].extend(block.calls)
        return dict(graph)

    def get_block_by_name(self, blocks: List[BlockWithCalls], name: str) -> BlockWithCalls:
        """通过函数名获取代码块"""
        for block in blocks:
            if block.decl_name == name:
                return block
        return None

    def topological_sort(self, blocks: List[BlockWithCalls]) -> List[str]:
        """
        对代码块进行拓扑排序
        Returns:
            排序后的函数名列表
        """
        if not blocks:
            return []
            
        # 构建图
        graph = self.blocks_to_graph(blocks)
        
        # 计算入度
        in_degree = defaultdict(int)
        for node in graph:
            for successor in graph[node]:
                if successor:  # 确保successor不是None
                    in_degree[successor] += 1
            if node not in in_degree:
                in_degree[node] = 0
    
        # 初始化队列（入度为0的节点）
        queue = deque([node for node, degree in in_degree.items() if degree == 0 and node])
        result = []
    
        # BFS进行拓扑排序
        while queue:
            node = queue.popleft()
            if node:  # 确保node不是None
                result.append(node)
                for successor in graph.get(node, []):
                    if successor:  # 确保successor不是None
                        in_degree[successor] -= 1
                        if in_degree[successor] == 0:
                            queue.append(successor)
    
        # 添加可能未被引用的节点
        all_nodes = {block.decl_name for block in blocks if block.decl_name}
        for node in all_nodes:
            if node and node not in result:
                result.append(node)
    
        return result


    def calculate_code_similarity(self, code1: str, code2: str) -> float:
        """计算代码相似度"""
        # 简化代码（移除空白字符和注释）
        def clean_code(code: str) -> str:
            import re
            # 移除注释
            code = re.sub(r'#.*$', '', code, flags=re.MULTILINE)
            # 移除多余空白字符
            code = ' '.join(code.split())
            return code
        
        code1 = clean_code(code1)
        code2 = clean_code(code2)
        
        if not code1 or not code2:
            return 0.0
        
        if code1 == code2:
            return 1.0
            
        # 使用最长公共子序列计算相似度
        return self.lcs_similarity(code1, code2)

    def lcs_similarity(self, s1: str, s2: str) -> float:
        """使用最长公共子序列计算相似度"""
        m, n = len(s1), len(s2)
        dp = [[0] * (n + 1) for _ in range(m + 1)]
        
        for i in range(1, m + 1):
            for j in range(1, n + 1):
                if s1[i-1] == s2[j-1]:
                    dp[i][j] = dp[i-1][j-1] + 1
                else:
                    dp[i][j] = max(dp[i-1][j], dp[i][j-1])
        
        lcs_length = dp[m][n]
        return 2.0 * lcs_length / (len(s1) + len(s2))

    def calculate_structural_similarity(self, 
                                     block1: BlockWithCalls, 
                                     block2: BlockWithCalls, 
                                     position1: int, 
                                     position2: int,
                                     max_pos: int) -> float:
        """计算结构相似度"""
        # 位置相似度
        pos_sim = 1.0 - abs(position1 - position2) / max_pos if max_pos > 0 else 1.0
        
        # 调用关系相似度
        calls1 = set(block1.calls)
        calls2 = set(block2.calls)
        calls_sim = len(calls1 & calls2) / len(calls1 | calls2) if calls1 or calls2 else 1.0
        
        # 计算加权平均
        return 0.4 * pos_sim + 0.6 * calls_sim

    def match_blocks(self, 
                    llm_blocks: List[BlockWithCalls], 
                    static_blocks: List[BlockWithCalls]) -> Dict:
        """匹配两组代码块"""
        # 1. 对两组代码块进行拓扑排序
        sorted_llm = self.topological_sort(llm_blocks)
        sorted_static = self.topological_sort(static_blocks)

        # 2. 计算匹配
        matches = []
        max_pos = max(len(sorted_llm), len(sorted_static)) - 1
        if max_pos < 0:
            max_pos = 0

        # 构建快速查找字典
        llm_blocks_dict = {b.decl_name: b for b in llm_blocks}
        static_blocks_dict = {b.decl_name: b for b in static_blocks}

        for i, name1 in enumerate(sorted_llm):
            block1 = llm_blocks_dict.get(name1)
            if not block1:
                continue

            for j, name2 in enumerate(sorted_static):
                block2 = static_blocks_dict.get(name2)
                if not block2:
                    continue

                # 计算代码相似度
                code_sim = self.calculate_code_similarity(block1.code, block2.code)
                
                # 计算结构相似度
                struct_sim = self.calculate_structural_similarity(
                    block1, block2, i, j, max_pos
                )
                
                # 综合相似度
                similarity = 0.6 * code_sim + 0.4 * struct_sim
                
                if similarity >= self.similarity_threshold:
                    matches.append((name1, name2, similarity))

        return {
            'matches': sorted(matches, key=lambda x: x[2], reverse=True),
            'topological_order_llm': sorted_llm,
            'topological_order_static': sorted_static,
            'coverage': len(set(m[0] for m in matches)) / len(llm_blocks) if llm_blocks else 0.0
        }

def format_match_line(block1: str, block2: str, similarity: float, width: int = 30) -> str:
    """格式化匹配结果行"""
    block1_str = str(block1).ljust(width)
    block2_str = str(block2).ljust(width)
    return f"{block1_str} <-> {block2_str} (相似度: {similarity:.2%})"

def print_match_results(result: Dict):
    """打印匹配结果"""
    print("\n" + "="*50)
    print("代码块匹配结果")
    print("="*50)
    
    print("\n1. 匹配的代码块对:")
    if result['matches']:
        for block1, block2, sim in result['matches']:
            print(format_match_line(block1, block2, sim))
    else:
        print("未找到匹配的代码块")
    
    print("\n2. LLM代码块的拓扑排序:")
    llm_order = [str(x) for x in result['topological_order_llm'] if x is not None]
    print(" -> ".join(llm_order) if llm_order else "空")
    
    print("\n3. 静态分析代码块的拓扑排序:")
    static_order = [str(x) for x in result['topological_order_static'] if x is not None]
    print(" -> ".join(static_order) if static_order else "空")
    
    print(f"\n4. 覆盖率: {result['coverage']:.2%}")
    print("="*50 + "\n")

def parse_json_to_cfg(json_data: dict) -> CodeBlock:
    """将JSON数据解析为CodeBlock对象"""
    cfg = None
    if 'cfg' in json_data:
        cfg_data = json_data['cfg']
        # 创建节点，添加order属性
        nodes = [
            CFGNode(
                id=node['id'], 
                code=node['code'],
                order=idx  # 使用索引作为顺序
            )
            for idx, node in enumerate(cfg_data['nodes'])
        ]
        # 创建边
        edges = [
            CFGEdge(
                from_node=edge['from'], 
                to_node=edge['to']
            )
            for edge in cfg_data['edges']
        ]
        cfg = CFGData(nodes=nodes, edges=edges)

    children = [
        parse_json_to_cfg(child) 
        for child in json_data.get('children', [])
    ]

    return CodeBlock(
        decl_name=json_data['decl_name'],
        start_line=json_data['start_line'],
        end_line=json_data['end_line'],
        code=json_data['code'],
        children=children,
        cfg=cfg
    )

def can_merge_global_nodes(node1: CFGNode, node2: CFGNode, edges: List[CFGEdge]) -> bool:
    """判断全局作用域中的节点是否可以合并"""
    # 检查是否都是全局作用域的节点
    if not (node1.id.startswith("GlobalBlock_") and node2.id.startswith("GlobalBlock_")):
        return False
        
    # 检查节点间是否有其他控制流（如if/else, try/except等）
    node1_code = node1.code.strip()
    node2_code = node2.code.strip()
    
    # 简单检查是否都是导入语句或简单的赋值语句
    def is_simple_statement(code: str) -> bool:
        lines = code.split('\n')
        for line in lines:
            line = line.strip()
            if not line:
                continue
            if not (line.startswith('from ') or 
                   line.startswith('import ') or 
                   '=' in line or 
                   line.startswith('#')):
                return False
        return True
        
    return is_simple_statement(node1_code) and is_simple_statement(node2_code)

def merge_nodes(node1_id: str, node2_id: str, cfg_data: CFGData) -> CFGData:
    """合并两个节点，返回新的CFG数据"""
    nodes_dict = {node.id: node for node in cfg_data.nodes}
    
    # 获取原始节点
    node1 = nodes_dict[node1_id]
    node2 = nodes_dict[node2_id]
    
    # 合并代码
    merged_code = f"{node1.code}\n{node2.code}"
    
    # 创建新节点，保持较小的order
    merged_node = CFGNode(
        id=node1_id,
        code=merged_code,
        order=min(node1.order, node2.order)
    )
    
    # 更新节点列表，保持顺序
    new_nodes = [node for node in cfg_data.nodes if node.id not in {node1_id, node2_id}]
    new_nodes.append(merged_node)
    new_nodes.sort(key=lambda x: x.order)
    
    # 更新边
    new_edges = []
    for edge in cfg_data.edges:
        if edge.from_node == node2_id:
            new_edges.append(CFGEdge(from_node=node1_id, to_node=edge.to_node))
        elif edge.to_node == node2_id:
            continue
        elif edge.from_node != node1_id or edge.to_node != node2_id:
            new_edges.append(edge)
    
    return CFGData(nodes=new_nodes, edges=new_edges)

def can_merge_nodes(from_node_id: str, to_node_id: str, edges: List[CFGEdge], nodes_dict: Dict[str, CFGNode]) -> bool:
    """判断两个节点是否可以合并
    条件：
    1. from_node 必须直接连接到 to_node
    2. to_node 只能有一个入边（来自 from_node）
    3. from_node 只能有一个出边（到 to_node）
    """
    # 检查 from_node -> to_node 的直接连接
    is_directly_connected = any(
        edge.from_node == from_node_id and edge.to_node == to_node_id
        for edge in edges
    )
    if not is_directly_connected:
        return False

    # 检查 to_node 的入边数量
    incoming_edges_to_node = sum(1 for edge in edges if edge.to_node == to_node_id)
    if incoming_edges_to_node > 1:
        return False

    # 检查 from_node 的出边数量
    outgoing_edges_from_node = sum(1 for edge in edges if edge.from_node == from_node_id)
    if outgoing_edges_from_node > 1:
        return False

    return True

def optimize_cfg(cfg_data: CFGData) -> CFGData:
    """优化CFG，合并可以合并的节点"""
    if not cfg_data or len(cfg_data.nodes) <= 1:
        return cfg_data
    
    nodes_dict = {node.id: node for node in cfg_data.nodes}
    changed = True
    
    while changed:
        changed = False
        nodes = sorted(cfg_data.nodes, key=lambda x: x.order)
        
        # 首先尝试合并全局节点
        for i in range(len(nodes) - 1):
            node1 = nodes[i]
            node2 = nodes[i + 1]
            if can_merge_global_nodes(node1, node2, cfg_data.edges):
                cfg_data = merge_nodes(node1.id, node2.id, cfg_data)
                nodes_dict = {node.id: node for node in cfg_data.nodes}
                changed = True
                break
        
        # 如果没有全局节点可以合并，再尝试常规的边合并
        if not changed:
            edges = sorted(cfg_data.edges, 
                         key=lambda e: (nodes_dict[e.from_node].order, nodes_dict[e.to_node].order))
            for edge in edges:
                if can_merge_nodes(edge.from_node, edge.to_node, cfg_data.edges, nodes_dict):
                    cfg_data = merge_nodes(edge.from_node, edge.to_node, cfg_data)
                    nodes_dict = {node.id: node for node in cfg_data.nodes}
                    changed = True
                    break
    
    return cfg_data

def optimize_code_block(block: CodeBlock) -> CodeBlock:
    """优化单个代码块"""
    if block.cfg:
        block.cfg = optimize_cfg(block.cfg)
    
    # 递归优化子块
    block.children = [optimize_code_block(child) for child in block.children]
    return block

def parse_and_optimize_json_to_cfg(json_data: List[dict]) -> List[CodeBlock]:
    """解析JSON并优化所有代码块"""
    blocks = [parse_json_to_cfg(block_data) for block_data in json_data]
    return [optimize_code_block(block) for block in blocks]

def print_code_block_hierarchy(block: CodeBlock, indent: int = 0):
    """打印代码块层次结构"""
    indent_str = "  " * indent
    print(f"{indent_str}Block: {block.decl_name} (lines {block.start_line}-{block.end_line})")
    if block.cfg:
        print(f"{indent_str}CFG Nodes: {len(block.cfg.nodes)}")
        print(f"{indent_str}CFG Edges: {len(block.cfg.edges)}")
        print(f"{indent_str}Nodes (in order):")
        for node in sorted(block.cfg.nodes, key=lambda x: x.order):
            print(f"{indent_str}  Node {node.id} (order {node.order}):")
            print(f"{indent_str}    {node.code.strip()}")
        
        # 打印边的关系
        print(f"{indent_str}Edges:")
        for edge in block.cfg.edges:
            print(f"{indent_str}  {edge.from_node} -> {edge.to_node}")
        print()  # 空行分隔
        
    for child in block.children:
        print_code_block_hierarchy(child, indent + 1)


## static cfg
def parse_block(block):
    """解析基本块"""
    # 获取块中语句的行号范围
    start_line = min([stmt.lineno for stmt in block.statements if hasattr(stmt, 'lineno')] or [0])
    end_line = max([getattr(stmt, 'end_lineno', stmt.lineno) for stmt in block.statements if hasattr(stmt, 'lineno')] or [0])
    
    statements = []
    for stmt in block.statements:
        if hasattr(stmt, 'lineno'):
            try:
                import ast
                if hasattr(ast, 'unparse'):
                    code = ast.unparse(stmt)
                else:
                    code = str(stmt)
            except:
                code = str(stmt)
            statements.append(code)
    
    return {
        "id": block.id,
        "code": "\n".join(statements),
        "start_line": start_line,
        "end_line": end_line,
        "order": getattr(block, 'order', 0)
    }

def process_block(name, block_cfg):
    """处理单个代码块（可以是函数或类方法）"""
    if not hasattr(block_cfg, 'entryblock'):
        return [], []
        
    nodes = []
    edges = []
    visited = set()
    block_order = 0
    
    # 使用广度优先搜索来保持正确的顺序
    queue = [(block_cfg.entryblock, block_order)]
    while queue:
        current_block, order = queue.pop(0)
        if current_block in visited:
            continue
            
        visited.add(current_block)
        
        block_data = parse_block(current_block)
        block_data["order"] = order
        nodes.append(block_data)
        
        # 添加所有出边
        for link in current_block.exits:
            if hasattr(link, "target"):
                edges.append({
                    "from": current_block.id,
                    "to": link.target.id
                })
                if link.target not in visited:
                    block_order += 1
                    queue.append((link.target, block_order))
    
    # 按order排序节点
    nodes.sort(key=lambda x: x["order"])
    return nodes, edges

def process_cfg_recursively(cfg_obj, prefix="", processed=None, context=None):
    """递归处理CFG对象，返回所有代码块"""
    if processed is None:
        processed = set()
    if context is None:
        context = {"in_class": False}
    
    blocks = []
    
    # 使用cfg_obj的id作为唯一标识
    cfg_id = id(cfg_obj)
    if cfg_id in processed:
        return blocks
    processed.add(cfg_id)
    
    # 处理当前层级的主体代码
    if hasattr(cfg_obj, 'entryblock'):
        nodes, edges = process_block(f"{prefix}", cfg_obj)
        if nodes:  # 只有当有实际内容时才添加
            block_type = "GlobalBlock"
            if context.get("in_class"):
                if prefix.endswith(".__init__"):
                    block_type = "Constructor"
                elif "." in prefix:
                    block_type = "Method"
                else:
                    block_type = "ClassBody"
            elif prefix:
                block_type = "Function"
                
            # 处理嵌套类名称
            display_name = prefix
            if "." in prefix and not context.get("in_class"):
                parts = prefix.split(".")
                display_name = ".".join([p if i == 0 else f"Input" if p == "Input" else p 
                                       for i, p in enumerate(parts)])
            
            blocks.append({
                "name": f"{block_type}: {display_name}" if prefix else block_type,
                "nodes": nodes,
                "edges": edges,
                "type": block_type,
                "original_name": prefix,  # 保存原始名称用于排序
                "line_info": (min([n.get("start_line", 0) for n in nodes] or [0]),
                            max([n.get("end_line", 0) for n in nodes] or [0]))
            })
    
    # 获取所有需要处理的项
    all_items = []
    
    # 添加类
    if hasattr(cfg_obj, 'class_cfgs'):
        for class_name, class_cfg in cfg_obj.class_cfgs.items():
            all_items.append(('class', class_name, class_cfg))
    
    # 添加方法
    if hasattr(cfg_obj, 'methodcfgs'):
        for method_name, method_cfg in cfg_obj.methodcfgs.items():
            all_items.append(('method', method_name, method_cfg))
    
    # 添加函数
    if hasattr(cfg_obj, 'functioncfgs'):
        for func_name, func_cfg in cfg_obj.functioncfgs.items():
            all_items.append(('function', func_name, func_cfg))
    
    # 按照源代码中的顺序排序
    def get_first_line(item):
        _, _, cfg = item
        if hasattr(cfg, 'entryblock') and hasattr(cfg.entryblock, 'statements'):
            statements = cfg.entryblock.statements
            if statements and hasattr(statements[0], 'lineno'):
                return statements[0].lineno
        return float('inf')
    
    all_items.sort(key=get_first_line)
    
    # 按顺序处理所有项
    for item_type, name, sub_cfg in all_items:
        if id(sub_cfg) in processed:
            continue
        
        new_prefix = f"{prefix}.{name}" if prefix else name
        new_context = {"in_class": item_type == 'class'}
        
        # 递归处理
        sub_blocks = process_cfg_recursively(
            sub_cfg,
            new_prefix,
            processed,
            new_context
        )
        blocks.extend(sub_blocks)
    
    return blocks

def parse_cfg(cfg):
    """解析CFG为结构化数据"""
    return process_cfg_recursively(cfg)

def dedent_code(code: str) -> str:
    """处理代码缩进"""
    lines = code.split('\n')
    if not lines:
        return ''
    
    # 找到最小的非空行缩进
    min_indent = float('inf')
    for line in lines:
        if line.strip():
            indent = len(line) - len(line.lstrip())
            min_indent = min(min_indent, indent)
    
    if min_indent == float('inf'):
        return code
    
    # 删除多余的缩进
    result = []
    for line in lines:
        if line.strip():
            result.append(line[min_indent:])
        else:
            result.append(line)
    
    return '\n'.join(result)

def convert_parsed_cfg_to_codeblock(cfg_blocks) -> List[CodeBlock]:
    """将解析后的CFG转换为CodeBlock结构"""
    def create_cfg_data(block) -> CFGData:
        nodes = []
        edges = []
        
        # 转换节点
        for node in block["nodes"]:
            nodes.append(CFGNode(
                id=node["id"],
                code=node["code"],
                order=node["order"],
                start_line=node.get("start_line", 0),
                end_line=node.get("end_line", 0)
            ))
        
        # 转换边
        for edge in block["edges"]:
            edges.append(CFGEdge(
                from_node=edge["from"],
                to_node=edge["to"]
            ))
        
        return CFGData(nodes=nodes, edges=edges)
    
    def get_block_code(nodes: List[dict]) -> str:
        """从节点列表中提取完整的代码"""
        sorted_nodes = sorted(nodes, key=lambda x: x["order"])
        code_parts = []
        for node in sorted_nodes:
            if node["code"]:
                code_parts.append(dedent_code(node["code"]))
        return "\n".join(code_parts)
    
    def build_block_hierarchy(blocks: List[dict]) -> List[CodeBlock]:
        """构建代码块层级结构"""
        # 按照行号排序所有块
        sorted_blocks = sorted(blocks, key=lambda x: x["line_info"][0])
        
        # 创建一个映射来存储所有块
        block_map = {}  # original_name -> CodeBlock
        
        # 第一遍：创建所有 CodeBlock 对象
        for block in sorted_blocks:
            name = block["original_name"]
            cfg_data = create_cfg_data(block)
            code = get_block_code(block["nodes"])
            start_line, end_line = block["line_info"]
            
            code_block = CodeBlock(
                decl_name=name,
                start_line=start_line,
                end_line=end_line,
                children=[],
                code=code,
                cfg=cfg_data
            )
            block_map[name] = code_block
        
        # 第二遍：构建层级关系
        result = []
        for block in sorted_blocks:
            name = block["original_name"]
            code_block = block_map[name]
            
            # 检查是否是某个类的成员
            if "." in name:
                parent_name = name.split(".")[0]
                if parent_name in block_map:
                    block_map[parent_name].children.append(code_block)
                    continue
            
            # 如果不是成员，添加到结果列表
            result.append(code_block)
        
        return result
    
    return build_block_hierarchy(cfg_blocks)

def visualize_cfg(code_blocks: List[CodeBlock], indent: str = "") -> str:
    """生成CFG的文本可视化"""
    result = ["Optimized Code Block Hierarchy:"]
    
    def visualize_block(block: CodeBlock, level: int = 0):
        """递归可视化代码块及其子块"""
        indent = "  " * level
        lines = []
        
        # 添加块名称和行号范围
        block_info = f"{indent}Block: {block.decl_name}"
        if block.start_line > 0 and block.end_line > 0:
            block_info += f" (lines {block.start_line}-{block.end_line})"
        lines.append(block_info)
        
        # 添加代码内容
        lines.append(f"{indent}Code:")
        for line in block.code.split('\n'):
            if line.strip():
                lines.append(f"{indent}  {line}")
        
        # 添加CFG信息（如果存在）
        if block.cfg:
            lines.append(f"{indent}CFG Nodes: {len(block.cfg.nodes)}")
            lines.append(f"{indent}CFG Edges: {len(block.cfg.edges)}")
            
            # 按顺序显示节点
            lines.append(f"{indent}Nodes (in order):")
            sorted_nodes = sorted(block.cfg.nodes, key=lambda x: x.order)
            for node in sorted_nodes:
                lines.append(f"{indent}  Node {node.id} (order {node.order})")
            
            # 显示边
            lines.append(f"{indent}Edges:")
            for edge in block.cfg.edges:
                lines.append(f"{indent}  {edge.from_node} -> {edge.to_node}")
        
        # 递归处理子块
        if block.children:
            lines.append(f"{indent}Children:")
            for child in block.children:
                lines.extend(visualize_block(child, level + 1))
        
        lines.append("")  # 添加空行分隔不同的块
        return lines
    
    # 处理所有顶层块
    for block in code_blocks:
        result.extend(visualize_block(block))
    
    return '\n'.join(result)

if __name__ == "__main__":
    for file in os.listdir("llm_cfg"):
        if file.endswith(".json"):
            with open(f"llm_cfg/{file}", 'r', encoding='utf-8') as f:
                llm_cfg = json.load(f)
                llm_blocks = parse_and_optimize_json_to_cfg(llm_cfg)

            file_path = f"source_code/{file.split('.')[0]}.py"
            src = open(file_path, 'r', encoding='utf-8').read()
            cfg = CFGBuilder().build_from_src(file.split('.')[0], src)
            parsed_cfg = parse_cfg(cfg)
            static_blocks = convert_parsed_cfg_to_codeblock(parsed_cfg)
            
            llm_blocks_with_calls = convert_to_blocks_with_calls(llm_blocks)
            static_blocks_with_calls = convert_to_blocks_with_calls(static_blocks)

            # 进行匹配
            matcher = TopologicalBlockMatcher()
            result = matcher.match_blocks(llm_blocks_with_calls, static_blocks_with_calls)
            print_match_results(result)


