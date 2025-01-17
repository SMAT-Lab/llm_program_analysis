package cbor4cj
public class UnicodeString <: ChunkableDataItem {
    private let string: ?String
    public init(string: ?String) {
        super(MajorType.UNICODE_STRING)
        this.string = string
    }
    public func toString(): String {
        if (string.isNone()) {
            return "null"
        } else {
            return string.getOrThrow()
        }
    }
    public func getString(): ?String {
        return string
    }
    public func equals(object: Object): Bool {
        if (object is UnicodeString && super.equals(object)) {
            let other = (object as UnicodeString).getOrThrow()
            if (string.isNone()) {
                return other.string.isNone()
            } else {
                return string == (other.string)
            }
        }
        return false
    }
    public func hashCode(): Int64 {
        var hash = 0
        if (let Some(v) <- string) {
            hash = Int64(super.hashCode())
            hash += Int64(v.hashCode())
        }
        return Int64(hash)
    }
}