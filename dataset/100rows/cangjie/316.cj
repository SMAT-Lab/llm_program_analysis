package proto
// 执行prepare阶段的请求
public class StmtExecutePacket <: MysqlPacket {
    public let status: Byte = MysqlPacket.COM_STMT_EXECUTE
    public var stmtId: Int64 = 0
    public var flags: Byte = 0
    public let iterationCount: Int64 = 1
    public var paramCount: Int64 = 0
    public var nullBitmap: Array<Byte> = []
    public var fieldTypes = ArrayList<Map<Byte, Byte>>()
    public var paramValues = ArrayList<String>()
    public func read(data: Array<Byte>) {}
    public func write(buffer: ByteBuffer): Unit {
        BufferUtil.writeUB3(buffer, Int32(calcPacketSize()))
        buffer.put(packetId)
        buffer.put(status)
        BufferUtil.writeUB4(buffer, stmtId)
        buffer.put(flags)
        BufferUtil.writeUB4(buffer, iterationCount)
        if (paramCount > 0) {
            let bitmapSize = (paramCount + 7) / 8
            for (i in 0..bitmapSize) {
                buffer.put(0)
            }
        }
        for (i in 0..paramCount) {
            let value: String = paramValues[i]
            //类型
            buffer.put(0x08)
            //值
            BufferUtil.writeWithLength(buffer, value.toArray())
        }
    }
    public func calcPacketSize(): Int64 {
        var size = 11
        if (paramCount > 0) {
            size += (paramCount + 7) / 8
            size += paramCount * 2
            for (i in 0..paramCount) {
                let value: String = paramValues[i]
                size += BufferUtil.getLength(value.toArray())
            }
        }
        return size
    }
    public func getPacketInfo(): String {
        return "MySQL StmtExecute Packet"
    }
}