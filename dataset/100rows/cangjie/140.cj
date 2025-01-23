// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from charset import charset.*
from charset import charset.simplechinese.*
main (){
    var charset = Charsets.GB18030
    charset.newDecoder()
    var _: Array<UInt8> = Array<UInt8>([0x84, 0x36, 0x81, 0x37, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32])
    var _: Int64 = 0
    var _: Int64 = 6
    var _: Array<Char> = Array<Char>(6, {_ => '\u{0}'})
    var _: Int64 = 2
    return 0
}