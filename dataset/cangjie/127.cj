package csv4cj
public class CSVOutFormat {
    // Header title
    private var header: Array<String>
    // array of header column names
    private var headerComments: Array<String>
    // Annotation symbols
    private var commentMarker: Rune
    // Separator
    private var delimiter: String
    // Separator
    private var delimiterRune: Array<Rune>
    // Escape character
    private var escapeCharacter: Rune
    // Reference symbol
    private var quoteCharacter: Rune
    // Record split string
    private var recordSeparator: String
    // Ignore records without values
    private var ignoreEmptyRecord: Bool
    // Whether to remove white space characters outside the content
    private var trim: Bool
    // Add column ordinal for reference symbol
    private var quotedColsIndex: Array<Int64>
    // Reference mode of output content
    private var quoteMode: QuoteMode
    public static prop DEFAULT: CSVOutFormat {
        get() {
            CSVOutFormat(
                Constants.COMMA_STRING,
                Constants.DOUBLE_QUOTE_CHAR,
                QuoteMode.SpecialValue,
                [],
                Constants.COMMENT_CHAR,
                Constants.BACKSLASH,
                true,
                true,
                Constants.CRLF,
                [],
                []
            )
        }
    }
    CSVOutFormat(
        delimiter: String,
        quoteChar: Rune,
        quoteMode: QuoteMode,
        quotedColsIndex: Array<Int64>,
        commentStart: Rune,
        escape: Rune,
        trim: Bool,
        ignoreEmptyRecord: Bool,
        recordSeparator: String,
        header: Array<String>,
        headerComments: Array<String>
    ) {
        this.delimiter = delimiter
        this.delimiterRune = delimiter.toRuneArray()
        this.quoteCharacter = quoteChar
        this.quoteMode = quoteMode
        this.quotedColsIndex = quotedColsIndex
        this.trim = trim
        this.ignoreEmptyRecord = ignoreEmptyRecord
        this.recordSeparator = recordSeparator
        this.commentMarker = commentStart
        this.escapeCharacter = escape
        this.header = header
        this.headerComments = headerComments
    }
    public func setEscapeCharacter(escapeCharacter: Rune) {
        this.escapeCharacter = escapeCharacter
        return this
    }
    public func getEscapeCharacter(): Rune {
        return escapeCharacter
    }
    public func setHeader(headerList: Array<String>) {
        this.header = headerList
        return this
    }
    public func getHeader() {
        return header
    }
    public func setIgnoreEmptyRecord(ignoreEmptyRecord: Bool) {
        this.ignoreEmptyRecord = ignoreEmptyRecord
        return this
    }
    public func getIgnoreEmptyRecord(): Bool {
        return ignoreEmptyRecord
    }
    public func setTrim(trim: Bool) {
        this.trim = trim
        return this
    }
    public func getTrim(): Bool {
        return trim
    }
    public func setQuoteCharacter(quoteCharacter: Rune) {
        this.quoteCharacter = quoteCharacter
        return this
    }
    public func getQuoteCharacter(): Rune {
        return quoteCharacter
    }
    public func setQuoteMode(quoteMode: QuoteMode) {
        this.quoteMode = quoteMode
        return this
    }
    public func getQuoteMode(): QuoteMode {
        return quoteMode
    }
    public func setDelimiter(outdelimiter: String) {
        this.delimiter = outdelimiter
        this.delimiterRune = outdelimiter.toRuneArray()
        return this
    }
    public func getDelimiterString(): String {
        return delimiter
    }
    public func getDelimiterRune(): Array<Rune> {
        return delimiterRune
    }
    public func setCommentMarker(outcommentMarker: Rune) {
        this.commentMarker = outcommentMarker
        return this
    }
    public func getCommentMarker(): Rune {
        return commentMarker
    }
    public func getRecordSeparator() {
        return recordSeparator
    }
    public func setQuotedColsIndex(quotedColsIndex: Array<Int64>) {
        this.quotedColsIndex = quotedColsIndex
        return this
    }
    public func getQuotedColsIndex() {
        return quotedColsIndex
    }
}
public enum QuoteMode {
    // All columns
    All |
    // Configure the specified column
    CfgCols |
    // Column values with special characters
    SpecialValue |
    // No reference, escape if there are special symbols
    None
}