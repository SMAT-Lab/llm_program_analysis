package utils.nio
public func ArrayCopy(src: Array<Byte>, srcPos: Int64, dest: Array<Byte>, destPos: Int64, length: Int64) {
    if ((srcPos | destPos | length) < 0) {
        throw IndexOutOfBoundsException()
    }
    if (destPos > dest.size) {
        throw IndexOutOfBoundsException()
    }
    src.copyTo(dest, srcPos, destPos, length)
}
public class ByteBuffer <: Buffer & ToString & Hashable & Equatable<Buffer>  {
    public let hb: Array<Byte>
    let offset: Int64
    init (mark: Int64, position: Int64, limits: Int64, capacity: Int64, hbs: Array<Byte>, offsets: Int64) {
        super(mark, position, limits, capacity)
        this.hb = hbs
        this.offset = offsets
    }
    init (cap: Int64, lims: Int64) {
        this (-1, 0, lims, cap, Array<Byte>(cap, item: 0), 0)
    }
    init (bufs: Array<Byte>, off: Int64, len: Int64) {
        this (-1, off, off+len, bufs.size, bufs, 0)
    }
    protected init (bufs: Array<Byte>, mark: Int64, pos: Int64, lim: Int64, cap: Int64, off: Int64) {
        this(mark, pos, lim, cap, bufs, off)
    }
    public static func allocate(capacitys: Int64): ByteBuffer {
        if (capacitys < 0) {
            throw IllegalArgumentException()
        }
        return ByteBuffer(capacitys, capacitys)
    }
    public static func wrap(arrays: Array<UInt8>, offset: Int64, length: Int64): ByteBuffer {
        try{
            return ByteBuffer(arrays,offset,length)
        } catch (ex: IllegalArgumentException) {
            throw IndexOutOfBoundsException()
        }
    }
    public static func wrap(arrays: Array<UInt8>): ByteBuffer {
        return wrap(arrays, 0, arrays.size)
    }
    public func get(dst: Array<UInt8>): ByteBuffer {
        return get(dst, 0, dst.size)
    }
    public func put(srcs: Array<UInt8>): ByteBuffer {
        return this.put(srcs, 0, srcs.size)
    }
    public func hasArray(): Bool {
        return false
    }
    public func array(): Array<UInt8> {
        return this.hb
    }
    public func arrayOffset(): Int64 {
        return this.offset
    }
    public func position(newPosit: Int64): ByteBuffer {
        super.position(newPosit)
        return this
    }
    public func limit(newLim: Int64): ByteBuffer {
        super.limit(newLim)
        return this
    }
    public func reset(): ByteBuffer {
        super.reset()
        return this
    }
    public func clear (): ByteBuffer {
        super.clear()
        return this
    }
    public func flip(): ByteBuffer {
        super.flip()
        return this
    }
    public func rewind(): ByteBuffer {
        super.rewind()
        return this
    }
    public func toString(): String {
        let sbd = StringBuilder()
        sbd.append("ByteBuffer: [offset=")
        sbd.append(this.offset)
        sbd.append(" mark=")
        sbd.append(this.mar)
        sbd.append(" pos=")
        sbd.append(position())
        sbd.append(" lim=")
        sbd.append(limit())
        sbd.append(" cap=")
        sbd.append(capacity())
        sbd.append("]")
        let src = sbd.toString()
        sbd.reset()
        return src
    }
    @OverflowWrapping
    public func hashCode(): Int64 {
        var hc: Int32 = 1
        var p = position()
        for (i in limit()-1..=p:-1) {
            hc = 31 * hc + Int32(get(i))
        }
        return Int64(hc)
    }
    public operator func == (thats: Buffer): Bool {
        return refEq(this, thats)
    }
    public operator func != (thats: Buffer): Bool {
        return !refEq(this, thats)
    }
    public func slice(): ByteBuffer {
        return ByteBuffer(this.hb, -1, 0, this.remaining(), this.remaining(), this.position() + offset)
    }
    public func slice (pos: Int64, limit: Int64): ByteBuffer {
        let rem = limit - pos
        return ByteBuffer(hb, -1, 0, rem, rem, pos + offset)
    }
    public func duplicate(): ByteBuffer {
        return ByteBuffer(hb, this.markValue(), this.position(), this.limit(), this.capacity(), offset)
    }
    public func asReadOnlyBuffer(): ByteBuffer {
        return ByteBuffer(hb, this.markValue(), this.position(), this.limit(), this.capacity(), offset)
    }
    protected func ix(ii: Int64): Int64 {
        return ii + offset
    }
    public func get(): Byte {
        return hb[ix(nextGetIndex())]
    }
    public func get(i:Int64) : Byte {
        return hb[ix(checkIndex(i))]
    }
    public func get(dsts: Array<Byte>, offset: Int64, length: Int64): ByteBuffer {
        checkBounds(offset, length, dsts.size)
        if (length > this.remaining()) {
            throw Exception() // BufferUnderflowException
        }
        ArrayCopy(hb, ix(position()), dsts, offset, length)
        position(position() + length)
        return this
    }
    public func put(x: Byte): ByteBuffer {
        hb[ix(nextGetIndex())] = x
        return this
    }
    public func put(i: Int64, x: Byte): ByteBuffer {
        hb[ix(checkIndex(i))] = x
        return this
    }
    public func put(src: Array<Byte>, offsets: Int64, length: Int64): ByteBuffer {
        checkBounds(offsets, length, src.size)
        if (length > remaining()) {
            throw Exception() // BufferOverflowException
        }
        ArrayCopy(src, offsets, hb, ix(position()), length)
        position(position() + length)
        return this
    }
    public func put(srcs: ByteBuffer): ByteBuffer {
        if (srcs is ByteBuffer) {
            if (srcs == this) {
                throw createSameBufferException()
            }
            let sb: ByteBuffer =(srcs as ByteBuffer).getOrThrow()
            let n = sb.remaining()
            if (n > remaining()) {
                throw BufferOverflowException() // BufferOverflowException
            }
            ArrayCopy(sb.hb, sb.ix(sb.position()), hb, ix(position()), n)
            sb.position(sb.position() + n )
            position(position() +n)
        }
        return this
    }
    public func compact(): ByteBuffer {
        ArrayCopy(hb, ix(position()), hb, ix(0), remaining())
        position(remaining())
        limit(capacity())
        discardMark()
        return this
    }
    @OverflowWrapping
    public func putLong(val: Int64): ByteBuffer {
        this.putUInt64(UInt64(val))
    }
    @OverflowWrapping
    public func putInt(val: Int32): ByteBuffer {
        this.putUInt32(UInt32(val))
    }
    @OverflowWrapping
    public func putShort(val: Int16): ByteBuffer {
        this.putUInt16(UInt16(val))
    }
    @OverflowWrapping
    public func getLong(): Int64 {
        return Int64(this.getUInt64())
    }
    @OverflowWrapping
    public func getInt(): Int32 {
        return Int32(this.getUInt32())
    }
    @OverflowWrapping
    public func getShort(): Int16 {
        return Int16(this.getUInt16())
    }
    @OverflowWrapping
    public func putUInt64(val: UInt64): ByteBuffer {
        this.put(UInt8((val >> 56) & 0xff))
        this.put(UInt8((val >> 48) & 0xff))
        this.put(UInt8((val >> 40) & 0xff))
        this.put(UInt8((val >> 32) & 0xff))
        this.put(UInt8((val >> 24) & 0xff))
        this.put(UInt8((val >> 16) & 0xff))
        this.put(UInt8((val >> 8) & 0xff))
        this.put(UInt8(val & 0xff))
        return this
    }
    @OverflowWrapping
    public func putUInt32(val: UInt32): ByteBuffer {
        this.put(UInt8((val >> 24) & 0xff))
        this.put(UInt8((val >> 16) & 0xff))
        this.put(UInt8((val >> 8) & 0xff))
        this.put(UInt8(val & 0xff))
        return this
    }
    @OverflowWrapping
    public func putUInt16(val: UInt16): ByteBuffer {
        this.put(UInt8((val >> 8) & 0xff))
        this.put(UInt8(val & 0xff))
        return this
    }
    @OverflowWrapping
    public func getUInt64(): UInt64 {
        return UInt64(this.get()) << 56 |
                UInt64(this.get()) << 48 |
                UInt64(this.get()) << 40 |
                UInt64(this.get()) << 32 |
                UInt64(this.get()) << 24 |
                UInt64(this.get()) << 16 |
                UInt64(this.get()) << 8 |
                UInt64(this.get())
    }
    @OverflowWrapping
    public func getUInt32(): UInt32 {
        return UInt32(this.get()) << 24 |
            UInt32(this.get()) << 16 |
            UInt32(this.get()) << 8 |
            UInt32(this.get())
    }
    @OverflowWrapping
    public func getUInt16(): UInt16 {
        return UInt16(this.get()) << 8 |
            UInt16(this.get())
    }
     func createSameBufferException(): IllegalArgumentException {
        throw IllegalArgumentException("The source buffer is this buffer")
    }
}
public class BufferOverflowException <: Exception {
    public init() {
        super("BufferOverflowException: \n")
    }
}