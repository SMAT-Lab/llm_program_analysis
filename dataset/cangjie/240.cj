package cbor4cj
import std.io.ByteBuffer
import std.io.InputStream
import std.io.OutputStream
import std.math.numeric.BigInt
public abstract class AbstractBuilder<T> {
    private let parent: ?T
    public init(parent: ?T) {
        this.parent = parent
    }
    protected func getParent(): ?T {
        return parent
    }
    protected open func addChunk(_: ?DataItem): Unit {
        throw Exception()
    }
    protected func convert(value: Int64): DataItem {
        if (value >= 0) {
            return UnsignedInteger(value)
        } else {
            return NegativeInteger(value)
        }
    }
    protected func convert(value: BigInt): DataItem {
        if (value.sign == -1) {
            return NegativeInteger(value)
        } else {
            return UnsignedInteger(value)
        }
    }
    protected func convert(value: Bool): DataItem {
        if (value) {
            return SimpleValue.TRUE
        } else {
            return SimpleValue.FALSE
        }
    }
    protected func convert(bytes: Array<UInt8>): DataItem {
        return ByteString(bytes)
    }
    protected func convert(string: String): DataItem {
        return UnicodeString(string)
    }
    protected func convert(value: Float32): DataItem {
        if (isHalfPrecisionEnough(value)) {
            return HalfPrecisionFloat(value)
        } else {
            return SinglePrecisionFloat(value)
        }
    }
    protected func convert(value: Float64): DataItem {
        return DoublePrecisionFloat(value)
    }
    protected func tag(value: Int64): Tag {
        return Tag(value)
    }
    private func isHalfPrecisionEnough(value: Float32): Bool {
        try {
            let outputStream = ByteBuffer()
            let encoder = getHalfPrecisionFloatEncoder(outputStream)
            encoder.encode(HalfPrecisionFloat(value))
            let bytes: Array<UInt8> = outputStream.bytes()
            let inputStream = ByteBuffer()
            inputStream.write(bytes)
            let decoder = getHalfPrecisionFloatDecoder(inputStream)
            let arr = Array<Byte>(1, repeat: 0)
            if (inputStream.read(arr) == -1) {
                throw CborException("unexpected end of stream")
            }
            let halfPrecisionFloat = decoder.decode(0)
            return value == halfPrecisionFloat.getValue()
        } catch (cborException: CborException) {
            return false
        }
    }
    protected open func getHalfPrecisionFloatEncoder(outputStream: OutputStream): HalfPrecisionFloatEncoder {
        return HalfPrecisionFloatEncoder(None, outputStream)
    }
    protected open func getHalfPrecisionFloatDecoder(inputStream: InputStream): HalfPrecisionFloatDecoder {
        return HalfPrecisionFloatDecoder(None, inputStream)
    }
}