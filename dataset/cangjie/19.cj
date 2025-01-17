macro package cj_easy_data.macros

import std.ast.*
import std.collection.*

public macro InitNone(input: Tokens):Tokens{
    var clazz= getClassDecl(input)
    return addDefaultNones(clazz).toTokens()
}


func addDefaultNones(classDecl: ClassDecl): ClassDecl {
    classDecl.body.decls = classDecl.body.decls |> map(addDefaultNone) |> collectArrayList
    return classDecl
}
//给加了问号的参数自动添加None
func addDefaultNone(decl: Decl): Decl {
    if (isFunc(decl.keyword)) {
        return decl
    }
    match (decl) {
        case m: MacroExpandDecl =>
            let vd = (m.macroInputDecl as VarDecl).getOrThrow()
            vd.expr = parseExpr(quote(None))
            vd.assign = Token(ASSIGN, '=')
        case v: VarDecl =>
            v.expr = parseExpr(quote(None))
            v.assign = Token(ASSIGN, '=')
        case _ => decl
    }
    return decl
}


