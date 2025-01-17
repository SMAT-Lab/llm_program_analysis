package glob

import std.regex.Regex
import std.collection.ArrayList
import std.fs.{Directory, Path, FileInfo, FSException}
import std.deriving.Derive

// cjlint-ignore -start !G.OPR.01 !G.NAM.04 !G.ITF.04 macro
@Derive[Equatable]
enum CharSpecifier {
    SingleChar(Rune)
    | CharRange(Rune, Rune)
}

@Derive[Equatable]
enum PatternToken {
    Char(Rune)
    | AnyChar
    | AnySequence
    | AnyRecursiveSequence
    | AnyWithin(Array<CharSpecifier>)
    | AnyExcept(Array<CharSpecifier>)
}

public struct MatchOptions {
    /**
     * 是否以大小写敏感的方式匹配模式。
     * 目前只考虑 ASCII 字符之间的大/小写关系，
     * 但将来可能会扩展到适用于 Unicode。
     */
    public var caseSensitive: Bool = false

    /**
     * 是否要求路径分隔符字符（例如 Posix 上的 `/`）必须由字面量 `/` 匹配，
     * 而不是由 `*` 或 `?` 或 `[...]` 匹配。
     */
    public var requireLiteralSeparator: Bool = false

    /**
     * 是否要求路径组件的开头是 `.` 字符，必须由字面量 `.` 匹配，
     * 而不是由 `*` 或 `?` 或 `**` 或 `[...]` 匹配。
     * 这对于 Unix 系统上被传统认为是隐藏的文件很有用，
     * 可能希望在列出文件时跳过它们。
     */
    public var requireLiteralLeadingDot: Bool = false
}

@Derive[Equatable]
public enum MatchResult {
    Match
    | SubPatternDoesntMatch
    | EntirePatternDoesntMatch
}

// cjlint-ignore -end macro

const ERROR_WILDCARDS = "wildcards are either regular `*` or recursive `**`";
const ERROR_RECURSIVE_WILDCARDS = "recursive wildcards must form a single path component";
const ERROR_INVALID_RANGE = "invalid range pattern";

public class PatternException <: Exception {
    public let pos: Int

    public init(pos: Int, message: String) {
        super(message)
        this.pos = pos
    }

    public override func getClassName(): String {
        "PatternException"
    }
}

func isSeparator(c: Rune): Bool {
    return c.isAscii() && (c == r'/' || c == r'\\')
}

func parseCharSpecifiers(s: Array<Rune>): Array<CharSpecifier> {
    let ret = ArrayList<CharSpecifier>()
    var i = 0
    while (i < s.size) {
        if (i + 3 <= s.size && s[i + 1] == r'-') {
            ret.append(CharSpecifier.CharRange(s[i], s[i + 2]))
            i += 3
        } else {
            ret.append(CharSpecifier.SingleChar(s[i]))
            i += 1
        }
    }
    return ret.toArray()
}

public class CharsIterator <: Iterator<Rune> {
    let chars: Array<Rune>
    var i: Int

    init(c: Array<Rune>, i!: Int = 0) {
        this.chars = c
        this.i = i
    }

    public func clone(): CharsIterator {
        return CharsIterator(this.chars, i: this.i)
    }

    public func next(): Option<Rune> {
        if (this.i < this.chars.size) {
            let c = this.chars[this.i]
            this.i++
            return Some(c)
        } else {
            return None
        }
    }
}

func charsEq(a: Rune, b: Rune, caseSensitive: Bool): Bool {
    if (!caseSensitive && a.isAscii() && b.isAscii()) {
        a.toAsciiLowerCase() == b.toAsciiLowerCase()
    } else {
        a == b
    }
}

// cjlint-ignore -start !G.FUN.01 fun
func inCharSpecifiers(cs: Array<CharSpecifier>, c: Rune, options: MatchOptions): Bool {
    for (spec in cs) {
        match (spec) {
            case CharSpecifier.SingleChar(cs) =>
                if (charsEq(c, cs, options.caseSensitive)) {
                    return true
                } else {
                    continue
                }

            case CharSpecifier.CharRange(start, end) =>
                if (!options.caseSensitive && c.isAscii() && start.isAscii() && end.isAscii()) {
                    let sl = start.toAsciiLowerCase()
                    let el = end.toAsciiLowerCase()

                    let su = sl.toAsciiUpperCase()
                    let eu = el.toAsciiUpperCase()

                    if (sl != su && el != eu) {
                        let cl = c.toAsciiLowerCase()
                        if (cl >= sl && cl <= el) {
                            return true;
                        }
                    }
                }

                if (c >= start && c <= end) {
                    return true
                }
        }
    }

    return false
}

public struct Pattern {
    let original: String
    let tokens: ArrayList<PatternToken>
    let isRecursive: Bool

    init(pattern: String) {
        let chars = pattern.toRuneArray()
        let tokens = ArrayList<PatternToken>()
        var is_recursive = false
        var i = 0

        while (i < chars.size) {
            match (chars[i]) {
                case r'?' =>
                    tokens.append(PatternToken.AnyChar)
                    i++
                case r'*' =>
                    let old = i

                    while (i < chars.size && chars[i] == r'*') {
                        i++
                    }

                    let count = i - old

                    if (count > 2) {
                        throw PatternException(old + 2, ERROR_WILDCARDS)
                    } else if (count == 2) {
                        let is_valid = if (i == 2 || isSeparator(chars[i - count - 1])) {
                            if (i < chars.size && isSeparator(chars[i])) {
                                i++
                                true
                            } else if (i == chars.size) {
                                true
                            } else {
                                throw PatternException(i, ERROR_RECURSIVE_WILDCARDS)
                            }
                        } else {
                            throw PatternException(old - 1, ERROR_RECURSIVE_WILDCARDS)
                        }

                        if (is_valid) {
                            let tokens_len = tokens.size

                            if (!(tokens_len > 1 && tokens.get(tokens_len - 1) == PatternToken.AnyRecursiveSequence)) {
                                is_recursive = true
                                tokens.append(PatternToken.AnyRecursiveSequence)
                            }
                        }
                    } else {
                        tokens.append(PatternToken.AnySequence)
                    }
                case r'[' =>
                    if (i + 4 <= chars.size && chars[i + 1] == r'!') {
                        match (chars[i + 3..].indexOf(r']')) {
                            case None => ()
                            case Some(j) =>
                                let subChars = chars[i + 2..i + 3 + j]
                                let cs = parseCharSpecifiers(subChars)
                                tokens.append(PatternToken.AnyExcept(cs))
                                i += 4 + j
                                continue
                        }
                    } else if (i + 3 <= chars.size && chars[i + 1] != r'!') {
                        match (chars[i + 2..].indexOf(r']')) {
                            case None => ()
                            case Some(j) =>
                                let subChars = chars[i + 1..i + 2 + j]
                                let cs = parseCharSpecifiers(subChars)
                                tokens.append(PatternToken.AnyWithin(cs))
                                i += 3 + j
                                continue
                        }
                    }

                    throw PatternException(i, ERROR_INVALID_RANGE)
                case c =>
                    tokens.append(PatternToken.Char(c))
                    i++
            }
        }

        this.original = pattern
        this.tokens = tokens
        this.isRecursive = is_recursive
    }

    public func matches(str: String): Bool {
        this.matchesWith(str, MatchOptions())
    }

    public func matchesWith(
        str: String,
        options: MatchOptions
    ): Bool {
        this.matchesFrom(true, CharsIterator(str.toRuneArray()), 0, options) == MatchResult.Match
    }

    public func matchesFrom(
        followsSeparator: Bool,
        file: CharsIterator,
        i: Int,
        options: MatchOptions
    ): MatchResult {
        var fs = followsSeparator
        for ((ti, token) in this.tokens[i..].iterator().enumerate()) {
            match (token) {
                case AnySequence | AnyRecursiveSequence =>
                    match (this.matchesFrom(fs, file.clone(), i + ti + 1, options)) {
                        case MatchResult.SubPatternDoesntMatch => ()
                        case m => return m
                    }

                    while (let Some(c) <- file.next()) {
                        if (fs && options.requireLiteralLeadingDot && c == r'.') {
                            return MatchResult.SubPatternDoesntMatch
                        }
                        fs = isSeparator(c)
                        match (token) {
                            case PatternToken.AnyRecursiveSequence =>
                                if (!fs) {
                                    continue
                                }
                            case PatternToken.AnySequence =>
                                if (options.requireLiteralSeparator && fs) {
                                    return MatchResult.SubPatternDoesntMatch
                                }
                            case _ => ()
                        }

                        match (this.matchesFrom(fs, file.clone(), i + ti + 1, options)) {
                            case MatchResult.SubPatternDoesntMatch => ()
                            case m => return m
                        }
                    }
                case _ =>
                    let c = match (file.next()) {
                        case Some(c) => c
                        case None => return MatchResult.EntirePatternDoesntMatch
                    }

                    let is_sep = isSeparator(c)

                    if (!match (token) {
                        case PatternToken.AnyChar | PatternToken.AnyWithin(_) | AnyExcept(_) =>
                            if ((options.requireLiteralSeparator && is_sep) || (fs && options.requireLiteralLeadingDot &&
                                c == r'.')) {
                                false
                            } else {
                                true
                            }
                        case _ => true
                    }) {
                        return MatchResult.SubPatternDoesntMatch
                    }

                    if (!match (token) {
                        case PatternToken.AnyChar => true
                        case PatternToken.AnyWithin(cs) => inCharSpecifiers(cs, c, options)
                        case PatternToken.AnyExcept(cs) => !inCharSpecifiers(cs, c, options)
                        case PatternToken.Char(tc) => charsEq(c, tc, options.caseSensitive)
                        case _ => throw Exception("unreachable")
                    }) {
                        return MatchResult.SubPatternDoesntMatch
                    }
                    fs = is_sep
            }
        }

        if (file.next().isNone()) {
            return MatchResult.Match
        } else {
            return MatchResult.SubPatternDoesntMatch
        }
    }

    func toCharString(): Option<String> {
        let ret = StringBuilder()
        for (token in this.tokens) {
            match (token) {
                case Char(c) => ret.append(c)
                case _ => return None
            }
        }
        return ret.toString()
    }
}

func checkWindowsVerbatim(path: String): Bool {
    if (path.size < 4) {
        return false
    }
    let chars = path.toRuneArray()

    let c0 = chars[0]
    let c1 = chars[1]
    let c2 = chars[2]
    let c3 = chars[3]

    // \\.\
    if (c0 == r'\\' && c1 == r'\\' && c2 == r'.' && c3 == r'\\') {
        return true
    }
    // \\?\
    if (c0 == r'\\' && c1 == r'\\' && c2 == r'?' && c3 == r'\\') {
        return true
    }

    return false
}

public struct PathWrapper {
    public let path: Path
    let isDirectory: Bool

    init(path: Path) {
        this.path = path
        this.isDirectory = FileInfo(path).isDirectory()
    }

    init(path: Path, isDirectory: Bool) {
        this.path = path
        this.isDirectory = isDirectory
    }
}

func fillTodo(
    todo: ArrayList<(PathWrapper, Int64)>,
    patterns: Array<Pattern>,
    idx: Int,
    path: PathWrapper,
    options: MatchOptions
): Unit {
    let pattern = patterns[idx]
    let isDir = path.isDirectory
    let curDir = path.path.toString() == "."

    let add = {
        todo: ArrayList<(PathWrapper, Int64)>, nextPath: PathWrapper => if (idx + 1 == patterns.size) {
            todo.append((nextPath, Int64.Max))
        } else {
            fillTodo(todo, patterns, idx + 1, nextPath, options)
        }
    }

    match (pattern.toCharString()) {
        case Some(s) =>
            let special = s == "." || s == ".."
            let nextPath = if (curDir) {
                Path(s)
            } else {
                path.path.join(s)
            }
            let nextPathWrapper: PathWrapper
            try {
                nextPathWrapper = PathWrapper(nextPath)
            } catch (e: FSException) {
                return
            }
            if ((special && isDir) || !special) {
                add(todo, nextPathWrapper)
            }
        case None =>
            if (isDir) {
                let dirFiles = Directory.readFrom(path.path)
                let dirs = ArrayList<PathWrapper>()
                for (e in dirFiles) {
                    if (curDir) {
                        dirs.append(PathWrapper(Path(e.path.fileName), e.isDirectory()))
                    } else {
                        dirs.append(PathWrapper(e.path, e.isDirectory()))
                    }
                }
                var children = dirs.iterator()
                if (options.requireLiteralLeadingDot) {
                    children = children.filter {
                        c => !(c.path.fileName.startsWith("."))
                    }
                }
                let cc = ArrayList<PathWrapper>()
                for (c in children) {
                    cc.append(c)
                }
                cc.sortBy {
                    l: PathWrapper, r: PathWrapper => if (l.path.fileName > r.path.fileName) {
                        Ordering.GT
                    } else if (l.path.fileName < r.path.fileName) {
                        Ordering.LT
                    } else {
                        Ordering.EQ
                    }
                }

                for (c in cc) {
                    todo.append((c, idx))
                }

                if (!pattern.tokens.isEmpty() && pattern.tokens[0] == PatternToken.Char(r'.')) {
                    for (sp in [".", ".."]) {
                        if (pattern.matchesWith(sp, options)) {
                            add(todo, PathWrapper(path.path.join(sp)))
                        }
                    }
                }
            }
    }
}

public class Paths <: Iterator<Path> {
    let dirPatterns: Array<Pattern>
    let requireDir: Bool
    let options: MatchOptions
    let todo: ArrayList<(PathWrapper, Int64)>
    let scope: PathWrapper
    var initialized: Bool = false

    init(
        dirPatterns: Array<Pattern>,
        requireDir: Bool,
        options: MatchOptions,
        todo: ArrayList<(PathWrapper, Int64)>,
        scope: PathWrapper
    ) {
        this.dirPatterns = dirPatterns
        this.requireDir = requireDir
        this.options = options
        this.todo = todo
        this.scope = scope
    }

    public func next(): Option<Path> {
        if (!this.initialized) {
            this.initialized = true
            if (!this.dirPatterns.isEmpty()) {
                fillTodo(this.todo, this.dirPatterns, 0, this.scope, this.options)
            }
        }
        while (true) {
            if (this.dirPatterns.isEmpty() || this.todo.isEmpty()) {
                return None
            }

            let t = this.todo.remove(this.todo.size - 1)
            let path = t[0]
            var idx = t[1]

            if (idx == Int64.Max) {
                if (this.requireDir && !path.isDirectory) {
                    continue
                }
                return Some(path.path)
            }

            if (this.dirPatterns[idx].isRecursive) {
                var next = idx
                while (next + 1 < this.dirPatterns.size && this.dirPatterns[next + 1].isRecursive) {
                    next++
                }

                if (path.isDirectory) {
                    fillTodo(
                        this.todo,
                        this.dirPatterns,
                        next,
                        path,
                        this.options
                    )

                    if (next == this.dirPatterns.size - 1) {
                        return Some(path.path)
                    } else {
                        idx = next + 1
                    }
                } else if (next == this.dirPatterns.size - 1) {
                    continue
                } else {
                    idx = next + 1
                }
            }

            if (this.dirPatterns[idx].matchesWith(path.path.fileName, this.options)) {
                if (idx == this.dirPatterns.size - 1) {
                    if (!this.requireDir || path.isDirectory) {
                        return Some(path.path)
                    }
                } else {
                    fillTodo(
                        this.todo,
                        this.dirPatterns,
                        idx + 1,
                        path,
                        this.options
                    )
                }
            }
        }

        None
    }
}

func getRoot(pattern: String): Option<String> {
    let chars = pattern.toRuneArray()

    if (chars.size == 0) {
        return ""
    }

    if (chars[0] == r'/') {
        return "/"
    }

    if (chars.size >= 2) {
        if (chars[0].isAsciiLetter() && chars[1] == r':') {
            return pattern[0..2] + "\\"
        }
    }

    None
}

extend String {
    func split(checker: (Rune) -> Bool): Array<String> {
        let chars = this.toRuneArray()
        let ret = ArrayList<String>()
        var start = 0
        var i = 0

        while (i < chars.size) {
            if (checker(chars[i])) {
                if (start < i) {
                    ret.append(this[start..i])
                }
                start = i + 1
            }
            i++
        }

        if (start < i) {
            ret.append(this[start..i])
        }

        return ret.toArray()
    }
}

/** 返回一个迭代器，使用默认匹配选项生成与给定模式匹配的所有 Path。 
 * 这些路径可以是绝对路径，也可以是相对于当前工作目录的相对路径。
 *
 * 如果模式无效，则可能会引发 PatternException。
 */
public func glob(pattern: String): Paths {
    globWith(pattern, MatchOptions())
}

/** 返回一个迭代器，使用给定的匹配选项生成与给定模式匹配的所有 Path。 
 * 这些路径可以是绝对路径，也可以是相对于当前工作目录的相对路径。
 * 此函数允许您指定匹配选项，例如大小写敏感性。
 *
 * 如果模式无效，则可能会引发 PatternException。
 */
public func globWith(pattern: String, options: MatchOptions): Paths {
    let _ = Pattern(pattern)

    if (checkWindowsVerbatim(pattern)) {
        throw PatternException(0, "verbatim paths are not supported")
    }

    var root: String
    var foundRoot = false

    match (getRoot(pattern)) {
        case Some(r) =>
            root = r
            foundRoot = true
        case None =>
            root = "."
            foundRoot = false
    }

    let dirPatterns = ArrayList<Pattern>()
    let skip = if (foundRoot) {
        root.size
    } else {
        0
    }
    let components = pattern[(min(skip, pattern.size))..].split(isSeparator)
    for (c in components) {
        dirPatterns.append(Pattern(c))
    }

    if (foundRoot && root.size == pattern.size) {
        dirPatterns.append(Pattern(""))
    }

    let lastIsSeparator = if (pattern.size > 0) {
        let ra = pattern.toRuneArray()
        isSeparator(ra[ra.size - 1])
    } else {
        false
    }

    return Paths(
        dirPatterns.toArray(),
        lastIsSeparator,
        options,
        ArrayList<(PathWrapper, Int64)>(),
        PathWrapper(Path(root))
    )
}

// cjlint-ignore -end fun
