package compress4cj.archivers.rar.unpack.decode
public class RepDecode <: Decode {
    public init() {
        this.decodeNum = Array<Int32>(Int64(Compress.RC), repeat: 0)
    }
}