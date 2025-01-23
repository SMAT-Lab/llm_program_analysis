// EXEC: cjc %import-path %L %l %f  %project-path %project-L/protobuf  -l protobuf-cj
// EXEC: ./main
from rpc4cj import grpc.*
from rpc4cj import transport.*
from rpc4cj import exceptions.*
from rpc4cj import util.*
from std import io.*
from std import socket.*
main (){
    println("a")
    let socket: TcpSocket = TcpSocket("127.0.0.1", 0)
    let sc = GRPCConn.SocketConn(socket)
    let conn: GRPCConnSocket = GRPCConnSocket(sc)
    //socket.close()
    println("b")
    var bw: BufWriter = BufWriter(0, conn, err: GrpcError())
    var src: Array<UInt8> = Array<UInt8>()
    var res = bw.write(src)//(Int64, GrpcError)
    println("c")
    if (res[1].isNull()) {
        println(1)
        return 1
    }
    bw = BufWriter(10, conn)
    println("d")
    src = Array<UInt8>(30, item: 96)
    println("end")
    return 0
}