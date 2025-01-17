package mimetype
func isShp(raw: Array<UInt8>, _: UInt32): Bool {
    if (raw.size < 112) {
        false
    } else if (!(bigEndianUInt32(raw[0..4]) == 9994 && bigEndianUInt32(raw[4..8]) == 0 && bigEndianUInt32(raw[8..12]) ==
        0 && bigEndianUInt32(raw[12..16]) == 0 && bigEndianUInt32(raw[16..20]) == 0 && bigEndianUInt32(raw[20..24]) == 0 &&
        littleEndianUInt32(raw[28..32]) == 1000)) {
        false
    } else {
        let shapeTypes: Array<Int32> = [
            0, // Null shape
            1, // Point
            3, // Polyline
            5, // Polygon
            8, // MultiPoint
            11, // PointZ
            13, // PolylineZ
            15, // PolygonZ
            18, // MultiPointZ
            21, // PointM
            23, // PolylineM
            25, // PolygonM
            28, // MultiPointM
            31 // MultiPatch
        ]
        for (st in shapeTypes) {
            if (st == Int32(littleEndianUInt32(raw[108..112]))) {
                return true
            }
        }
        false
    }
}
func isShx(raw: Array<UInt8>, _: UInt32): Bool {
    hasPrefix(raw, [0x00, 0x00, 0x27, 0x0A])
}