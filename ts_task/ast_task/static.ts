import * as fs from 'fs';
import * as path from 'path';
import * as ts from 'typescript';

/**
 * 递归获取指定目录下的所有 .ts 文件路径
 * @param dirPath 需要遍历的目录路径
 * @returns 返回 .ts 文件路径数组
 */
function getAllTsFiles(dirPath: string): string[] {
  let tsFiles: string[] = [];

  const items = fs.readdirSync(dirPath, { withFileTypes: true });
  for (const item of items) {
    const itemPath = path.join(dirPath, item.name);

    if (item.isDirectory()) {
      // 递归子目录
      tsFiles = tsFiles.concat(getAllTsFiles(itemPath));
    } else {
      // 若以 .ts 结尾，则收集
      if (itemPath.endsWith('.ts')) {
        tsFiles.push(itemPath);
      }
    }
  }

  return tsFiles;
}

/**
 * 将 AST 节点转换为可序列化的 JSON 对象
 * @param node        要转换的 TypeScript AST 节点
 * @param sourceFile  对应的 SourceFile，用于获取节点文本
 * @returns 可序列化的 JSON 对象，结构为 { type, label, children }
 */
function nodeToJson(node: ts.Node, sourceFile: ts.SourceFile): any {
  const children: any[] = [];
  node.forEachChild(child => {
    children.push(nodeToJson(child, sourceFile));
  });

  return {
    type: ts.SyntaxKind[node.kind],    // 节点类型（字符串）
    label: node.getText(sourceFile),   // 节点对应源码文本
    children
  };
}

/**
 * 将指定 .ts 文件解析为 AST 并保存为 JSON 文件
 * @param filePath 要解析的 .ts 文件路径
 * @param outDir   输出目录，可根据需要自定义
 */
function parseAndSaveAst(filePath: string, outDir: string): void {
  const sourceCode = fs.readFileSync(filePath, 'utf-8');

  // 1. 生成 SourceFile
  const sourceFile = ts.createSourceFile(
    filePath,
    sourceCode,
    ts.ScriptTarget.Latest,
    /* setParentNodes */ true
  );

  // 2. 将 AST 转换成可序列化的 JSON
  const astJson = nodeToJson(sourceFile, sourceFile);

  // 3. 确定输出路径，这里将 JSON 文件放到 outDir 下，文件名与 .ts 文件名一致
  const fileName = path.basename(filePath, '.ts') + '.json';
  const outPath = path.join(outDir, fileName);

  // 如果 outDir 不存在，先创建
  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  // 4. 写入 JSON 文件
  fs.writeFileSync(outPath, JSON.stringify(astJson, null, 2), 'utf-8');
  console.log(`[OK] AST JSON saved -> ${outPath}`);
}

/**
 * 主函数：获取所有 .ts 文件 -> 解析并输出 JSON AST
 */
function main() {
  // 1. 要遍历的根目录
  const rootDir = '/home/arkanalyzer/tests/projects/ts_files';

  // 2. AST JSON 输出目录 (可自行修改)
  const outDir = path.join(__dirname, 'ast-json-output');

  // 3. 获取全部的 .ts 文件列表
  const allTsFiles = getAllTsFiles(rootDir);

  // 4. 依次处理
  for (const tsFile of allTsFiles) {
    parseAndSaveAst(tsFile, outDir);
  }
}

// 运行
main();
