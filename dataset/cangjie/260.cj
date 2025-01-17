package bignumber
public class MathContext <: ToString & Hashable {
    static let DEFAULT_DIGITS: Int32 = 9
    static let DEFAULT_ROUNDINGMODE: RoundingMode = RoundingMode.HALF_UP
    static let MIN_DIGITS: Int32 = 0
    public static let UNLIMITED: MathContext = MathContext(0, RoundingMode.HALF_UP)
    public static let DECIMAL32: MathContext = MathContext(7, RoundingMode.HALF_EVEN)
    public static let DECIMAL64: MathContext = MathContext(16, RoundingMode.HALF_EVEN)
    public static let DECIMAL128: MathContext = MathContext(34, RoundingMode.HALF_EVEN)
    let precision: Int32
    let roundingMode: RoundingMode
    public init(setPrecision: Int32) {
        this(setPrecision, DEFAULT_ROUNDINGMODE)
    }
    public init(setPrecision: Int32, setRoundingMode: RoundingMode) {
        if (setPrecision < MIN_DIGITS) {
            throw IllegalArgumentException("Digits < 0")
        }
        this.precision = setPrecision
        this.roundingMode = setRoundingMode
    }
    public init(val: String) {
        var setPrecision: Int32 = 0
        try {
            if (!val.startsWith("precision=")) {
                throw Exception()
            }
            let fence = if (let Some(v) <- val.indexOf(b' ')) {
                v
            } else {
                -1
            }
            var off = 10
            setPrecision = Int32.parse(val[10..fence])
            if (!val[(fence + 1)..val.size].startsWith("roundingMode=")) {
                throw Exception()
            }
            off = fence + 1 + 13
            let str = val[off..val.size]
            this.roundingMode = RoundingMode.valueOf(str)
        } catch (e: Exception) {
            throw IllegalArgumentException("bad string format")
        }
        if (setPrecision < MIN_DIGITS) {
            throw IllegalArgumentException("Digits < 0")
        }
        this.precision = setPrecision
    }
    public operator func ==(mc: MathContext): Bool {
        if (refEq(this, mc)) {
            return true
        }
        mc.precision == this.precision && mc.roundingMode == this.roundingMode
    }
    public func equals(mc: MathContext): Bool {
        this == mc
    }
    public func hashCode(): Int64 {
        Int64(this.precision) + this.roundingMode.hashCode() * 59
    }
    public func toString(): String {
        "precision=${this.precision} roundingMode=${this.roundingMode.toString()}"
    }
}