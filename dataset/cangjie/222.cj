package maxicode.decoder
from std import math.*
from std import core.*
from std import format.*
public class DecodedBitStreamParser {
    private static let SHIFTA = '\u{FFF0}'
    private static let SHIFTB = '\u{FFF1}'
    private static let SHIFTC = '\u{FFF2}'
    private static let SHIFTD = '\u{FFF3}'
    private static let SHIFTE = '\u{FFF4}'
    private static let TWOSHIFTA = '\u{FFF5}'
    private static let THREESHIFTA = '\u{FFF6}'
    private static let LATCHA = '\u{FFF7}'
    private static let LATCHB = '\u{FFF8}'
    private static let LOCK = '\u{FFF9}'
    private static let ECI = '\u{FFFA}'
    private static let NS = '\u{FFFB}'
    private static let PAD = '\u{FFFC}'
    private static let FS = '\u{001C}'
    private static let GS = '\u{001D}'
    private static let RS = '\u{001E}'
    private static var COUNTRY_BYTES: Array<Int8> = [53, 54, 43, 44, 45, 46, 47, 48, 37, 38]
    private static var SERVICE_CLASS_BYTES: Array<Int8> = [55, 56, 57, 58, 59, 60, 49, 50, 51, 52]
    private static var POSTCODE_2_LENGTH_BYTES: Array<Int8> = [39, 40, 41, 42, 31, 32]
    private static var POSTCODE_2_BYTES: Array<Int8> = [
        33,
        34,
        35,
        36,
        25,
        26,
        27,
        28,
        29,
        30,
        19,
        20,
        21,
        22,
        23,
        24,
        13,
        14,
        15,
        16,
        17,
        18,
        7,
        8,
        9,
        10,
        11,
        12,
        1,
        2
    ]
    private static var POSTCODE_3_BYTES: Array<Array<Int8>> = [
        [39, 40, 41, 42, 31, 32],
        [33, 34, 35, 36, 25, 26],
        [27, 28, 29, 30, 19, 20],
        [21, 22, 23, 24, 13, 14],
        [15, 16, 17, 18, 7, 8],
        [9, 10, 11, 12, 1, 2]
    ]
    private static var SETS: Array<Array<Char>> = [
        ("\rABCDEFGHIJKLMNOPQRSTUVWXYZ" + ECI.toString() + FS.toString() + GS.toString() + RS.toString() + NS.toString() +
            ' '.toString() + PAD.toString() + "\"#$%&'()*+,-./0123456789:" + SHIFTB.toString() + SHIFTC.toString() +
            SHIFTD.toString() + SHIFTE.toString() + LATCHB.toString()).toRuneArray(),
        ("`abcdefghijklmnopqrstuvwxyz" + ECI.toString() + FS.toString() + GS.toString() + RS.toString() + NS.toString() +
            '{'.toString() + PAD.toString() + "}~\u{007F};<=>?[\\]^_ ,./:@!|" + PAD.toString() + TWOSHIFTA.toString() +
            THREESHIFTA.toString() + PAD.toString() + SHIFTA.toString() + SHIFTC.toString() + SHIFTD.toString() +
            SHIFTE.toString() + LATCHA.toString()).toRuneArray(),
        ("\u{00C0}\u{00C1}\u{00C2}\u{00C3}\u{00C4}\u{00C5}\u{00C6}\u{00C7}\u{00C8}\u{00C9}\u{00CA}\u{00CB}\u{00CC}\u{00CD}\u{00CE}\u{00CF}\u{00D0}\u{00D1}\u{00D2}\u{00D3}\u{00D4}\u{00D5}\u{00D6}\u{00D7}\u{00D8}\u{00D9}\u{00DA}" +
            ECI.toString() + FS.toString() + GS.toString() + RS.toString() + NS.toString() +
            "\u{00DB}\u{00DC}\u{00DD}\u{00DE}\u{00DF}\u{00AA}\u{00AC}\u{00B1}\u{00B2}\u{00B3}\u{00B5}\u{00B9}\u{00BA}\u{00BC}\u{00BD}\u{00BE}\u{0080}\u{0081}\u{0082}\u{0083}\u{0084}\u{0085}\u{0086}\u{0087}\u{0088}\u{0089}" +
            LATCHA.toString() + ' '.toString() + LOCK.toString() + SHIFTD.toString() + SHIFTE.toString() +
            LATCHB.toString()).toRuneArray(),
        ("\u{00E0}\u{00E1}\u{00E2}\u{00E3}\u{00E4}\u{00E5}\u{00E6}\u{00E7}\u{00E8}\u{00E9}\u{00EA}\u{00EB}\u{00EC}\u{00ED}\u{00EE}\u{00EF}\u{00F0}\u{00F1}\u{00F2}\u{00F3}\u{00F4}\u{00F5}\u{00F6}\u{00F7}\u{00F8}\u{00F9}\u{00FA}" +
            ECI.toString() + FS.toString() + GS.toString() + RS.toString().toString() + NS.toString() +
            "\u{00FB}\u{00FC}\u{00FD}\u{00FE}\u{00FF}\u{00A1}\u{00A8}\u{00AB}\u{00AF}\u{00B0}\u{00B4}\u{00B7}\u{00B8}\u{00BB}\u{00BF}\u{008A}\u{008B}\u{008C}\u{008D}\u{008E}\u{008F}\u{0090}\u{0091}\u{0092}\u{0093}\u{0094}" +
            LATCHA.toString() + ' '.toString() + SHIFTC.toString() + LOCK.toString() + SHIFTE.toString() +
            LATCHB.toString()).toRuneArray(),
        ("\u{0000}\u{0001}\u{0002}\u{0003}\u{0004}\u{0005}\u{0006}\u{0007}\u{0008}\u{0009}\n\u{000B}\u{000C}\r\u{000E}\u{000F}\u{0010}\u{0011}\u{0012}\u{0013}\u{0014}\u{0015}\u{0016}\u{0017}\u{0018}\u{0019}\u{001A}" +
            ECI.toString() + PAD.toString() + PAD.toString() + '\u{001B}'.toString() + NS.toString() + FS.toString() +
            GS.toString() + RS.toString() +
            "\u{001F}\u{009F}\u{00A0}\u{00A2}\u{00A3}\u{00A4}\u{00A5}\u{00A6}\u{00A7}\u{00A9}\u{00AD}\u{00AE}\u{00B6}\u{0095}\u{0096}\u{0097}\u{0098}\u{0099}\u{009A}\u{009B}\u{009C}\u{009D}\u{009E}" +
            LATCHA.toString() + ' '.toString() + SHIFTC.toString() + SHIFTD.toString() + LOCK.toString() +
            LATCHB.toString()).toRuneArray()
    ]
    private init() {}
    public static func decode(bytes: Array<UInt8>, mode: Int64): DecoderResult {
        var result: ArrayList<Char> = ArrayList<Char>()
        match (mode) {
            case 2 | 3 =>
                var postcode: String
                if (mode == 2) {
                    var pc: Int64 = getPostCode2(bytes)
                    var ps2Length: Int64 = getPostCode2Length(bytes)
                    if (ps2Length > 10) {
                        throw Qrcoder4cjFormatException.getFormatInstance()
                    }
                    postcode = pc.format(ps2Length.toString())
                } else {
                    postcode = getPostCode3(bytes)
                }
                var country: String = getCountry(bytes).format("3.3");
                var service: String = getServiceClass(bytes).format("3.3");
                result.appendAll(getMessage(bytes, 10, 84).toRuneArray())
                if (String(result).startsWith("[)>" + RS.toString() + "01" + GS.toString())) {
                    result.insertAll(
                        9,
                        (postcode + GS.toString() + country.toString() + GS.toString() + service + GS.toString()).
                            toRuneArray()
                    )
                } else {
                    result.insertAll(
                        0,
                        (postcode + GS.toString() + country + GS.toString() + service + GS.toString()).toRuneArray()
                    )
                }
            case 4 => result.appendAll(getMessage(bytes, 1, 93).toRuneArray())
            case 5 => result.appendAll(getMessage(bytes, 1, 77).toRuneArray())
            case _ => throw Exception("Unhandled mode: " + mode.toString())
        }
        var a = DecoderResult(bytes, String(result), ArrayList<Array<UInt8>>(), mode.toString())
        return a
    }
    private static func getBit(bit: Int64, bytes: Array<UInt8>): Int64 {
        var bt = bit - 1
        if ((bytes[bt / 6] & (1 << (5 - (bt % 6)))) == 0) {
            return 0
        } else {
            return 1
        }
    }
    private static func getInt(bytes: Array<UInt8>, x: Array<Int8>): Int64 {
        var val: Int64 = 0
        for (i in 0..x.size) {
            val += getBit(Int64(x[i]) & 0xFF, bytes) << (x.size - i - 1)
        }
        return val
    }
    private static func getCountry(bytes: Array<UInt8>): Int64 {
        return getInt(bytes, COUNTRY_BYTES)
    }
    private static func getServiceClass(bytes: Array<UInt8>): Int64 {
        return getInt(bytes, SERVICE_CLASS_BYTES)
    }
    private static func getPostCode2Length(bytes: Array<UInt8>): Int64 {
        return getInt(bytes, POSTCODE_2_LENGTH_BYTES)
    }
    private static func getPostCode2(bytes: Array<UInt8>): Int64 {
        return getInt(bytes, POSTCODE_2_BYTES)
    }
    private static func getPostCode3(bytes: Array<UInt8>): String {
        var sb: ArrayList<Char> = ArrayList<Char>()
        for (i in 0..POSTCODE_3_BYTES.size) {
            for (j in 0..POSTCODE_3_BYTES[i].size) {
                sb.append(SETS[0][getInt(bytes, [POSTCODE_3_BYTES[i][j]])])
            }
        }
        return String(sb)
    }
    private static func getMessage(bytes: Array<UInt8>, start: Int64, len: Int64): String {
        var sb: ArrayList<Char> = ArrayList<Char>()
        var shift: Int64 = -1
        var set: Int64 = 0
        var lastset: Int64 = 0
        var i = start
        while (i < start + len) {
            var c: Char = SETS[set][Int64(bytes[i])]
            if (c == LATCHA) {
                set = 0
                shift = -1
            } else if (c == LATCHB) {
                set = 1
                shift = -1
            } else if (c == SHIFTA || c == SHIFTB || c == SHIFTC || c == SHIFTD || c == SHIFTE) {
                lastset = set
                set = Int64(UInt32(c) - UInt32(SHIFTA))
                shift = 1
            } else if (c == TWOSHIFTA) {
                lastset = set
                set = 0
                shift = 2
            } else if (c == THREESHIFTA) {
                lastset = set
                set = 0
                shift = 3
            } else if (c == NS) {
                var nsval: Int64 = (Int64(bytes[i + 1]) << 24) + (Int64(bytes[i + 2]) << 18) + (Int64(bytes[i + 3]) << 12) +
                    (Int64(bytes[i + 4]) << 6) + Int64(bytes[i + 5])
                i += 5
                sb.appendAll(nsval.format("9.9").toRuneArray());
            } else if (c == LOCK) {
                shift = -1
            } else {
                sb.append(c)
            }
            if (shift == 0) {
                set = lastset
            }
            shift = shift - 1
            i++
        }
        while (sb.size > 0 && sb[sb.size - 1] == PAD) {
            sb.remove(sb.size - 1)
        }
        return String(sb);
    }
}