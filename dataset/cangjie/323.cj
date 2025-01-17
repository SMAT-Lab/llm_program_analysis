package dslkit.token_parsers
import std.collection.*
import std.ast.*
sealed interface PackratValue {}
enum LR<R> <: PackratValue {
    | Pending
    | Seeding
    | Growing(ParseResult<R>)
}
extend <R> ParseResult<R> <: PackratValue {}
extend ParseFailureException <: PackratValue {}
public struct TokenInput {
    private TokenInput(var tokens: Tokens, public var position!: Int64, var newLine!: Bool) {}
    public static func of(tokens: Tokens) {
        of(tokens, position: 0)
    }
    public static func of(tokens: Tokens, position!: Int64): TokenInput {
        var pos = position
        var newLine = false
        while (true) {
            match (tokens.tryGet(pos)?.kind) {
                case Some(kind) where kind == TokenKind.ILLEGAL || kind == TokenKind.COMMENT || kind == TokenKind.END =>
                    pos++
                case Some(kind) where kind == TokenKind.NL =>
                    pos++
                    newLine = true
                case _ => break
            }
        }
        TokenInput(tokens, position: pos, newLine: newLine)
    }
    public prop current: ?Token {
        get() {
            tokens.tryGet(position)
        }
    }
    private var packratStorage = HashMap<String, PackratValue>()
    public var suppressedError: ?ParseFailureException = None
    private func tryGrowSeed<R>(sig: String, parser: () -> ParseResult<R>, result: ParseResult<R>): ParseResult<R> {
        let cur = packratStorage.get(sig) ?? throw IllegalArgumentException()
        match (cur as LR<R>) {
            case Some(Seeding) =>
                packratStorage[sig] = Growing(result)
                var currentPosition: Int64 = match (result) {
                    case ParseSuccess(_, i) => i.position
                }
                var currentResult = result
                try {
                    while (true) {
                        let newResult = parser()
                        match (newResult) {
                            case ParseSuccess(_, i) where i.position > currentPosition =>
                                currentPosition = i.position
                            case _ => break
                        }
                        currentResult = newResult
                        packratStorage[sig] = Growing(newResult)
                    }
                    return currentResult
                } catch (ex: ParseFailureException) {
                    let ParseSuccess(r, input) = currentResult
                    var currentInput = input
                    if(let Some(err) <- currentInput.suppressedError) {
                        eprintln(err.detailedMessage())
                    }
                    currentInput.suppressedError = ex
                    return ParseSuccess(r, currentInput)
                }
            case _ => return result
        }
    }
    private func applyG<R>(sig: String, parser: () -> ParseResult<R>): ParseResult<R> {
        match (packratStorage.get(sig)) {
            case None =>
                try {
                    packratStorage[sig] = LR<R>.Pending
                    var result = parser()
                    result = tryGrowSeed(sig, parser, result)
                    packratStorage[sig] = result
                    return result
                } catch (ex: ParseFailureException) {
                    packratStorage[sig] = ex
                    throw ex
                }
            case Some(res: ParseResult<R>) =>
                return res
            case Some(ex: ParseFailureException) =>
                throw ex
            case Some(lr: LR<R>) =>
                match (lr) {
                    case Pending | Seeding =>
                        packratStorage[sig] = LR<R>.Seeding
                        throwFailure(HashSet<String>(), this)
                    case Growing(result) =>
                        return result
                }
            case _ => throw IllegalArgumentException("Logic error")
        }
    }
    public func apply<R>(sig: String, parser: Parser<R>): ParseResult<R> {
        if (sig.startsWith("cangjie.")) { pushCustomCompletion(this.position, "$CANGJIE$") }
        applyG(sig) { parser.parse(this) }
    }
    public func apply<R>(sig: String, parser: (TokenInput) -> ParseResult<R>): ParseResult<R> {
        if (sig.startsWith("cangjie.")) { pushCustomCompletion(this.position, "$CANGJIE$") }
        applyG(sig) { parser(this) }
    }
    public func applyLiteral(literal: String): ParseResult<Tokens> {
        applyG("##" + literal) {
            var input = this
            let literalRunes = literal.toRuneArray()
            var literalRuneIndex = 0
            let result = Tokens()
            pushCustomCompletion(this.position, literal)
            while (literalRuneIndex < literalRunes.size) {
                match(input.current) {
                    case Some(t) where t.kind != STRING_LITERAL
                        && t.kind != MULTILINE_STRING
                        && t.kind != MULTILINE_RAW_STRING =>
                            for (rune in t.value.runes()) {
                                if (literalRunes.get(literalRuneIndex) != Some(rune)) {
                                    throwFailure("\"${literal}\"", this)
                                }
                                literalRuneIndex++
                            }
                            result.append(t)
                            input.goNext()
                            if (literalRuneIndex >= literalRunes.size) {
                                try { pushCustomHighlighting(this.position, DslKitHighlightingKind.Keyword) } catch (ex: Exception) {}
                                return ParseSuccess(result, input)
                            }
                    case _ => throwFailure("\"${literal}\"", this)
                }
            }
            return ParseSuccess(result, input)
        }
    }
    public mut func goNext(): Unit {
        position++
        packratStorage = HashMap()
        skipIgnored()
    }
    public mut func skipIgnored(): Unit {
        while (true) {
            match (current?.kind) {
                case Some(kind) where
                     kind == COMMENT || kind == ILLEGAL || kind == END => position++
                case Some(kind) where kind == NL =>
                    position++
                    newLine = true
                case _ => break
            }
        }
    }
    public func next(): TokenInput {
        var copy = this
        copy.goNext()
        copy
    }
    public func eof(): Bool {
        if (let Some(END) <- current?.kind) {
            return true
        }
        return position >= tokens.size
    }
    public func endsInNewline(): Bool {
        return newLine
    }
    public func toTokens(): Tokens {
        Tokens(tokens |> skip<Token>(position) |> collectArray)
    }
}
public interface TokenSource {
    func toTokenInput(): TokenInput
}
extend Tokens <: TokenSource {
    public func toTokenInput(): TokenInput { TokenInput.of(this) }
}
extend <T> ArrayList<T> <: TokenSource where T <: Token {
    public func toTokenInput(): TokenInput {
        let coerce = this as ArrayList<Token> ?? throw Exception()
        TokenInput.of(Tokens(coerce))
    }
}
extend String <: TokenSource {
    public func toTokenInput(): TokenInput {
        let tokens = cangjieLex(this)
        TokenInput.of(tokens)
    }
}
extend TokenInput <: TokenSource {
    public func toTokenInput(): TokenInput { this }
}