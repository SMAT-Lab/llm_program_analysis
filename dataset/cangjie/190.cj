package barcode
abstract class AI013x0xReader <: AI01WeightReader {
    static let HEADER_SIZE = 5 // 4 + 1
    static let WEIGHT_SIZE = 15
    init(information: BitArray) {
        super(information)
    }
    public override func parseInformation(): String {
        if (this.information.size != HEADER_SIZE + GTIN_SIZE + WEIGHT_SIZE) {
            throw NotFoundException()
        }
        let buf = StringBuilder()
        encodeCompressedGtin(buf, HEADER_SIZE)
        encodeCompressedWeight(buf, HEADER_SIZE + GTIN_SIZE, WEIGHT_SIZE)
        buf.toString()
    }
}