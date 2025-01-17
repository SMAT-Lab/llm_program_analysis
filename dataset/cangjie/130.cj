// EXEC: cjc %import-path %L %l %f  %project-path %project-L/protobuf  -l protobuf-cj
// EXEC: ./main
from rpc4cj import http2.frame.*
from rpc4cj import util.*
from rpc4cj import transport.*
from std import collection.*
from net import http.*
main (){
    try {
        let er: EmptyResponseWriteStream = EmptyResponseWriteStream()
        er.header()
        er.write(Array<UInt8>(16, item: 0))
        er.writeStatusCode(200)
        er.flush()
    } catch (e: Exception) {
        return -1
    }
    return 0
}
public class EmptyResponseWriteStream <: ResponseWriteStream {
    public func header(): HttpHeaders{ return HttpHeaders() }
    public func write(_: Array<UInt8>): Unit {}
    public func writeStatusCode(_: Int64): Unit {}
    public func flush(): Unit {}
}