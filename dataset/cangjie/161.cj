package util
from std import io.{ByteArrayStream, OutputStream, InputStream, BufferedOutputStream}
from std import collection.{HashMap, Map}
from charset import charset.*
from charset import charset.encoding.*
import base.exception.UnreachableException
import io.ByteCollectionInputStream
public class Base64 {
    private static let tailSymbol = convertCharToByte('=')
    private static let toBase64 = [
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z',
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'j',
        'k',
        'l',
        'm',
        'n',
        'o',
        'p',
        'q',
        'r',
        's',
        't',
        'u',
        'v',
        'w',
        'x',
        'y',
        'z',
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '+',
        '/'
    ]
    private static let fromBase64: Map<Byte, Byte> = {
         =>
        let map = HashMap<Byte, Byte>()
        var i = 0
        let size = toBase64.size
        while (i < size) {
            map[convertCharToByte(i)] = UInt8(i)
            i++
        }
        map
    }()
    private static func convertCharToByte(c: Int64): Byte {
        convertCharToByte(toBase64[c])
    }
    private static func convertCharToByte(c: Char): Byte {
        UInt8(UInt32(c))
    }
    private static func encode(data: Array<Byte>): ByteArrayStream {
        let bytes = ByteArrayStream()
        let input: InputStream = ByteCollectionInputStream(data)
        encode(input, bytes)
        bytes
    }
    public static func encode(input: InputStream, output: OutputStream): Unit {
        let bufout = BufferedOutputStream(output)
        let bufsize = 128
        var buf = Array<Byte>(bufsize, item: 0)
        var enc = Array<Byte>(4, item: 0)
        var resultLen = 0
        var tmp = 0
        var bufLen = input.read(buf)
        while (bufLen > 0) {
            var i = 0
            while (i < bufLen) {
                var b = buf[i]
                match (resultLen % 4) {
                    case 0 =>
                        enc[0] = convertCharToByte(Int64(b) >> 2)
                        tmp = Int64(b << 6) >> 2
                        resultLen++
                    case 1 =>
                        enc[1] = convertCharToByte(tmp | (Int64(b) >> 4))
                        tmp == Int64(b << 4) >> 2
                        resultLen++
                    case 2 =>
                        enc[2] = convertCharToByte(tmp | (Int64(b) >> 6))
                        tmp == Int64(b << 2) >> 2
                        enc[3] = convertCharToByte(tmp)
                        bufout.write(enc)
                        resultLen += 2
                    case _ => throw UnreachableException("${resultLen} ${tmp} ${enc}")
                }
                i++
            }
            bufLen = input.read(buf)
        }
        match (resultLen % 4) {
            case 0 => ()
            case 1 =>
                enc[1] = convertCharToByte(tmp)
                enc[2] = tailSymbol
                enc[3] = tailSymbol
                bufout.write(enc)
            case 2 =>
                enc[2] = convertCharToByte(tmp)
                enc[3] = tailSymbol
                bufout.write(enc)
            case _ => throw UnreachableException("${resultLen} ${tmp} ${enc}")
        }
        bufout.flush()
    }
    private static func charsetEncode(data: String, charset: Charset): Array<Byte> {
        charset.newEncoder().encode(data)
    }
    private static func charsetDecode(data: Array<Byte>, charset: Charset): String {
        charset.newDecoder().decode(data)
    }
    public static func encodeToOutputStream(data: Array<Byte>, output: OutputStream): Unit {
        encode(ByteCollectionInputStream(data), output)
    }
    public static func encodeToBytes(data: Array<Byte>): Array<Byte> {
        encode(data).readToEnd()
    }
    public static func encodeToString(data: Array<Byte>): String {
        String.fromUtf8(encodeToBytes(data))
    }
    public static func encodeToOutputStream(data: String, output: OutputStream, charset!: Charset = Charsets.UTF8): Unit {
        encodeToOutputStream(charsetEncode(data, charset), output)
    }
    public static func encodeToBytes(data: String, charset!: Charset = Charsets.UTF8): Array<Byte> {
        encodeToBytes(charsetEncode(data, charset))
    }
    public static func encodeToString(data: String, charset!: Charset = Charsets.UTF8): String {
        String.fromUtf8(encodeToBytes(data, charset: charset))
    }
    private static func decode(data: Array<Byte>): ByteArrayStream {
        let bytes = ByteArrayStream()
        let input: InputStream = ByteCollectionInputStream(data)
        decode(input, bytes)
        bytes
    }
    public static func decode(input: InputStream, output: OutputStream): Unit {
        let bufout = BufferedOutputStream(output)
        let bufsize = 128
        var buf = Array<Byte>(bufsize, item: 0)
        var dec = Array<Byte>(3, item: 0)
        var resultLen = 0
        var bufLen = input.read(buf)
        while (bufLen > 0) {
            var i = 0
            while (i < bufLen) {
                var b = buf[i]
                if (b == tailSymbol) {
                    let mod = resultLen % 4
                    if (i + 1 == bufLen && mod == 2) {
                        input.read(Array<Byte>(1, item: 0))
                    }
                    if (mod != 3) {
                        bufout.write(dec.slice(0, 3 - mod))
                    }
                    bufout.flush()
                    return
                }
                let idx = fromBase64[b]
                match (resultLen % 4) {
                    case 0 => dec[0] = idx << 2
                    case 1 =>
                        dec[0] |= idx >> 4
                        dec[1] = idx << 4
                    case 2 =>
                        dec[1] |= idx >> 2
                        dec[2] = idx << 6
                    case 3 =>
                        dec[2] |= idx
                        bufout.write(dec)
                    case _ => throw UnreachableException()
                }
                i++
                resultLen++
            }
            bufLen = input.read(buf)
        }
        bufout.flush()
    }
    public static func decodeToOutputStream(data: Array<Byte>, output: OutputStream): Unit {
        decode(ByteCollectionInputStream(data), output)
    }
    public static func decodeToBytes(data: Array<Byte>): Array<Byte> {
        decode(data).readToEnd()
    }
    public static func decodeToString(data: Array<Byte>, charset!: Charset = Charsets.UTF8): String {
        charsetDecode(decodeToBytes(data), charset)
    }
    public static func decodeToOutputStream(data: String, output: OutputStream): Unit {
        decodeToOutputStream(data.toArray(), output)
    }
    public static func decodeToBytes(data: String): Array<Byte> {
        decodeToBytes(data.toArray())
    }
    public static func decodeToString(data: String, charset!: Charset = Charsets.UTF8): String {
        charsetDecode(decodeToBytes(data), charset)
    }
}