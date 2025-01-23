macro package cj_easy_data.macros

import std.ast.*
import std.collection.*

//支持一次添加ToString和默认None
public macro Data(input: Tokens): Tokens {
    var classDecl =getClassDecl(input)
    let handler = addToString ~> addDefaultNones
    classDecl = handler(classDecl)
    return classDecl.toTokens()
}

func isFunc(token: Token): Bool {
    return token.kind==FUNC;
}
func getClassDecl(input: Tokens):ClassDecl{
    let varDecl = parseDecl(input)
   return (varDecl as ClassDecl).getOrThrow()
}