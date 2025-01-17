macro package CJson.jsonmacro
public macro JsonCust(attr_Tk: Tokens, input_Tk: Tokens): Tokens {
    var decl = TokenVerifier.verifyVarDecl(input_Tk, Const.JSON_NAME_MARCO_NAME)
    assertParentContext("JsonSerializable")
    setItem("prop", decl.identifier.value)
    setItem("serializer", attr_Tk.toString())
    return input_Tk
}