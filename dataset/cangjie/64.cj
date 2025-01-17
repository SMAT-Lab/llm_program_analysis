macro package opds_cj.macros

import std.ast.*
import std.fs.*
import std.io.*
import std.regex.*
import std.collection.HashMap

let typeMap = HashMap<String, TokenKind>(
    [
        ("void", TokenKind.UNIT),
        ("bool", TokenKind.BOOLEAN),
        ("char", TokenKind.UINT8),
        ("int8_t", TokenKind.UINT8),
        ("uint8_t", TokenKind.UINT8),
        ("int16_t", TokenKind.INT16),
        ("uint16_t", TokenKind.UINT16),
        ("int32_t", TokenKind.INT32),
        ("uint32_t", TokenKind.UINT32),
        ("int64_t", TokenKind.INT64),
        ("uint64_t", TokenKind.UINT64),
        ("ssize_t", TokenKind.INTNATIVE),
        ("size_t", TokenKind.UINTNATIVE),
        ("float", TokenKind.FLOAT32),
        ("double", TokenKind.FLOAT64), //以上为通用映射表
        ("int", TokenKind.INT32), //根据平台变化
        ("sqlite3_int64", TokenKind.INT64) //以上为当前项目特殊映射
    ]
)

func parseType(oriType: String, pointerCount: String): Tokens {
    if (oriType == "char" && pointerCount.count("*") == 1) {
        return Tokens() + Token(TokenKind.IDENTIFIER, "CString") //返回CString
    }
    var outType = Tokens()
    if (typeMap.contains(oriType)) {
        outType += Token(typeMap[oriType])
    } else {
        outType += Token(TokenKind.UNIT)
    }
    for (_ in 0..pointerCount.count("*")) {
        outType = quote(CPointer<$(outType)>)
    }
    return outType
}

func parseDotH(dotH: String): Tokens {
    var outTokens = Tokens()
    let file = File(dotH, Read)
    let reader = StringReader(file)
    var content = reader.readToEnd() //StringReader的分段读取未解决，暂时直接全部读完
    let commentRegex = Regex(##"/\*.*\*/|//.*(\n|\r)|\*/|/\*|\*{2}\s.*(\n|\r)"##) //移除注释
    content = commentRegex
        .matcher(content)
        .replaceAll("")
        .replace("void(*)(void*)", "void*")
        .replace("int (*callback)(void*,int,char**,char**)", "void *")
    let funcRegex = Regex(##"\w+\s+\**\w+\s*\([^)]*\)\s*;"##) //获得函数定义的匹配
    let funcArr = funcRegex.matcher(content).findAll() ?? Array<MatchData>()
    for (i in funcArr) {
        var funcDefine = i.matchStr()
        let funcDefineArray = funcDefine.split("(")
        let funcPrefix = funcDefineArray[0].split(" ")
        var funcReturn = Tokens()
        if (typeMap.contains(funcPrefix[0])) {
            funcReturn += Token(typeMap[funcPrefix[0]])
        }else{
            funcReturn += Token(TokenKind.UNIT)
        }
        var funcName = funcPrefix[1]
        if (funcName.contains("*")) { //判断是否可能为字符串
            funcName = funcName.replace("*", "")
            if (funcPrefix[0] == "char") {
                funcReturn = quote(CString)
            } else {
                funcReturn = quote(CPointer<Byte>)
            }
        }
        let paramListStr = funcDefineArray[1]
        let paramRegex = Regex(##"(\w+\s*\**|\w+\s+\**\w+|\.{3})(\s*,|\s*\))"##) //匹配到参数列表
        let paramMatchList = paramRegex.matcher(paramListStr).findAll() ?? Array<MatchData>()
        let paramList = Array<String>(paramMatchList.size,
            {i => Regex(##"\s*,|\s*\)|\n|\r"##).matcher(paramMatchList[i].matchStr()).replace("")}) //移除特殊字符并存入数组
        var paramsToken = Tokens()
        for (i in 0..paramList.size) {
            println("${funcName}\n${paramList}\n${"void" == paramList[i]}")
            if (let Some(_) <- Regex(##"\w+\s+\**\w+"##).matches(paramList[i])) { //处理诸如int n的函数参数
                let paramSplit = paramList[i].split(" ")
                let type_u = paramSplit[0].replace("*", "")
                let paramToken = Token(TokenKind.IDENTIFIER, paramSplit[1].replace("*", "").replace("type","type${i}"))
                let typeToken = parseType(type_u, paramList[i])
                paramsToken += quote($(paramToken): $(typeToken))
            } else if ("void" == paramList[i]) { //处理诸如void的函数参数
                continue
            } else if (let Some(_) <- Regex(##"\w+\s*\**"##).matches(paramList[i])) { // 处理诸如int*的函数参数
                let type_u = paramList[i].replace("*", "")
                let paramToken = Token(TokenKind.IDENTIFIER, "param${i}")
                let typeToken = parseType(type_u, paramList[i])
                paramsToken += quote($(paramToken): $(typeToken))
            } else if (let Some(_) <- Regex(##"\.{3}|va_list"##).matches(paramList[i])) { //处理诸如...的函数参数
                paramsToken += Token(TokenKind.ELLIPSIS)
            } else {
                println("unknown param:${paramList[i]}")
            }
            if (i != paramList.size - 1) {
                paramsToken += Token(TokenKind.COMMA)
            }
        }
        let nameToken = Token(TokenKind.IDENTIFIER, funcName)
        outTokens += quote(foreign func $(nameToken)($(paramsToken)): $(funcReturn)
        )
    }
    file.close()
    outTokens
}

public macro include(input: Tokens): Tokens {
    parseDotH(input.toString().replace('"', ""))
}
