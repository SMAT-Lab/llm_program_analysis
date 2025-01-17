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
main (){
    try {
        let arr: Array<Byte> = Array<Byte>(1024, item: 0)
        OutputStreamConn(ByteArrayStream()).read(arr)
    } catch (e: Exception) {
        return 0
    }
    return -1
}