from concurrent.futures import ThreadPoolExecutor, wait
import os
import requests
from github import Github

# GitHub API Token (可以去 GitHub 上获取 Personal Access Token)
GITHUB_TOKEN = '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'
GITHUB_API_URL = 'https://api.github.com/search/repositories'
GITHUB_REPO_API_URL = 'https://api.github.com/repos/'
g = Github(GITHUB_TOKEN)

# 设置保存 .py 文件的目录
SAVE_DIR = "data"

# 创建 data 目录，如果不存在的话
if not os.path.exists(SAVE_DIR):
    os.makedirs(SAVE_DIR)

# 获取高 star 的 Python 仓库
def get_top_python_repos():
    repos = g.search_repositories(query="language:Python", sort="stars", order="desc")
    return repos[3:5]  # 获取前5个高 star 的 Python 仓库

# 下载指定仓库中的 .py 文件
def download_py_files(repo):
    print(f"Downloading from repository: {repo.name}")
    contents = repo.get_contents("")
    for content_file in contents:
        if content_file.type == "file" and content_file.name.endswith(".py"):
            file_url = content_file.download_url
            response = requests.get(file_url)
            file_path = os.path.join(SAVE_DIR, content_file.name)
            
            with open(file_path, "wb") as f:
                f.write(response.content)
            print(f"Downloaded: {content_file.name}")
        elif content_file.type == "dir":
            # 如果是文件夹，递归下载
            download_py_files_from_directory(repo, content_file.path)

def download_py_files_from_directory(repo, path):
    contents = repo.get_contents(path)
    for content_file in contents:
        if content_file.type == "file" and content_file.name.endswith(".py"):
            file_url = content_file.download_url
            response = requests.get(file_url)
            file_path = os.path.join(SAVE_DIR, content_file.name)
            
            with open(file_path, "wb") as f:
                f.write(response.content)
            print(f"Downloaded: {content_file.name}")
        elif content_file.type == "dir":
            download_py_files_from_directory(repo, content_file.path)

def main():
    # 获取高 star 的 Python 仓库
    repos = get_top_python_repos()
    
    # 创建线程池
    with ThreadPoolExecutor(max_workers=4) as executor:
        # 并行下载每个仓库中的 .py 文件
        futures = [executor.submit(download_py_files, repo) for repo in repos]
        # 等待所有下载任务完成
        wait(futures)

if __name__ == "__main__":
    main()
