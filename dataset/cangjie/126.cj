package enum_enhance.test

// import std.unittest.testmacro.*
// import std.unittest.*
import enum_enhance.{EquatableEnum, ToStringEnum}

@EquatableEnum
public enum EquatableColor {
    | Red
    | Yellow
    | Green(Bool)
    | Orange(Bool)
    | Blue(Rune)
    | Pink(Rune)
    | YCbCr(UInt8, Int32, Float64)
    | RGBA(Rune, Int32, Bool)
}

@Test
class EqutableEnumTest {
    @TestCase
    func noArgTest(): Unit {
        let red1 = EquatableColor.Red
        let red2 = EquatableColor.Red
        let yellow = EquatableColor.Yellow

        @Expect(red1 == red2)
        @Expect(red1 != yellow)
    }

    @TestCase
    func boolTest(): Unit {
        let green1 = EquatableColor.Green(true)
        let green2 = EquatableColor.Green(true)
        let green3 = EquatableColor.Green(false)
        let orange1 = EquatableColor.Orange(true)
        let orange2 = EquatableColor.Orange(false)

        @Expect(green1 == green2)
        @Expect(green1 != green3)
        @Expect(green1 != orange1)
        @Expect(green1 != orange2)
        @Expect(green3 != orange1)
        @Expect(green3 != orange2)
        @Expect(orange1 != orange2)
    }

    @TestCase
    func runeTest(): Unit {
        let blue1 = EquatableColor.Blue(r"A")
        let blue2 = EquatableColor.Blue(r"A")
        let blue3 = EquatableColor.Blue(r"B")
        let blue4 = EquatableColor.Blue(r"\\")
        let pink1 = EquatableColor.Pink(r"A")
        let pink2 = EquatableColor.Pink(r"B")
        let pink3 = EquatableColor.Pink(r"\\")
        
        @Expect(blue1 == blue2)
        @Expect(blue1 != blue3)
        @Expect(blue1 != pink1)
        @Expect(blue1 != pink2)
        @Expect(blue1 != blue4)
        @Expect(blue3 != pink1)
        @Expect(blue3 != pink2)
        @Expect(blue4 != pink3)
        @Expect(pink1 != pink2)
        @Expect(pink1 != blue4)
        @Expect(pink3 != blue4)
    }

    @TestCase
    func nultiArgTest(): Unit {
        let ycbcr1 = EquatableColor.YCbCr(255, 1024, 0.5)
        let ycbcr2 = EquatableColor.YCbCr(255, 1024, 0.5)
        let ycbcr3 = EquatableColor.YCbCr(128, 2048, 0.75)
        
        let rgba1 = EquatableColor.RGBA(r"A", 1024, true)
        let rgba2 = EquatableColor.RGBA(r"A", 1024, true)
        let rgba3 = EquatableColor.RGBA(r"B", 2048, false)
        let rgba4 = EquatableColor.RGBA(r"A", 2048, true)
        
        @Expect(ycbcr1 == ycbcr2)
        @Expect(ycbcr1 != ycbcr3)
        @Expect(ycbcr1 != rgba1)
        @Expect(ycbcr1 != rgba3)
        
        @Expect(rgba1 == rgba2)
        @Expect(rgba1 != rgba3)
        @Expect(rgba1 != rgba4)
        @Expect(rgba1 != ycbcr1)
    }
}
