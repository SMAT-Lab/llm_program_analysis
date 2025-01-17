// EXEC: cjc %import-path %L %l %f  %project-path %project-L/protobuf  -l protobuf-cj
// EXEC: ./main
from rpc4cj import grpc.*
from rpc4cj import transport.*
from rpc4cj import exceptions.*
from rpc4cj import util.*
from std import collection.*
from rpc4cj import http2.buffer.*
from rpc4cj import http2.hpack.*
from rpc4cj import http2.http.*
from rpc4cj import http2.frame.*
from rpc4cj import http2.proto.*
from compress import zlib.*
from net import http.*
from std import io.*
main (){
    let decode: Decoder = Decoder.newDecode()
    let resp: H2Response = H2Response(decode)
    //let headerBlock: ByteBuffer = ByteBuffer(mark: Int64, position: Int64, limit: Int64, capacity: Int64, hbs: Array<Byte>, offset: Int64)
    let headers: Array<UInt8> = Array<UInt8>([65, 139, 8, 157, 92, 11, 129, 112, 220, 108, 0, 108, 63, 131, 68, 149, 98, 114, 209, 65, 252, 30, 202, 36, 95, 21, 133, 42, 75, 99, 27, 135, 235, 25, 104, 160, 255, 134, 95, 139, 29, 117, 208, 98, 13, 38, 61, 76, 77, 101, 100, 92, 2, 49, 50, 64, 138, 154, 202, 200, 177, 106, 33, 228, 53, 83, 127, 131, 155, 217, 171, 122, 144, 32, 234, 155, 161, 138, 180, 233, 77, 107, 18, 131, 22, 164, 176, 37, 193, 64, 2, 116, 101, 134, 77, 131, 53, 5, 177, 31])
    let headerBlock: ByteBuffer = ByteBuffer.wrap(headers)
    let head: HeadersFrame = HeadersFrame(1, 4, headerBlock)
    resp.appendHeader(head)
    let data: Array<Byte> = Array<Byte>([0, 0, 0, 0, 7, 10, 5, 87, 111, 114, 108, 100])
    let bas: ByteArrayStream = ByteArrayStream(36)
    bas.write(data)
    let req: HttpRequest = HttpRequestBuilder().version(HTTP2_0).url("http://127.0.0.1:50055/").method("POST").body(data).build()
    let h2r: H2Request = H2Request(req)
    //let h2r: H2Request = H2Request(decode)
    let data2: Array<Byte> = Array<Byte>([1, 0, 0, 0, 0])
    let dataBlock2: ByteBuffer = ByteBuffer.wrap(data2)
    let dataFrame2: DataFrame = DataFrame(1, 1, dataBlock2)
    resp.appendData(dataFrame2)
    resp.rawCreatResponse(h2r)
    let h2c: Http2Client = Http2Client()
    let res: ArrayList<Array<UInt8>> = h2c.handleStreamResponse(resp)
    if (res.size != 0) {
        println(-1)
        return -1
    }
    println("end")
    return 0
}