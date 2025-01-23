macro package opds_cj.macros

import std.ast.*
import std.collection.ArrayList

class VarVisitor <: Visitor {
    public var varList = ArrayList<VarDecl>()
    public override func visit(varDecl: VarDecl) {
        varList.append(varDecl)
        breakTraverse() // 不会继续遍历 varDecl 的子节点
        return
    }

    public override func visit(_: FuncDecl) { //阻止在func函数下查找变量
        breakTraverse()
        return
    }
}

func newField(varDecl: VarDecl): Tokens {
    let name = varDecl.identifier
    // let type_u = varDecl.declType
    quote(
        w.writeName($(name.value)).writeValue($(name)))
}

func newToString(varList: ArrayList<VarDecl>): Tokens {
    var newToken = Tokens()
    for (i in varList) {
        newToken += newField(i)
    }
    quote(
        extend Series {
            public func toJson(): String {
                let stream = ByteBuffer()
                let w = JsonWriter(stream)
                w.startObject()
                $(newToken)
                w.endObject()
                w.flush()
                return String.fromUtf8(readToEnd(stream))
            }
        }
    )
}

public macro Json(input: Tokens): Tokens {
    let s: Decl = parseDecl(input)
    var toString: Tokens
    var visitor = VarVisitor()
    match (s) {
        case d: ClassDecl =>
            d.traverse(visitor)
            toString = newToString(visitor.varList)
        case _ => throw Exception("Json only using for Class")
    }
    input + toString
}
