macro package bindings.runner.macros
from std import ast.*
from std import collection.HashMap
from std import fs.File
import bindings.common.*
import bindings.clang.parseForeignCDecls
public macro CBindings(attr: Tokens, input: Tokens): Tokens {
    let filepath = parseExpr(input).checkStringLiteral()
    if (!File.exists(filepath)) {
        throw IllegalArgumentException("File ${filepath} does not exist")
    }
    let ctx = attr.parseTranslationContext()
    parseForeignCDecls(filepath, context: ctx)
}