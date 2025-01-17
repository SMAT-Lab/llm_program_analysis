package enum_enhance.test

// import std.unittest.testmacro.*
// import std.unittest.*
import enum_enhance.{ToStringEnum, EquatableEnum}

@ToStringEnum
public enum Color2 {
    | Red
    | Green(Bool)
    | Blue(Rune)
    | RGBA(UInt8, UInt8, UInt8, Color2)
}



@Test
class ToStringEnumTest {
    @TestCase
    func noArgTest(): Unit {
        let red = Color2.Red
        @Expect(red.toString(true), 'Color2.Red')
        @Expect(red.toString(), 'Red')
    }

    @TestCase
    func runeTest(): Unit {
        let blue1 = Color2.Blue(r'\\')
        let blue2 = Color2.Blue(r'$')
        @Expect(blue1.toString(true), 'Color2.Blue(\\)')
        @Expect(blue2.toString(true), 'Color2.Blue($)')
        @Expect(blue1.toString(), 'Blue(\\)')
        @Expect(blue2.toString(), 'Blue($)')
    }

    @TestCase
    func noNestedPrimTest(): Unit {
        let green1 = Color2.Green(false)
        let green2 = Color2.Green(true)
        @Expect(green1.toString(true), 'Color2.Green(false)')
        @Expect(green2.toString(true), 'Color2.Green(true)')
        @Expect(green1.toString(), 'Green(false)')
        @Expect(green2.toString(), 'Green(true)')
    }

    @TestCase
    func NestedTest(): Unit {
        let rgba1 = Color2.RGBA(23, 54, 67, Color2.Red)
        let rgba2 = Color2.RGBA(2, 4, 6, Green(true))
        let rgba3 = Color2.RGBA(9, 3, 12, rgba2)
        @Expect(rgba1.toString(true), 'Color2.RGBA(23, 54, 67, Color2.Red)')
        @Expect(rgba2.toString(true), 'Color2.RGBA(2, 4, 6, Color2.Green(true))')
        @Expect(rgba3.toString(true), 'Color2.RGBA(9, 3, 12, Color2.RGBA(2, 4, 6, Color2.Green(true)))')
        @Expect(rgba1.toString(), 'RGBA(23, 54, 67, Red)')
        @Expect(rgba2.toString(), 'RGBA(2, 4, 6, Green(true))')
        @Expect(rgba3.toString(), 'RGBA(9, 3, 12, RGBA(2, 4, 6, Green(true)))')
    }
}
