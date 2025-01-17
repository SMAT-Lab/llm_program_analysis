package editorkit.language_ruby.lexer
func getRubyTOKENFromStr(str: String): RUBYTOKEN {
    let rubyTypeStr: String = str
    var token: RUBYTOKEN = match (rubyTypeStr) {
        case "integer" | "float" | "i" | "ri" => RUBYTOKEN.NUMBER_LITERAL
        case "instance_variable" | "class_variable" => RUBYTOKEN.INSTANCE_VARIABLE
        case "alias" => RUBYTOKEN.ALIAS
        case "super" => RUBYTOKEN.SUPER
        case "self" => RUBYTOKEN.SELF
        case "undef" => RUBYTOKEN.UNDEF
        case "class" => RUBYTOKEN.CLASS
        case "def" => RUBYTOKEN.DEF
        case "end" => RUBYTOKEN.END
        case "module" => RUBYTOKEN.MODULE
        case "return" => RUBYTOKEN.RETURN
        case "and" => RUBYTOKEN.AND
        case "begin" | "BEGIN" => RUBYTOKEN.BEGIN
        case "break" => RUBYTOKEN.BREAK
        case "do" => RUBYTOKEN.DO
        case "ensure" => RUBYTOKEN.ENSURE
        case "for" => RUBYTOKEN.FOR
        case "in" => RUBYTOKEN.IN
        case "next" => RUBYTOKEN.NEXT
        case "not" => RUBYTOKEN.NOT
        case "or" => RUBYTOKEN.OR
        case "redo" => RUBYTOKEN.REDO
        case "rescue" => RUBYTOKEN.RESCUE
        case "retry" => RUBYTOKEN.RETRY
        case "yield" => RUBYTOKEN.YIELD
        case "until" => RUBYTOKEN.UNTIL
        case "unless" => RUBYTOKEN.UNLESS
        case "while" => RUBYTOKEN.WHILE
        case "if" => RUBYTOKEN.IF
        case "case" => RUBYTOKEN.CASE
        case "when" => RUBYTOKEN.WHEN
        case "then" => RUBYTOKEN.THEN
        case "else" => RUBYTOKEN.ELSE
        case "elsif" => RUBYTOKEN.ELSIF
        case "end" | "END" => RUBYTOKEN.END
        case "until" => RUBYTOKEN.UNTIL
        case "constant" => RUBYTOKEN.CONSTANT
        case "abort" |
           "catch" |
           "chomp" |
           "chop" |
           "eval" |
           "exec" |
           "exit" |
           "fail" |
           "fork" |
           "format" |
           "gets" |
           "gsub" |
           "Integer" |
           "proc" |
           "lambda" |
           "load" |
           "loop" |
           "open" |
           "p" |
           "print" |
           "proc" |
           "puts" |
           "putc" |
           "pp" |
           "raise" |
           "fail" |
           "rand" |
           "readline" |
           "readlines" |
           "require" |
           "scan" |
           "select" |
           "sleep" |
           "srand" |
           "system" |
           "sub" |
           "throw" => RUBYTOKEN.METHOD
        case "nil" => RUBYTOKEN.NIL
        case "true" => RUBYTOKEN.TRUE
        case "false" => RUBYTOKEN.FALSE
        case "__ENCODING__" | "encoding" => RUBYTOKEN._ENCODING
        case "__LINE__" | "line"=> RUBYTOKEN._LINE
        case "__FILE__" | "file" => RUBYTOKEN._FILE
        case "defined?" => RUBYTOKEN.DEFINED
        case "(" | "%w(" => RUBYTOKEN.LPAREN
        case ")" => RUBYTOKEN.RPAREN
        case "{" | "#{" => RUBYTOKEN.LBRACE
        case "}" => RUBYTOKEN.RBRACE
        case "[" | "[]" | "[]=" => RUBYTOKEN.LBRACK
        case "]" => RUBYTOKEN.RBRACK
        case "+" => RUBYTOKEN.PLUS
        case "-" => RUBYTOKEN.MINUS
        case "*" => RUBYTOKEN.MULT
        case "**" => RUBYTOKEN.POW
        case "/" => RUBYTOKEN.DIV
        case "%" | "%i(" => RUBYTOKEN.MOD
        case "<<" => RUBYTOKEN.LTLT
        case ">>" => RUBYTOKEN.GTGT
        case "&" | "&."=> RUBYTOKEN.AND
        case "|" => RUBYTOKEN.OR
        case "!" => RUBYTOKEN.NOT
        case "NOT" => RUBYTOKEN.NOT_KEYWORD
        case "&&" | "&&=" => RUBYTOKEN.ANDAND
        case "AND" => RUBYTOKEN.AND_KEYWORD
        case "||" | "||="=> RUBYTOKEN.OROR
        case "OR" => RUBYTOKEN.OR_KEYWORD
        case "^"  => RUBYTOKEN.XOR
        case "~" | "~@" => RUBYTOKEN.TILDE
        case "<"  => RUBYTOKEN.LT
        case ">" | "->"  => RUBYTOKEN.GT
        case "<=" => RUBYTOKEN.LTEQ
        case ">=" | "=>" => RUBYTOKEN.GTEQ
        case "==" | "==="=> RUBYTOKEN.EQEQ
        case "!=" | "!~" => RUBYTOKEN.NOTEQ
        case "<>" | "<=>"=> RUBYTOKEN.LTGT
        case "," => RUBYTOKEN.COMMA
        case ":" | "::" => RUBYTOKEN.COLON
        case "." => RUBYTOKEN.DOT
        case ".." | "..." => RUBYTOKEN.RANGE
        case "`"  => RUBYTOKEN.BACKTICK
        case "=" | "=~"=> RUBYTOKEN.EQ
        case ";" => RUBYTOKEN.SEMICOLON
        case "+=" | "+@" => RUBYTOKEN.PLUSEQ
        case "-=" | "-@" => RUBYTOKEN.MINUSEQ
        case "*=" => RUBYTOKEN.MULTEQ
        case "/="  => RUBYTOKEN.DIVEQ
        case "%="  => RUBYTOKEN.MODEQ
        case "&="  => RUBYTOKEN.ANDEQ
        case "|="  => RUBYTOKEN.OREQ
        case "^="  => RUBYTOKEN.XOREQ
        case ">>="  => RUBYTOKEN.GTGTEQ
        case "<<="  => RUBYTOKEN.LTLTEQ
        case "**="  => RUBYTOKEN.POWEQ
        case "identifier" => RUBYTOKEN.IDENTIFIER
        case "comment" => RUBYTOKEN.COMMENT
        case "simple_symbol" | "string_content" | "heredoc_content" | "heredoc_beginning" | "heredoc_end" | "string" | "\""=> RUBYTOKEN.QUOTED_STRING
        case "escape_sequence" => RUBYTOKEN.WHITESPACE
        case _ => RUBYTOKEN.BAD_CHARACTER
    }
    token
}