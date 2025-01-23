package examples.lock
from std import collection.*
from protobuf import protobuf.*
from protobuf import grpc.*
public class Empty <: MessageLite & TypedMessage<Empty> {
    public init() { m_innerInit() }
    protected func m_size(): Int64 { 0 }
    protected func m_hashCode(): Int64 { 0 }
    protected func m_isEmpty(): Bool { true }
    protected func m_clear(): Unit { }
    public operator func !=(src: Empty): Bool { !(this == src) }
    public operator func ==(src: Empty): Bool { hashCode() == src.hashCode() && size == src.size && unknownFields == src.unknownFields }
    public func mergeFrom(src: Empty): Unit { if(!src.unknownFields.isEmpty()) { unknownFields.appendAll(src.unknownFields) } }
    public func copyFrom(src: Empty): Empty { m_innerCopyFrom(src); return this }
    public func clone(): Empty { return Empty().copyFrom(this) }
    public func unpack<T>(src: T): Unit where T <: BytesReader { while (!src.isEmpty()) { m_unknown(src, src.parseTag()) }; markDirty() }
    public func pack<T>(out: T): Unit where T <: BytesWriter { m_unknown(out) }
    public func toString(): String { "{}" }
    public func packi(out: BytesWriter) { pack(out) }
    public func unpacki(src: BytesReader) { unpack(src) }
    public static func empty() { Empty() }
    public static func fromBytes(src: Collection<Byte>) { let m = Empty(); m.unpack(src); m }
    public static func fromBytes(src: BytesReader) { let m = Empty(); m.unpack(src); m }
}
public abstract class DMutexService <: Service {
    protected init() { super("examples.lock.DMutex") }
    protected func m_dispatch(fn: String, sess: ServerSession) {
        match (fn) {
            case "caller" => duplexStream(sess, caller)
            case _ => notfound(sess)
        }
    }
    protected func caller(ctx: Context, stream: ServerReaderWriter<Empty, Empty>): Status
}
public abstract class Unimplemented_DMutexService <: DMutexService {
    protected open func caller(ctx: Context, stream: ServerReaderWriter<Empty, Empty>): Status { UNIMPLEMENTED }
}
public class DMutexClient <: Stub {
    public init(chan: Channel) { super(chan, "examples.lock.DMutex") }
    public func caller(opts!: ?CallOptions = None) {
        duplexStream<Empty, Empty>("caller", opts)
    }
}