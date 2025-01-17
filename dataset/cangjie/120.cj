// 基于函数实现二叉树，演示仓颉函数的 first class 及闭包特性
// cjc version: 0.53.13
func node(value: Rune,
    left!: () -> Unit = {=>}, right!: () -> Unit = {=>}) {
    return { =>
        left()
        print(value)
        right()
    }
}

main() {
    let tree = node(r'A',
        left: node(r'B', left: node(r'C', right: node(r'D'))),
        right: node(r'E', left: node(r'F'), right: node(r'G')))
    tree()
}
