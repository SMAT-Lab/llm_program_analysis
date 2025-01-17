package barcode
public class EAN13Reader <: UPCEANReader {
    static let FIRST_DIGIT_ENCODINGS = [0x00, 0x0B, 0x0D, 0xE, 0x13, 0x19, 0x1C, 0x15, 0x16, 0x1A]
    let decodeMiddleCounters: Array<Int64> = Array<Int64>(4, item: 0)
    protected func decodeMiddle(
        row: BitArray,
        startRange: Array<Int64>,
        resultString: StringBuilder
    ): Int64 {
        let counters = decodeMiddleCounters
        counters[0] = 0
        counters[1] = 0
        counters[2] = 0
        counters[3] = 0
        let end = row.size
        var rowOffset = startRange[1]
        var lgPatternFound = 0
        for (x in 0..6) {
            if (rowOffset >= end) {
                break
            }
            let bestMatch = decodeDigit(row, counters, rowOffset, L_AND_G_PATTERNS)
            resultString.append(Char(UInt32('0') + UInt32(bestMatch % 10)))
            for (counter in counters) {
                rowOffset += counter
            }
            if (bestMatch >= 10) {
                lgPatternFound |= 1 << (5 - x)
            }
        }
        determineFirstDigit(resultString, lgPatternFound)
        let middleRange = findGuardPattern(row, rowOffset, true, MIDDLE_PATTERN)
        rowOffset = middleRange[1]
        for (x in 0..6) {
            if (rowOffset >= end) {
                break
            }
            let bestMatch = decodeDigit(row, counters, rowOffset, L_PATTERNS)
            resultString.append(Char(UInt32('0') + UInt32(bestMatch)))
            for (counter in counters) {
                rowOffset += counter
            }
        }
        rowOffset
    }
    func getBarcodeFormat(): BarcodeFormat {
        return BarcodeFormat.EAN_13
    }
    static func determineFirstDigit(resultString: StringBuilder, lgPatternFound: Int64) {
        for (d in 0..10) {
            if (lgPatternFound == FIRST_DIGIT_ENCODINGS[d]) {
                resultString.insert(0, Char(UInt32('0') + UInt32(d)))
                return
            }
        }
        throw NotFoundException()
    }
}
public class EAN13Writer <: UPCEANWriter {
    static let CODE_WIDTH = 3 + // start guard
    (7 * 6) + // left bars
    5 + // middle guard
    (7 * 6) + // right bars
    3
    protected override func getSupportedWriteFormats(): ?HashSet<BarcodeFormat> {
        HashSet<BarcodeFormat>([BarcodeFormat.EAN_13])
    }
    public func encode(oContents: String): Array<Bool> {
        var contents = oContents
        let length = contents.size
        match (length) {
            case 12 =>
                let check = try {
                    UPCEANReader.getStandardUPCEANChecksum(contents)
                } catch (e: FormatException) {
                    throw IllegalArgumentException(e.toString())
                }
                contents = "${contents}${check}"
            case 13 =>
                try {
                    if (!UPCEANReader.checkStandardUPCEANChecksum(contents)) {
                        throw IllegalArgumentException("Contents do not pass checksum")
                    }
                } catch (_: FormatException) {
                    throw IllegalArgumentException("Illegal contents")
                }
            case _ =>
                throw IllegalArgumentException("Requested contents should be 12 or 13 digits long, but got ${length}")
        }
        checkNumeric(contents)
        let firstDigit = charDigit(contents.charAt(0), 10)
        let parities = EAN13Reader.FIRST_DIGIT_ENCODINGS[firstDigit]
        let result = Array<Bool>(CODE_WIDTH, item: false)
        var pos = appendPattern(result, 0, UPCEANReader.START_END_PATTERN, true)
        for (i in 1..7) {
            var digit = charDigit(contents.charAt(i), 10)
            if ((parities >> (6 - i) & 1) == 1) {
                digit += 10
            }
            pos += appendPattern(result, pos, UPCEANReader.L_AND_G_PATTERNS[digit], false)
        }
        pos += appendPattern(result, pos, UPCEANReader.MIDDLE_PATTERN, false)
        for (i in 7..13) {
            let digit = charDigit(contents.charAt(i), 10)
            pos += appendPattern(result, pos, UPCEANReader.L_PATTERNS[digit], true)
        }
        appendPattern(result, pos, UPCEANReader.START_END_PATTERN, true)
        result
    }
}