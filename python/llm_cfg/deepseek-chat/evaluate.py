# 读取CSV文件
from matplotlib import pyplot as plt
import pandas as pd
# 获取最新的similarity_results文件
import glob
import os

csv_files = glob.glob('*_similarity_results.csv')

# 读取所有CSV文件
dfs = []
for csv_file in sorted(csv_files):  # 只取前三个文件
    df = pd.read_csv(csv_file)
    
    # 检查必要的列是否存在
    required_columns = ['Index', 'Static Similarity', 'Original Code', 'Generated Code']
    missing_columns = [col for col in required_columns if col not in df.columns]
    if missing_columns:
        raise ValueError(f"CSV文件 {csv_file} 缺少以下必要列: {missing_columns}")
        
    # 按index排序
    df = df.sort_values('Index')
    dfs.append(df)

print(csv_files)

# 提取每个文件的相似度数据
def extract_static_score(x):
    try:
        if isinstance(x, str):
            return float(eval(x)['final_score'])
        return float(x)
    except:
        return 0.0

all_similarities = []
for i, df in enumerate(dfs):
    static_similarities = df['Static Similarity'].apply(extract_static_score)
    all_similarities.append(static_similarities)

# 获取所有样本的索引
all_indices = set()
for df in dfs:
    all_indices.update(df['Index'].values)
all_indices = sorted(list(all_indices))

# 比较每个样本的相似度
print("各文件相似度对比:")
print("样本ID\t\t静态相似度")
print("-" * 60)
for idx in all_indices:
    static_scores = []
    for i, df in enumerate(dfs):
        if idx in df['Index'].values:
            row = df[df['Index'] == idx]
            static_scores.append(float(all_similarities[i][row.index[0]]))
        else:
            static_scores.append(0.0)
    
    # 检查是否有数据再获取代码行数
    code_lines = 0
    for df in dfs:
        if idx in df['Index'].values:
            code = df[df['Index'] == idx]['Original Code'].values[0]
            code_lines = len(code.split('\n'))
            break
            
    print(f"样本 {idx}")
    print(f"代码行数: {code_lines}")
    print(f"静态相似度: {static_scores}")
    print("-" * 60)

print(sorted(csv_files))

# 按代码行数分组计算平均相似度
print("\n按代码行数分组的平均相似度:")
print("-" * 60)

line_groups = {
    "0-50行": (0, 50),
    "50-100行": (50, 100),
    "100-200行": (100, 200), 
    "200-300行": (200, 300),
    ">300行": (300, float('inf'))
}

for group_name, (min_lines, max_lines) in line_groups.items():
    print(f"\n{group_name}代码:")
    
    # 先获取dfs[0]中该行数范围的样本数作为分母
    code_lines_base = dfs[0]['Original Code'].apply(lambda x: len(x.split('\n')))
    group_mask_base = (code_lines_base >= min_lines) & (code_lines_base < max_lines)
    base_sample_count = len(code_lines_base[group_mask_base])
    
    for i, csv_file in enumerate(sorted(csv_files)):
        print(f"\n{csv_file}:")
        static_scores = all_similarities[i]
        
        # 获取当前文件的代码行数
        code_lines = dfs[i]['Original Code'].apply(lambda x: len(x.split('\n')))
        
        # 获取该行数范围内的分数
        group_mask = (code_lines >= min_lines) & (code_lines < max_lines)
        group_static = static_scores[group_mask]
        
        if base_sample_count > 0:
            avg_static = sum(s for s in group_static if s >= 0) / base_sample_count
            
            print(f"样本数: {len(group_static)}")
            print(f"平均静态相似度: {avg_static:.2f}")
    print("-" * 60)