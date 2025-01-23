package mp3tag4cj.mp3tag4cj
public abstract class AbstractID3v2FrameData {
    var unsynchronisation: Bool = false
    public init(unsynchronisation: Bool) {
        this.unsynchronisation = unsynchronisation
    }
    protected open func synchroniseAndUnpackFrameData(bytes: Array<Int8>): Unit {
        if (unsynchronisation && BufferTools.sizeSynchronisationWouldSubtract(bytes) > 0) {
            var synchronisedBytes: Array<Int8> = BufferTools.synchroniseBuffer(bytes)
            unpackFrameData(synchronisedBytes)
        } else {
            unpackFrameData(bytes)
        }
    }
    protected open func packAndUnsynchroniseFrameData(): Array<Int8> {
        var bytes: Array<Int8> = packFrameData()
        if (unsynchronisation && BufferTools.sizeUnsynchronisationWouldAdd(bytes) > 0) {
            return BufferTools.unsynchroniseBuffer(bytes)
        }
        return bytes
    }
    public open func toBytes(): Array<Int8> {
        return packAndUnsynchroniseFrameData()
    }
    @OverflowWrapping
    public open func hashCode(): Int64 {
        let prime: Int32 = 31
        var result: Int32 = 1
        if (unsynchronisation) {
            result = prime * result + 1231
        } else {
            result = prime * result + 1237
        }
        return Int64(result)
    }
    protected func unpackFrameData(bytes: Array<Int8>): Unit
    public func packFrameData(): Array<Int8>
    public func getLength(): Int32
}