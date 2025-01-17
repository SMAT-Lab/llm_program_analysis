macro package libclang.clangmacro
from std import ast.*
from std import collection.*
class CEnumTransformer {
    let enumConstType: TypeNode
    let rawConsts: ArrayList<Decl>
    CEnumTransformer(let classDecl: ClassDecl) {
        rawConsts = classDecl.body.decls
        if (rawConsts.isEmpty()) {
            throw IllegalStateException("Empty enum ${classDecl.identifier.value}")
        }
        let firstConst = rawConsts[0] as VarDecl ?? throw IllegalStateException("Expected const int decls as body of class!")
        enumConstType = firstConst.declType
        rawConsts |>
            forEach<Decl> {
            decl =>
            let cnst = decl as VarDecl ?? throw IllegalStateException("Expected const int decls as body of class!")
            if (!compareTokens(enumConstType.toTokens(), cnst.declType.toTokens())) {
                throw IllegalStateException("Consts must be the same integer type!")
            }
        }
    }
    prop emptyEnumTokens: Tokens {
        get() {
            quote(
                public enum $(classDecl.identifier) <: ToString { TOREMOVE }
            )
         }
    }
    func generate(): Tokens {
        buildEnum()
    }
    private func buildEnum() {
        let enumDecl = EnumDecl(emptyEnumTokens)
        enumDecl.constructors.clear()
        let ordinalMatch = MatchExpr(quote(match (this) { case _ => () }))
        ordinalMatch.matchCases.clear()
        let fromOrdinalMatch = MatchExpr(quote(match (ordinal) { case _ => () }))
        fromOrdinalMatch.matchCases.clear()
        let toStringMatch = MatchExpr(quote(match (this) { case _ => () }))
        toStringMatch.matchCases.clear()
        rawConsts |> forEach<Decl> { it =>
            let cnst = it as VarDecl ?? throw IllegalStateException()
            enumDecl.constructors.append(buildConstructor(cnst))
            ordinalMatch.matchCases.append(buildOrdinalMatchCase(cnst))
            fromOrdinalMatch.matchCases.append(buildFromOrdinalMatchCase(cnst))
            toStringMatch.matchCases.append(buildToStringMatchCase(cnst))
        }
        fromOrdinalMatch.matchCases.append(buildFromOrdinalInvalidMatchCase())
        enumDecl.decls.append(parseDecl(quote(
            public prop ordinal: $(enumConstType) {
                get() {
                    $ordinalMatch
                }
            }
        )))
        enumDecl.decls.append(parseDecl(quote(
            public static func fromOrdinal(ordinal: $(enumConstType)): $(classDecl.identifier) {
                $fromOrdinalMatch
            }
        )))
        enumDecl.decls.append(parseDecl(quote(
            public override func toString(): String {
                $toStringMatch
            }
        )))
        enumDecl.toTokens()
    }
    private func buildConstructor(cnst: VarDecl) {
        let ctor = Constructor()
        ctor.identifier = cnst.identifier
        ctor
    }
    private func buildOrdinalMatchCase(cnst: VarDecl) {
        let mcase = MatchCase()
        mcase.expr = parseExpr(Tokens(cnst.identifier))
        mcase.arrow = Token(DOUBLE_ARROW)
        let block = Block()
        block.nodes.append(cnst.expr)
        mcase.block = block
        mcase
    }
    private func buildFromOrdinalMatchCase(cnst: VarDecl) {
        let mcase = MatchCase()
        mcase.expr = cnst.expr
        mcase.arrow = Token(DOUBLE_ARROW)
        let block = Block()
        block.nodes.append(parseExpr(Tokens(cnst.identifier)))
        mcase.block = block
        mcase
    }
    private func buildFromOrdinalInvalidMatchCase() {
        let mcase = MatchCase()
        mcase.expr = parseExpr(quote(invalid))
        mcase.arrow = Token(DOUBLE_ARROW)
        let block = Block()
        let msg = Tokens(Token(STRING_LITERAL, "Can't create ${classDecl.identifier.value} from \${invalid}"))
        block.nodes.append(parseExpr(quote(throw IllegalArgumentException($msg))))
        mcase.block = block
        mcase
    }
    private func buildToStringMatchCase(cnst: VarDecl) {
        let mcase = MatchCase()
        mcase.expr = parseExpr(Tokens(cnst.identifier))
        mcase.arrow = Token(DOUBLE_ARROW)
        let block = Block()
        block.nodes.append(parseExpr(Tokens(Token(STRING_LITERAL, cnst.identifier.value))))
        mcase.block = block
        mcase
    }
}
public macro CEnum(tokens: Tokens) {
    let decl = ensureAbstractClass(tokens)
    CEnumTransformer(decl).generate()
}
func ensureAbstractClass(tokens: Tokens): ClassDecl {
    let decl = parseDecl(tokens) as ClassDecl ?? throw IllegalStateException("Passed decl is not class decl!")
    if (!decl.isAbstract()) {
        throw IllegalStateException("Passed class is not abstract!")
    }
    decl
}
extend ClassDecl {
    func isAbstract(): Bool {
        let modifiers = this.modifiers
        var hasAbstract = false
        for (modifier in modifiers) {
            if (modifier.keyword.kind == ABSTRACT) {
                hasAbstract = true
                break
            }
        }
        return hasAbstract
    }
}