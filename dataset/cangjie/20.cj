macro package cj_easy_data.macros

import std.ast.*
import std.collection.*

const NO_TO_STRING = "NoToString"
//加在类上
public macro ToStringClass(input: Tokens): Tokens {
    var classDecl = getClassDecl(input)
    return addToString(classDecl).toTokens()
}
//加在字段上,避免没有toString方法的类编译错误
public macro NoToString(input: Tokens): Tokens {
    //当判断外部宏不存在Data或ToStringClass注解时会报错
    if (!insideParentContext("Data") && !insideParentContext("ToStringClass")) {
            throw MacroContextException ("NoToString need Data or ToStringClass")
    }
    let decl = VarDecl(input)
    setItem(decl.identifier.value, true)
    return input
}

//添加toString方法
func addToString(clazz: ClassDecl): ClassDecl {
    let types = clazz.superTypes
    if (!isSuperToString(types)) {
        if (clazz.upperBound.value != "<:") {
            clazz.upperBound = Token(UPPERBOUND, "<:")
        }
        types.append(RefType(quote(ToString)))
    }
    if (isFuncToString(clazz)) {
        return clazz
    }
    var sb = StringBuilder()
    //接受内部宏NoToString消息
    let msg = getChildMessages(NO_TO_STRING)
    for (d in clazz.body.decls) {
        if (isFunc(d.keyword)) {
            continue;
        }
        var kind = match (d) {
            case m: MacroExpandDecl =>
                let vd = (m.macroInputDecl as VarDecl).getOrThrow()
                Some(vd.identifier.value)
            case v: VarDecl => Some(v.identifier.value)
            case _ => None<String>
        }

        if (let Some(value) <- kind) {
            let hasKey = msg |> any {m => m.hasItem(value)}
            if (!hasKey) {
                sb.append("${value}:\${${value}},")
            }
        }
    }
    let str = sb.toString().trimRight(",")
    let funDecl = FuncDecl(quote(public func toString():String{
        return $(str)
    }))
    clazz.body.decls.append(funDecl)
    return clazz
}

func isFuncToString(clazz: ClassDecl): Bool {
    return clazz.body.decls |> filter {d => isFunc(d.keyword)} |> any {
        d => d.identifier.value == "toString"
    }
}

func isSuperToString(superTypes: ArrayList<TypeNode>): Bool {
    return superTypes |>
        any {x: TypeNode => x is RefType && (x as RefType).getOrThrow().identifier.value.indexOf("ToString") != None}
}
