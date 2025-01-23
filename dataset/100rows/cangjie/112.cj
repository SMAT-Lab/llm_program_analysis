// 基于 struct 实现二叉树
// cjc version: 0.53.13
struct Node {
    public Node(var value: Rune,
        let left!: ?Node = None,
        let right!: ?Node = None) {}

    public func traverse(): Unit {
        left?.traverse()
        print(value)
        right?.traverse()
    }
}

main() {
    var tree = Node(r'A',
        left: Node(r'B', left: Node(r'C', right: Node(r'D'))),
        right: Node(r'E', left: Node(r'F'), right: Node(r'G')))
    tree.traverse()
}
