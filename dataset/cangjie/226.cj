// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
// https://gitee.com/HW-PLLab/http2/issues/I5WCU8?from=project-issue
from http2 import hpack.*
main () {
    let en: Encoder = Encoder.newEncoder()
    let arrHeaderField : Array<HeaderField> = [
        HeaderField(":status", "404"),
        HeaderField("content-length", "18"),
        HeaderField("date", "Tue"),
        HeaderField("date", "Tue, 18 Oct 2022 21:19:20 CST"),
        HeaderField("content-Type", "text/plain; charset=utf-8"),
        HeaderField("X-Content-Type-Options", "nosniff")
    ]
    let a = en.encode(arrHeaderField)
    if(a.toString() != "[141, 92, 2, 49, 56, 97, 3, 84, 117, 101, 97, 150, 223, 105, 126, 148, 11, 202, 106, 34, 84, 16, 4, 37, 4, 27, 129, 126, 224, 128, 165, 237, 219, 255, 64, 137, 33, 234, 73, 106, 74, 219, 253, 86, 95, 146, 73, 124, 165, 138, 232, 25, 170, 251, 80, 147, 142, 196, 21, 48, 90, 153, 86, 123, 64, 145, 252, 90, 241, 234, 73, 106, 74, 219, 253, 86, 85, 181, 86, 147, 30, 164, 127, 133, 168, 232, 168, 210, 203]") {
        return 1
    }
    let b = en.encode(arrHeaderField)
    if (b.toString() != "[141, 194, 193, 192, 191, 190]") {
        return 2
    }
    let de: Decoder = Decoder.newDecode()
    let aa = de.decode(a)
    if(aa.toString() != "[:status: 404 [false], content-length: 18 [false], date: Tue [false], date: Tue, 18 Oct 2022 21:19:20 CST [false], content-Type: text/plain; charset=utf-8 [false], X-Content-Type-Options: nosniff [false]]") {
        return 3
    }
    let bb = de.decode(b)
    if(bb.toString() != "[:status: 404 [false], content-length: 18 [false], date: Tue [false], date: Tue, 18 Oct 2022 21:19:20 CST [false], content-Type: text/plain; charset=utf-8 [false], X-Content-Type-Options: nosniff [false]]") {
        return 4
    }
    return 0
}