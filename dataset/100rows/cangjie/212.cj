// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from std import io.*
from httpclient4cj import httpclient4cj.*
from std import time.*
from net import http.*
from std import socket.*
from encoding import url.*
from net import tls.*
from std import core.*
from std import sync.sleep
var port: UInt16 = 0
main() {
    serve()
    let url: URL = URL.parse("http://127.0.0.1:${port}/1234")
    let client: HttpClient= HttpClient.builder().build()
    let request: httpclient4cj.Request = httpclient4cj.Request.builder()
                                    .url(url)
                                    .build()
    let call = client.newCall(request)
    try{
        let response: httpclient4cj.Response = call.execute()
    }catch (e: Exception) {
        return 1
    }
    return 0
}
func serve(){
    let serverSocket = TcpServerSocket(bindAt: 0)
    let server = ServerBuilder().listener(serverSocket).build()
    server.distributor.register("/1234", { httpContext =>
        let resp = "Hello from /red".toArray()
        httpContext.responseBuilder.status(307)
        httpContext.responseBuilder.header("Location","")
        httpContext.responseBuilder.body(resp)
        return
    })
    spawn{ server.serve() }
    sleep(Duration.second)
    port = serverSocket.localAddress.port
}