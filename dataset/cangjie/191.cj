// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from charset import charset.*
from charset import charset.traditionchinese.*
main (){
    var big5 = Charsets.BIG5
    var encoder = big5.newEncoder()
    var str: String = "你號，中國"
    var s1 = encoder.encode(str)
    let dest:Array<UInt8> = [0xA7,0x41,0xB8, 0xB9, 0xA1, 0x41, 0xA4, 0xA4, 0xB0, 0xEA]
    for(i in 0..dest.size){
        let a = dest[i]
        let b = s1[i]
        if(a != b){
            return 1
        }
    }
    return 0
}