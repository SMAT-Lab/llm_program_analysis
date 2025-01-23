package asn1
public enum ASN1TagClass {
    | UNIVERSAL(Byte)
    | APPLICATION(Byte)
    | CONTEXT_SPECIFIC(Byte)
    | PRIVATE(Byte)
    public static func parseClass(tagByte: Byte): ASN1TagClass {
        var classValue: UInt8 = (tagByte & 0xc0)
        match (classValue) {
            case 0 => return UNIVERSAL(0)
            case 0x40 => return APPLICATION(0x40)
            case 0x80 => return CONTEXT_SPECIFIC(0x80)
            case 0xc0 => return PRIVATE(0xc0)
            case _ => throw Exception("Could not parse ASN.1 Tag Class (should be impossible)")
        }
    }
    public func getValue(): Int64 {
        match (this) {
            case UNIVERSAL(v) =>
                if (v != 0) {
                    throw Exception("UNIVERSAL value should be 0x00")
                } else {
                    return Int64(v)
                }
            case APPLICATION(v) =>
                if (v != 0x40) {
                    throw Exception("APPLICATION value should be 0x40")
                } else {
                    return Int64(v)
                }
            case CONTEXT_SPECIFIC(v) =>
                if (v != 0x80) {
                    throw Exception("CONTEXT_SPECIFIC value should be 0x80")
                } else {
                    return Int64(v)
                }
            case PRIVATE(v) =>
                if (v != 0xc0) {
                    throw Exception("PRIVATE value should be 0xc0")
                } else {
                    return Int64(v)
                }
        }
    }
}