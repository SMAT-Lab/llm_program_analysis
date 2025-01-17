package mail
from std import socket.*
from std import time.*
func ArrayUInt8ToString(data: Array<UInt8>): String {
    let strb = StringBuilder()
    strb.append(data)
    return strb.toString()
}
func readSocketAccept(socket: Socket): String {
    let buf: Array<UInt8> = Array<UInt8>(1024*1024, item: 8)
    socket.read(buf, Duration.second(10))
    return ArrayUInt8ToString(buf)
}
func socketSend(socket: Socket, message: String, title!: String = ""): String {
    println("command: ${message}")
    let sendState = socket.write(message.toUtf8Array())
    match (sendState) {
        case Some<Int64>(size) =>
            let responseStr: String = readSocketAccept(socket)
            println("${title} 发送成功, 字节数为${size}")
            println("${responseStr}\n")
            return responseStr
        case None =>
            println("发送失败")
            return ""
    }
}