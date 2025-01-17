package language_base.model
public struct SyntaxHighlightResult {
    public SyntaxHighlightResult(public var tokenType: TokenType,
        public var start: UIntNative,
        public var end: UIntNative) {}
}