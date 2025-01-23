package compress4cj.compressors
import std.io.InputStream
public abstract class CompressorInputStream <: InputStream & Resource {
    private var bytesRead: Int64 = 0
    public open prop length: Int64 {
        get() {
            -1
        }
    }
    protected func count(read: Int64) {
        if (read != -1) {
            bytesRead += read
        }
    }
    protected func pushedBackBytes(pushBack: Int64) {
        bytesRead -= pushBack
    }
    public func getBytesRead(): Int64 {
        return bytesRead
    }
    public func getUncompressedCount(): Int64 {
        return getBytesRead()
    }
    public open func isClosed(): Bool {
        false
    }
    public open func close(): Unit {}
}