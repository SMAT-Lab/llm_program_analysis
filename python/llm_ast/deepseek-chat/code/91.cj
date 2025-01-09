引入 操作系统
引入 子进程

目录 = 操作系统.路径.目录名(操作系统.路径.真实路径(__文件__))

后端目录 = "."
库目录 = "../autogpt_libs"
目标目录 = [后端目录, 库目录]

定义 运行(*命令:字符串)->无:
    打印(f">>>>> 运行 poetry run {' '.join(命令)}")
    子进程.运行(["poetry", "run"] + 列表(命令), 工作目录=目录, 检查=真)

定义 检查():
    尝试:
        运行("ruff", "check", *目标目录, "--exit-zero")
        运行("ruff", "format", "--diff", "--check", 库目录)
        运行("isort", "--diff", "--check", "--profile", "black", 后端目录)
        运行("black", "--diff", "--check", 后端目录)
        运行("pyright", *目标目录)
    捕获 子进程.调用进程错误 为 错误:
        打印("检查失败，尝试运行 `poetry run format` 来修复问题: ", 错误)
        抛出 错误

定义 格式化():
    运行("ruff", "check", "--fix", *目标目录)
    运行("ruff", "format", 库目录)
    运行("isort", "--profile", "black", 后端目录)
    运行("black", 后端目录)
    运行("pyright", *目标目录)