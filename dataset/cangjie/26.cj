package glob

import std.unittest.*
import std.unittest.testmacro.*

@Test
class PatternTests {
    @TestCase
    func testPatternFromStr() {
        let p1 = Pattern("a*b")
        @Assert(p1.matches("a_b"), true)

        let e = @AssertThrows[PatternException]({
            let _ = Pattern("a/**b")
        })
        @Assert(e.pos, 4)
    }

    func assertInitException(pattern: String, pos: Int) {
        let e = @AssertThrows[PatternException]({
            let _ = Pattern(pattern)
        })
        @Assert(e.pos, pos)
    }

    @TestCase
    func testWildcardErrors() {
        assertInitException("a/**b", 4)
        assertInitException("a/bc**", 3)
        assertInitException("a/*****", 4)
        assertInitException("a/b**c**d", 2)
        assertInitException("a**b", 0)
    }

    @TestCase
    func testUnclosedBracketErrors() {
        assertInitException("abc[def", 3)
        assertInitException("abc[!def", 3)
        assertInitException("abc[", 3)
        assertInitException("abc[!", 3)
        assertInitException("abc[d", 3)
        assertInitException("abc[!d", 3)
        assertInitException("abc[]", 3)
        assertInitException("abc[!]", 3)
    }

    @TestCase
    func testWildcards() {
        let p1 = Pattern("a*b")
        @Assert(p1.matches("a_b"), true)

        let p2 = Pattern("a*b*c")
        @Assert(p2.matches("abc"), true)
        @Assert(p2.matches("abcd"), false)
        @Assert(p2.matches("a_b_c"), true)
        @Assert(p2.matches("a___b___c"), true)

        let p3 = Pattern("abc*abc*abc")
        @Assert(p3.matches("abcabcabcabcabcabcabc"), true)
        @Assert(p3.matches("abcabcabcabcabcabcabca"), false)

        let p4 = Pattern("a*a*a*a*a*a*a*a*a")
        @Assert(p4.matches("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"), true)

        let p5 = Pattern("a*b[xyz]c*d")
        @Assert(p5.matches("abxcdbxcddd"), true)
    }

    @TestCase
    func testRecursiveWildcards() {
        let pat = Pattern("some/**/needle.txt")
        @Assert(pat.matches("some/needle.txt"), true)
        @Assert(pat.matches("some/one/needle.txt"), true)
        @Assert(pat.matches("some/one/two/needle.txt"), true)
        @Assert(pat.matches("some/other/needle.txt"), true)
        @Assert(pat.matches("some/other/notthis.txt"), false)

        let pat2 = Pattern("**")
        @Assert(pat2.matches("abcde"), true)
        @Assert(pat2.matches(""), true)
        @Assert(pat2.matches(".asdf"), true)
        @Assert(pat2.matches("/x/.asdf"), true)

        let pat3 = Pattern("some/**/**/needle.txt")
        @Assert(pat3.matches("some/needle.txt"), true)
        @Assert(pat3.matches("some/one/needle.txt"), true)
        @Assert(pat3.matches("some/one/two/needle.txt"), true)
        @Assert(pat3.matches("some/other/needle.txt"), true)
        @Assert(pat3.matches("some/other/notthis.txt"), false)

        let pat4 = Pattern("**/test")
        @Assert(pat4.matches("one/two/test"), true)
        @Assert(pat4.matches("one/test"), true)
        @Assert(pat4.matches("test"), true)

        let pat5 = Pattern("/**/test")
        @Assert(pat5.matches("/one/two/test"), true)
        @Assert(pat5.matches("/one/test"), true)
        @Assert(pat5.matches("/test"), true)
        @Assert(pat5.matches("/one/notthis"), false)
        @Assert(pat5.matches("/notthis"), false)

        let pat6 = Pattern("**/.*")
        @Assert(pat6.matches(".abc"), true)
        @Assert(pat6.matches("abc/.abc"), true)
        @Assert(pat6.matches("ab.c"), false)
        @Assert(pat6.matches("abc/ab.c"), false)
    }

    @TestCase
    func testRangePattern() {
        let pat = Pattern("a[0-9]b")
        for (i in 0..10) {
            @Assert(pat.matches("a${i}b"), true)
        }
        @Assert(pat.matches("a_b"), false)

        let pat2 = Pattern("a[!0-9]b")
        for (i in 0..10) {
            @Assert(pat2.matches("a${i}b"), false)
        }
        @Assert(pat2.matches("a_b"), true)

        let pats = ["[a-z123]", "[1a-z23]", "[123a-z]"]
        for (p in pats) {
            let pat = Pattern(p)
            for (c in "abcdefghijklmnopqrstuvwxyz".toRuneArray()) {
                @Assert(pat.matches(String(c)), true)
            }
            for (c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".toRuneArray()) {
                var options = MatchOptions()
                options.caseSensitive = false
                @Assert(pat.matchesWith(String(c), options), true)
            }
            @Assert(pat.matches("1"), true)
            @Assert(pat.matches("2"), true)
            @Assert(pat.matches("3"), true)
        }

        let pats2 = ["[abc-]", "[-abc]", "[a-c-]"]
        for (p in pats2) {
            let pat = Pattern(p)
            @Assert(pat.matches("a"), true)
            @Assert(pat.matches("b"), true)
            @Assert(pat.matches("c"), true)
            @Assert(pat.matches("-"), true)
            @Assert(pat.matches("d"), false)
        }

        let pat3 = Pattern("[2-1]")
        @Assert(pat3.matches("1"), false)
        @Assert(pat3.matches("2"), false)

        let pat4 = Pattern("[-]")
        @Assert(pat4.matches("-"), true)
        let pat5 = Pattern("[!-]")
        @Assert(pat5.matches("-"), false)
    }

    @TestCase
    func testPatternMatches() {
        let txtPat = Pattern("*hello.txt")
        @Assert(txtPat.matches("hello.txt"), true)
        @Assert(txtPat.matches("gareth_says_hello.txt"), true)
        @Assert(txtPat.matches("some/path/to/hello.txt"), true)
        @Assert(txtPat.matches("some\\path\\to\\hello.txt"), true)
        @Assert(txtPat.matches("/an/absolute/path/to/hello.txt"), true)
        @Assert(txtPat.matches("hello.txt-and-then-some"), false)
        @Assert(txtPat.matches("goodbye.txt"), false)

        let dirPat = Pattern("*some/path/to/hello.txt")
        @Assert(dirPat.matches("some/path/to/hello.txt"), true)
        @Assert(dirPat.matches("a/bigger/some/path/to/hello.txt"), true)
        @Assert(dirPat.matches("some/path/to/hello.txt-and-then-some"), false)
        @Assert(dirPat.matches("some/other/path/to/hello.txt"), false)
    }

    @TestCase
    func testPatternMatchesWith() {
        let pat = Pattern("aBcDeFg")
        var options = MatchOptions()
        options.caseSensitive = false
        @Assert(pat.matchesWith("aBcDeFg", options), true)
        @Assert(pat.matchesWith("abcdefg", options), true)
        @Assert(pat.matchesWith("ABCDEFG", options), true)
        @Assert(pat.matchesWith("AbCdEfG", options), true)
    }

    @TestCase
    func testPatternMatchesWithLiteralSeparator() {
        let pat = Pattern("a/b/c")
        var options = MatchOptions()
        options.requireLiteralSeparator = true
        @Assert(pat.matchesWith("a/b/c", options), true)
        @Assert(pat.matchesWith("a/b/c/d", options), false)
        @Assert(pat.matchesWith("a/b/cd", options), false)
        @Assert(pat.matchesWith("a/b/c/", options), false)
        @Assert(pat.matchesWith("a/b/c//", options), false)
        @Assert(pat.matchesWith("a/b/c//d", options), false)
    }

    @TestCase
    func testPatternMatchesRequireLiteralSeparator() {
        var optionsRequireLiteral = MatchOptions()
        optionsRequireLiteral.caseSensitive = true
        optionsRequireLiteral.requireLiteralSeparator = true
        optionsRequireLiteral.requireLiteralLeadingDot = false

        var optionsNotRequireLiteral = MatchOptions()
        optionsNotRequireLiteral.caseSensitive = true
        optionsNotRequireLiteral.requireLiteralSeparator = false
        optionsNotRequireLiteral.requireLiteralLeadingDot = false

        @Assert(Pattern("abc/def").matchesWith("abc/def", optionsRequireLiteral), true)
        @Assert(Pattern("abc?def").matchesWith("abc/def", optionsRequireLiteral), false)
        @Assert(Pattern("abc*def").matchesWith("abc/def", optionsRequireLiteral), false)
        @Assert(Pattern("abc[/]def").matchesWith("abc/def", optionsRequireLiteral), false)

        @Assert(Pattern("abc/def").matchesWith("abc/def", optionsNotRequireLiteral), true)
        @Assert(Pattern("abc?def").matchesWith("abc/def", optionsNotRequireLiteral), true)
        @Assert(Pattern("abc*def").matchesWith("abc/def", optionsNotRequireLiteral), true)
        @Assert(Pattern("abc[/]def").matchesWith("abc/def", optionsNotRequireLiteral), true)
    }

    @TestCase
    func testPatternMatchesWithLiteralLeadingDot() {
        var optionsRequireLiteralLeadingDot = MatchOptions()
        optionsRequireLiteralLeadingDot.caseSensitive = true
        optionsRequireLiteralLeadingDot.requireLiteralSeparator = false
        optionsRequireLiteralLeadingDot.requireLiteralLeadingDot = true

        var optionsNotRequireLiteralLeadingDot = MatchOptions()
        optionsNotRequireLiteralLeadingDot.caseSensitive = true
        optionsNotRequireLiteralLeadingDot.requireLiteralSeparator = false
        optionsNotRequireLiteralLeadingDot.requireLiteralLeadingDot = false

        @Assert(Pattern("*.txt").matchesWith(".hello.txt", optionsNotRequireLiteralLeadingDot), true)
        @Assert(Pattern("*.txt").matchesWith(".hello.txt", optionsRequireLiteralLeadingDot), false)

        @Assert(Pattern(".*.*").matchesWith(".hello.txt", optionsNotRequireLiteralLeadingDot), true)
        @Assert(Pattern(".*.*").matchesWith(".hello.txt", optionsRequireLiteralLeadingDot), true)

        @Assert(Pattern("aaa/bbb/*").matchesWith("aaa/bbb/.ccc", optionsNotRequireLiteralLeadingDot), true)
        @Assert(Pattern("aaa/bbb/*").matchesWith("aaa/bbb/.ccc", optionsRequireLiteralLeadingDot), false)

        @Assert(Pattern("aaa/bbb/*").matchesWith("aaa/bbb/c.c.c.", optionsNotRequireLiteralLeadingDot), true)
        @Assert(Pattern("aaa/bbb/*").matchesWith("aaa/bbb/c.c.c.", optionsRequireLiteralLeadingDot), true)

        @Assert(Pattern("aaa/bbb/.*").matchesWith("aaa/bbb/.ccc", optionsNotRequireLiteralLeadingDot), true)
        @Assert(Pattern("aaa/bbb/.*").matchesWith("aaa/bbb/.ccc", optionsRequireLiteralLeadingDot), true)

        @Assert(Pattern("aaa/?bbb").matchesWith("aaa/.bbb", optionsNotRequireLiteralLeadingDot), true)
        @Assert(Pattern("aaa/?bbb").matchesWith("aaa/.bbb", optionsRequireLiteralLeadingDot), false)

        @Assert(Pattern("aaa/[.]bbb").matchesWith("aaa/.bbb", optionsNotRequireLiteralLeadingDot), true)
        @Assert(Pattern("aaa/[.]bbb").matchesWith("aaa/.bbb", optionsRequireLiteralLeadingDot), false)

        @Assert(Pattern("**/*").matchesWith(".bbb", optionsNotRequireLiteralLeadingDot), true)
        @Assert(Pattern("**/*").matchesWith(".bbb", optionsRequireLiteralLeadingDot), false)
    }

    @TestCase
    func testGlob() {
        let g1 = glob("/")
        @Assert(g1.next().isSome(), true)

        let g2 = glob("src/*")
        @Assert(g2.next().isSome(), true)
    }
}
