package glide
from ohos import base.*
extend File {
    public func write(s: UInt8): Unit {
        this.write(Array<UInt8>(1, item: s))
    }
}
    public func unsignedShiftRight64(c: Int64, num: Int64) {
        let t: Int64 = 0x7fffffffffffffff<<1 | 0x01;
        // AppLog.error("${c}  ${t&c}  ${num}");
        Int64(UInt64(t & c) >> num)
    }
    public func highestOneBit(i: Int64): Int64 {
        var i2 = i
        i2 |= (i2 >>  1);
        i2 |= i2 | (i2 >>  2);
        i2 |= (i2 >>  4);
        i2 |= (i2 >>  8);
        i2 |= (i2 >> 16);
        return i2 - unsignedShiftRight64(i2, 1);
    }