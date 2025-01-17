// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj
// EXEC: ./main
from httpclient4cj import httpclient4cj.*
from std import collection.*
from std import io.*
from std import time.*
from net import http.*
from std import socket.*
main() {
    let soc = TcpSocket("okhttp", portTrans(50066))
    soc.connect()
    let sc = SocketClient.SocketC(soc)
    let socket = OKSocket(sc, Option<Duration>.None, Option<Duration>.None)
    let h2conn = H2Connection(sc, BufferedOutputStream(socket), OkBuffer(socket))
    let formBody = FormBody.builder().add("username", "admin").add("password", "123456").add("host", "%6D").build()
    let request = httpclient4cj.Request.builder()
        .url("http://okhttp:${portTrans(50066)}/cangjie_test-1.0-SNAPSHOT/hello")
        .header("User-Agent", "OkHttp-Example")
        .put(formBody)
        .header("content-type", formBody.contentType().getOrThrow().toString())
        .build()
    h2conn.start()
    let h1 = h2conn.isHealthy()
    h2conn.close()
    let h2 = h2conn.isHealthy()
    if (h1 == true && h2 == false) {
        return 0
    }
    return 1
}