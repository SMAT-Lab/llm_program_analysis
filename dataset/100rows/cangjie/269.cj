package default
open class BitSieve {
    private var bits: Array<Int64> = Array<Int64>()
    private var length: Int32 = 0
    private static var smallSieve: BitSieve = BitSieve()
    private init (){
    }
    init (base: BigInteger, searchLen: Int32){
    }
    private static func unitIndex (bitIndex: Int32): Int32 {
  //    return bitIndex >>> 6;
        return 0
    }
    private static func bit (bitIndex: Int32): Int64 {
  //    return 1L << (bitIndex & ((1 << 6) - 1));
        return 0
    }
    private func get (bitIndex: Int32): Bool {
  //    int unitIndex = unitIndex(bitIndex);
  //    return ((bits[unitIndex] & bit(bitIndex)) != 0);
        return true
    }
    private func set (bitIndex: Int32): Unit {
  //    int unitIndex = unitIndex(bitIndex);
  //    bits[unitIndex] |= bit(bitIndex);
    }
    private func sieveSearch (limit: Int32, start: Int32): Int32 {
  //    if (start >= limit) return -1;
  //    int index = start;
  //    do {
  //        if (!get(index)) return index;
  //        index++;
  //    }     while (index < limit - 1);
  //    return -1;
        return 0
    }
    private func sieveSingle (limit: Int32, start: Int32, step: Int32): Unit {
  //    while (start < limit) {
  //        set(start);
  //        start += step;
    }
    open func retrieve (initValue: BigInteger, certainty: Int32, random: javautilRandom): BigInteger {
  //    int offset = 1;
  //    for (int i = 0; i < bits.length; i++) {
  //        long nextLong = ~bits[i];
  //        for (int j = 0; j < 64; j++) {
  //            if ((nextLong & 1) == 1) {
  //                BigInteger candidate = initValue.add(BigInteger.valueOf(offset));
  //                if (candidate.primeToCertainty(certainty, random)) return candidate;
  //            nextLong >>>= 1;
  //            offset += 2;
  //    return null;
        return BigInteger()
    }
}