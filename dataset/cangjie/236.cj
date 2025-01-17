package utils
from std import ast.*
from std import collection.*
from std import collection.concurrent.*
public class TokensManager {
    let tokens: TokensIterator
    let tokenArrayList: ArrayList<Token>
    public init(tokens: Tokens) {
        this.tokens = tokens.iterator()
        this.tokenArrayList = ArrayList()
    }
    public func insert(findKind: TokenKind, insertTokens: Tokens) {
        for (token in tokens) {
            if (findKind == token.kind) {
                tokenArrayList.append(token)
                for (insertToken in insertTokens) {
                    tokenArrayList.append(insertToken)
                }
                return
            } else {
                tokenArrayList.append(token)
            }
        }
    }
    public func append(appendTokens: Tokens) {
        for (token in appendTokens) {
            tokenArrayList.append(token)
        }
    }
    public func next(kind: TokenKind) {
        for (token in tokens) {
            if (kind == token.kind) {
                tokenArrayList.append(token)
                return
            } else {
                tokenArrayList.append(token)
            }
        }
    }
    public func getCurrentToken() {
        tokenArrayList[tokenArrayList.size - 1]
    }
    public func build() {
        for (token in tokens) {
            tokenArrayList.append(token)
        }
        Tokens(tokenArrayList)
    }
}
public func idAppend(token: Token, id: String) {
    Token(TokenKind.IDENTIFIER, "${token.value}${id}")
}