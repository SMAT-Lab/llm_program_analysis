// EXEC: cjc %import-path %L %l %f  %project-path %project-L/protobuf  -l protobuf-cj
// EXEC: ./main
from rpc4cj import grpc.*
from rpc4cj import transport.*
from rpc4cj import exceptions.*
from rpc4cj import util.*
from std import io.*
from std import socket.*
from net import tls.*
from std import time.*
var port: UInt16 = 0
main (){
    try {
        let ss: TcpServerSocket = TcpServerSocket(bindAt: port)
        port = ss.localAddress.port
        let timeout: Duration = Duration.second*(1)
        let gs = GrpcSocketS(ss)
        gs.close()
        gs.accept(timeout)
    } catch (e: Exception) {
        return 0
    }
    return -1
}