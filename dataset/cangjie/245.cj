package markdown.core
public class NodeView <: ToString {
    public var blockQuoteDepth: Int = -1
    public var blockQuote: ?BlockQuote = None
    public var emphasis: ?Emphasis = None
    public var strongEmphasis: ?StrongEmphasis = None
    public var link: ?Link = None
    public var bulletList: ?BulletList = None
    public var depth: Int = -1
    public var order: Int = -1
    public var orderedList: ?OrderedList = None
    public var bulletListDepth: Int = -1
    public var listMark: Bool = false
    // 本身Node节点
    public let node: Node
    // Node节点开始结束标志 -1:无效 0:开始 1:结束
    var startend = -1
    // 是否为Node开始
    public prop isNodeStart: Bool {
        get() {
            startend == 0
        }
    }
    // 是否为Node结束
    public prop isNodeEnd: Bool {
        get() {
            startend == 1
        }
    }
    // 子节点列表
    public let children: ArrayList<NodeView> = ArrayList<NodeView>()
    // NodeViewTree中的上级NodeView
    public var collector: ?NodeView = None
    // 供插件使用的自定义属性
    public var props: ?HashMap<String, Any> = None
    // 所有上级列表节点 用于ListItem中第一个Block前的列表符号绘制
    public var list: ArrayList<NodeView> = EMPTY_LIST
    private static let EMPTY_LIST = ArrayList<NodeView>()
    public init(currentNode: Node) {
        this.node = currentNode
        setView(currentNode)
    }
    public init(currentNode: Node, parentView: NodeView) {
        this.node = currentNode
        mergeView(parentView)
        setView(currentNode)
        setListItemFirstChild(currentNode, parentView)
    }
    func mergeView(parentView: NodeView) {
        this.link = parentView.link
        this.emphasis = parentView.emphasis
        this.strongEmphasis = parentView.strongEmphasis
        this.blockQuote = parentView.blockQuote
        this.blockQuoteDepth = parentView.blockQuoteDepth
        this.bulletList = parentView.bulletList
        this.bulletListDepth = parentView.bulletListDepth
        this.depth = parentView.depth
        this.order = parentView.order
        this.orderedList = parentView.orderedList
        this.collector = parentView.collector
        if (let Some(v) <- parentView.props) {
            this.props = v.clone()
        }
    }
    func setView(currentNode: Node) {
        if (currentNode is BlockQuote) {
            this.blockQuoteDepth++
            this.blockQuote = currentNode as BlockQuote
        } else if (currentNode is Emphasis) {
            this.emphasis = currentNode as Emphasis
        } else if (currentNode is StrongEmphasis) {
            this.strongEmphasis = currentNode as StrongEmphasis
        } else if (currentNode is Link) {
            this.link = currentNode as Link
        } else if (currentNode is BulletList) {
            this.bulletListDepth++
            this.bulletList = currentNode as BulletList
        } else if (currentNode is OrderedList) {
            this.depth++
            this.orderedList = currentNode as OrderedList
        } else if (currentNode is ListItem) {
            if (let Some(parent) <- this.orderedList) {
                this.order = if (let Some(previous) <- currentNode.getPrevious()?.getView()) {
                    previous.order + 1
                } else {
                    parent.getStartNumber()
                }
            }
        }
    }
    func setListItemFirstChild(currentNode: Node, parentView: NodeView): Unit {
        if (currentNode.getPrevious().isSome()) {
            return
        }
        let parent = parentView.node
        if (!(parent is ListItem || parent is BlockQuote)) {
            return
        }
        if (currentNode is BlockQuote || currentNode is OrderedList || currentNode is BulletList) {
            return
        }
        this.list = ArrayList<NodeView>()
        var tmp: ?Node = parent
        let end = this.collector().node
        while (let Some(n) <- tmp) {
            let isListNode = n is BlockQuote || n is OrderedList || n is BulletList
            if (isListNode && (list.size == 0 || n.getNodeType() != list[0].node.getNodeType())) {
                list.prepend(n.getView())
            }
            if (n == end) {
                break
            }
            tmp = n.getParent()
        }
    }
    private func isListNode(n: Node): Bool {
        n is BlockQuote || n is OrderedList || n is BulletList
    }
    public override func toString(): String {
        let emphaStr = emphasis?.toString() ?? ""
        let strongStr = strongEmphasis?.toString() ?? ""
        let linkStr = link?.toString() ?? ""
        let bulletStr = if (let Some(v) <- bulletList) {
            "{${v},bulletListDepth:${bulletListDepth}}"
        } else {
            ""
        }
        let orderListStr = if (let Some(v) <- orderedList) {
            "{${v},depth:${depth},order:${order}}"
        } else {
            ""
        }
        let blockQuoteStr = if (let Some(v) <- blockQuote) {
            "{blockQuote:${v},blockQuoteDepth:${blockQuoteDepth}}"
        } else {
            ""
        }
        let propStr = if (let Some(kvs) <- props) {
            let str = kvs |> map<(String, Any), String> {kv => "${kv[0]}:${kv[1] as ToString}"} |>
                collectString<String>(delimiter: ",")
            "{${str}}"
        } else {
            ""
        }
        let startEndStr = if (startend > -1) {
            "{isNodeStart:${isNodeStart},isNodeEnd:${isNodeEnd}}"
        } else {
            ""
        }
        let listStr = if (list.size > 0) {
            list.toString()
        } else {
            ""
        }
        return "view:{${node}${startEndStr}${emphaStr}${strongStr}${linkStr}${bulletStr}${orderListStr}${blockQuoteStr}${propStr}${listStr}}"
    }
}
public func buildView(node: Node, needCollect: Bool, needProps!: Bool = false): NodeView {
    if (let Some(v) <- (node.custom as NodeView)) {
        return v
    }
    let view = if (let Some(parentView: NodeView) <- node.getParent()?.custom) {
        NodeView(node, parentView)
    } else {
        NodeView(node)
    }
    if (needProps && view.props.isNone()) {
        view.props = HashMap<String, Any>()
    }
    if (needCollect) {
        view.collector?.children.append(view)
        view.collector = view
    }
    node.custom = view
    return view
}
public func buildFlatView(node: Node, nodeVisitor: (Node) -> Unit, needProps!: Bool = false): Unit {
    let (start, end) = if (let Some(parentView: NodeView) <- node.getParent()?.custom) {
        if (parentView.node is Document) {
            let list = NodeView(node, parentView)
            list.depth = -1
            list.bulletListDepth = -1
            list.blockQuoteDepth = -1
            list.collector?.children.append(list)
            list.collector = list
            (NodeView(node, list), NodeView(node, list))
        } else {
            (NodeView(node, parentView), NodeView(node, parentView))
        }
    } else {
        (NodeView(node), NodeView(node))
    }
    start.startend = 0
    if (needProps && start.props.isNone()) {
        start.props = HashMap<String, Any>()
    }
    node.custom = start
    start.collector?.children.append(start)
    nodeVisitor(node)
    end.startend = 1
    start.collector?.children.append(end)
}
public func buildListView(node: Node, needProps!: Bool = false): NodeView {
    if (let Some(_: Document) <- node.getParent()) {
        buildView(node, true, needProps: needProps)
    } else {
        buildView(node, false, needProps: needProps)
    }
}