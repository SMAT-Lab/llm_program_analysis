package proto3
public struct ParseComplete <: BackendMessage & Serializable<ParseComplete> {
    var kind = b'1'
    var len: Int32 = 4
    public init() {}
    public mut func decode(data: Array<UInt8>): Unit {
        var buf = ByteBuffer(data)
    }
    public func encode(): Array<UInt8> {
        var buf = ByteBuffer()
        buf.add(kind)
        buf.add(len)
        var arr = Array<UInt8>(buf.getBuf())
        return arr
    }
    public func serialize(): DataModel {
        let t: Char = Char(UInt32(kind))
        return DataModelStruct().add(field<Char>("type", t)).add(field<Int32>("len", len))
    }
    public static func deserialize(dm: DataModel): ParseComplete {
        var dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        var result = ParseComplete()
        result.kind = Byte.deserialize(dms.get("kind"))
        result.len = Int32.deserialize(dms.get("len"))
        return result
    }
    public func toString() {
        return this.serialize().toJson().toJsonString()
    }
}