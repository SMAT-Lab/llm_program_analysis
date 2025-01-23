// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from charset import charset.*
main (){
    var charset = Charsets.ISO_8859_6
    var decoder = charset.newDecoder()
    var encoder = charset.newEncoder()
    var s1 = "ف س ئ ب ز "
    var arr = encoder.encode(s1)
    var s2 = decoder.decode(arr)
    if(s1 != s2){
        return 1
    }
    return 0
}