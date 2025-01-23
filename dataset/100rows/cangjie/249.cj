package cbor4cj
public class MajorType <: Enum<MajorType> {
    public static let INVALID = MajorType("INVALID", 0, -1)
    public static let UNSIGNED_INTEGER = MajorType("UNSIGNED_INTEGER", 1, 0)
    public static let NEGATIVE_INTEGER = MajorType("NEGATIVE_INTEGER", 2, 1)
    public static let BYTE_STRING = MajorType("BYTE_STRING", 3, 2)
    public static let UNICODE_STRING = MajorType("UNICODE_STRING", 4, 3)
    public static let ARRAY = MajorType("ARRAY", 5, 4)
    public static let MAP = MajorType("MAP", 6, 5)
    public static let TAG = MajorType("TAG", 7, 6)
    public static let SPECIAL = MajorType("SPECIAL", 8, 7)
    private let value: Int32
    private init(_enum_name: String, _enum_ordinal: Int32, value: Int32) {
        super(_enum_name, _enum_ordinal)
        this.value = value
    }
    public func getValue(): Int32 {
        return value
    }
    public static func ofByte(b: Int32): MajorType {
        match (b >> 5) {
            case 0 => return UNSIGNED_INTEGER
            case 1 => return NEGATIVE_INTEGER
            case 2 => return BYTE_STRING
            case 3 => return UNICODE_STRING
            case 4 => return ARRAY
            case 5 => return MAP
            case 6 => return TAG
            case 7 => return SPECIAL
            case _ => return INVALID
        }
    }
}