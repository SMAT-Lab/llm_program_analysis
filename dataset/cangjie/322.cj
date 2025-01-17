package prism4cj.prism
public abstract class GrammarUtils {
    public static func findToken(grammar: Grammar, path: String): ?Token {
        let parts: Array<String> = path.split("/")
        return findToken(grammar, parts, 0)
    }
    private static func findToken(grammar: Grammar, parts: Array<String>, index: Int64): ?Token {
        let part: String = parts[index]
        let last: Bool = index == parts.size - 1
        for (token in grammar.tokens()) {
            if (part == token.name()) {
                if (last) {
                    return token
                } else {
                    let inside: ?Grammar = findFirstInsideGrammar(token)
                    if (let Some(v) <- inside) {
                        return findToken(v, parts, index + 1)
                    } else {
                        break
                    }
                }
            }
        }
        return None
    }
    // won't work if there are multiple patterns provided for a token (each with inside grammar)
    public static func insertBeforeToken(grammar: Grammar, path: String, tokens: ArrayList<Token>): Unit {
        let parts: Array<String> = path.split("/")
        insertBeforeToken(grammar, parts, 0, tokens.toArray())
    }
    private static func insertBeforeToken(grammar: Grammar, parts: Array<String>, index: Int64, tokens: Array<Token>): Unit {
        let part: String = parts[index]
        let last: Bool = index == parts.size - 1
        let grammarTokens: ArrayList<Token> = grammar.tokens()
        var token: Token
        for (i in 0..grammarTokens.size) {
            token = grammarTokens.get(i).getOrThrow()
            if (part == token.name()) {
                // here we must decide what to do next:
                //  - it can be out found one
                //  - or we need to go deeper (c)
                if (last) {
                    // here we go, it's our token
                    insertTokensAt(i, grammarTokens, tokens)
                } else {
                    // now we must find a grammar that is inside
                    // token can have multiple patterns
                    // but as they are not identified somehow (no name or anything)
                    // we will try to find first pattern with inside grammar
                    let inside: ?Grammar = findFirstInsideGrammar(token)
                    if (let Some(v) <- inside) {
                        insertBeforeToken(v, parts, index + 1, tokens)
                    }
                }
                // break after we have found token with specified name (most likely it won't repeat itself)
                break
            }
        }
    }
    public static func findFirstInsideGrammar(token: Token): ?Grammar {
        var grammar: ?Grammar = None
        for (i in 0..token.patterns().size) {
            if (let Some(v) <- token.patterns()[i].inside()) {
                grammar = v
                break
            }
        }
        return grammar
    }
    private static func insertTokensAt(start: Int64, grammarTokens: ArrayList<Token>, tokens: Array<Token>) {
        for (i in 0..tokens.size) {
            grammarTokens.insert(start + i, tokens[i])
        }
    }
    public static func clone(grammar: Grammar): Grammar {
        return CLONER.clone(grammar)
    }
    public static func clone(token: Token): Token {
        return CLONER.clone(token)
    }
    public static func clone(pattern: Pattern): Pattern {
        return CLONER.clone(pattern)
    }
    public static func extendGrammar(grammar: Grammar, name: String, tokens: ?ArrayList<Token>): Grammar {
        // we clone the whole grammar, but override top-most tokens that are passed here
        let size: Int64 = if (let Some(v) <- tokens) {
            v.size
        } else {
            0
        }
        if (size == 0) {
            return GrammarImpl(name, clone(grammar).tokens())
        }
        let overrides: HashMap<String, Token> = HashMap<String, Token>(size)
        if (let Some(v) <- tokens) {
            for (i in 0..v.size) {
                overrides.put(v[i].name(), v[i])
            }
        }
        let origins: ArrayList<Token> = grammar.tokens()
        var out: ArrayList<Token> = ArrayList<Token>(origins.size)
        var override: ?Token
        for (i in 0..origins.size) {
            override = overrides.get(origins[i].name())
            if (let Some(v) <- override) {
                out.append(v)
            } else {
                out.append(clone(origins[i]))
            }
        }
        return GrammarImpl(name, out)
    }
    public static func extendGrammar(grammar: Grammar, name: String, filter: TokenFilter, tokens: ?ArrayList<Token>): Grammar {
        let size: Int64 = if (let Some(v) <- tokens) {
            v.size
        } else {
            0
        }
        var overrides: HashMap<String, Token>
        if (size == 0) {
            overrides = HashMap<String, Token>()
        } else {
            overrides = HashMap<String, Token>(size)
            if (let Some(v) <- tokens) {
                for (i in 0..v.size) {
                    overrides.put(v[i].name(), v[i])
                }
            }
        }
        let origins: ArrayList<Token> = grammar.tokens()
        var out: ArrayList<Token> = ArrayList<Token>(origins.size)
        var override: ?Token
        for (i in 0..origins.size) {
            // filter out undesired tokens
            if (!filter.test(origins[i])) {
                continue
            }
            override = overrides.get(origins[i].name())
            if (let Some(v) <- override) {
                out.append(v)
            } else {
                out.append(clone(origins[i]))
            }
        }
        return GrammarImpl(name, out)
    }
    public static func require(prism: Prism, name: String): Grammar {
        let requireGrammar: ?Grammar = prism.grammar(name)
        if (requireGrammar.isNone()) {
            throw IllegalStateException("Unexpected state, requested language is not found: " + name)
        }
        return requireGrammar.getOrThrow()
    }
    private GrammarUtils() {
    }
    private static let CLONER: Cloner = Cloner.create()
}
public interface TokenFilter {
    func test(token: Token): Bool
}