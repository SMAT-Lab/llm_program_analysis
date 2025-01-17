package markdown.core
class NodeIterator <: Iterator<Node> {
    public NodeIterator(var current: ?Node, let justLeaf: Bool) {}
    public func next(): ?Node {
        let n: ?Node = current
        current = match (current?.getNext()) {
            case Some(Some(v: Node)) where justLeaf && v.isLeafNode() => v
            case Some(Some(v: Node)) where !justLeaf => v
            case _ => None
        }
        return n
    }
}
public interface NodeExt {
    func getListChildren(): ArrayList<Node>
    func iterateChildren(): Iterator<Node>
    func listChildren(): ArrayList<Node>
    func hasOnlyChild(): Bool
    func hasMultiChild(): Bool
    func hasChild(): Bool
    func isBlockNode(): Bool
    func isContentNode(): Bool
    func hasEmphasis(): Bool
    func hasStrongEmphasis(): Bool
    func listItemDepth(): Int
    func listItemIndex(): Int
    func flat(): Unit
    func getView(): NodeView
    func toViewString(): String
    func iterateLeafChildren(): Iterator<Node>
    func isLeafNode(): Bool
    func replaceWith(node: Node): Unit
}
extend Node <: NodeExt {
    public func getListChildren(): ArrayList<Node> {
        let list: ArrayList<Node> = ArrayList<Node>()
        var node: ?Node = getFirstChild()
        while (!node.isNone()) {
            list.append(node.getOrThrow())
            node = node.getOrThrow().getNext()
        }
        return list
    }
    public func iterateChildren(): Iterator<Node> {
        return NodeIterator(getFirstChild(), false)
    }
    public func listChildren(): ArrayList<Node> {
        return iterateChildren() |> collectArrayList
    }
    public func hasOnlyChild(): Bool {
        return getFirstChild() == getLastChild()
    }
    public func hasMultiChild(): Bool {
        return getFirstChild() != getLastChild()
    }
    public func hasChild(): Bool {
        return getFirstChild().isSome()
    }
    public func isBlockNode(): Bool {
        return this is Block
    }
    public func isContentNode(): Bool {
        throw Exception("TODO")
    }
    public func hasEmphasis(): Bool {
        var n: ?Node = this
        while (let Some(v) <- n) {
            if (v is Emphasis) {
                return true
            }
            n = v.getParent()
        }
        return false
    }
    public func hasStrongEmphasis(): Bool {
        var n: ?Node = this
        while (let Some(v) <- n) {
            if (v is StrongEmphasis) {
                return true
            }
            n = v.getParent()
        }
        return false
    }
    public func listItemDepth(): Int {
        var n: ?Node = this
        var depth: Int = 0
        while (let Some(v) <- n) {
            if (v is ListItem) {
                depth++
            }
            n = v.getParent()
        }
        return depth
    }
    public func listItemIndex(): Int {
        var n: ?Node = this
        var index: Int = 0
        while (let Some(v) <- n) {
            if (v is ListItem) {
                index = 1
                var node: Node = v
                while (let Some(p: ListItem) <- node.getPrevious()) {
                    index++
                    node = p
                }
                return index
            }
            n = v.getParent()
        }
        return index
    }
    public func flat(): Unit {
        if (let Some(v) <- this.getNext()) {
            this.iterateChildren() |> forEach(v.insertBefore)
        } else if (let Some(v) <- this.getParent()) {
            this.iterateChildren() |> forEach(v.appendChild)
        }
        this.unlink()
    }
    public func getView(): NodeView {
        (this.custom as NodeView)()
    }
    public func toViewString(): String {
        if (custom is NodeView) {
            "${this} ${getView()}"
        } else {
            this.toString()
        }
    }
    public func iterateLeafChildren(): Iterator<Node> {
        return NodeIterator(getFirstChild(), true)
    }
    public func isLeafNode(): Bool {
        if (this is Block) {
            return false
        }
        return (this is Text || this is Code || this is Image || this is HardLineBreak || this is SoftLineBreak)
    }
    public func replaceWith(node: Node): Unit {
        for (v in this.iterateChildren()) {
            node.appendChild(v)
        }
        this.insertBefore(node)
        this.unlink()
        // keep one way relation from this
        this.setParent(node.getParent())
        this.setPrevious(node.getPrevious())
        this.setNext(node.getNext())
        this.setFirstChild(node.getFirstChild())
        this.setLastChild(node.getLastChild())
    }
}
public interface ListNode {}
extend BlockQuote <: ListNode {}
extend BulletList <: ListNode {}
extend OrderedList <: ListNode {}