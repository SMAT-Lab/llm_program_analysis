package cbor4cj
import std.io.InputStream
public class SinglePrecisionFloatDecoder <: AbstractDecoder<SinglePrecisionFloat> {
    public init(decoder: ?CborDecoder, inputStream: InputStream) {
        super(decoder, inputStream)
    }
    @OverflowWrapping
    public override func decode(_: Int32): SinglePrecisionFloat {
        var bits: Int32 = 0
        bits |= nextSymbol() & 0xFF
        bits <<= 8
        bits |= nextSymbol() & 0xFF
        bits <<= 8
        bits |= nextSymbol() & 0xFF
        bits <<= 8
        bits |= nextSymbol() & 0xFF
        return SinglePrecisionFloat(Float32.fromBits(UInt32(bits)))
    }
}