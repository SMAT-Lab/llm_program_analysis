// 3rd_party_lib:websocket4cj/build/websocket4cj
//正常场景:建立连接 通信 2进制传输
//验证 服务端WsConn readMsg()sendBinary() 客户端WsConnClient readMsg()sendBinary()
import secodeFuzz.*
from std import unittest.*
from std import unittest.testmacro.*
from websocket4cj import client.*
from std import collection.*
from websocket4cj import server.*
var port: UInt16 = 1452
var Client_msg :String = ""
var hasConnect = false
let rawUrl = "ws://127.0.0.1:${port}"
let headerMap = HashMap<String, String>()
var wsclient = WebSocket4cjClient(rawUrl,headerMap)
var Exception_message = ""
var WebSocket4cjClient_ck : Option<WsConnClient> = Option<WsConnClient>.None
var string_s:String = ""
func serve(){
    var ws = WebSocket4cjServer("127.0.0.1",port)
    ws.handleFunc{w=>
        while (true) {
            let data = w.readMsg()
            //println("data[0] = ${String.fromUtf8(data[0])}")
            match (data[1]) {
                case Some(msg)=>
                    w.sendBinary("客户端~ 我收到了你的消息 \'${string_s}\'".toUtf8Array())
                case _ =>
                    w.close()
                    return
            }
        }
    }
    ws.launch() // 启动监听
}
func call_fuzz(string_c:String, string_s2:String) {
    string_s = string_s2
    try{
        WebSocket4cjClient_ck.getOrThrow().sendBinary(string_c.toUtf8Array())
        let data = WebSocket4cjClient_ck.getOrThrow().readMsg()
        //println("data[0] = ${String.fromUtf8(data[0])}")
        match (data[1]) {
            case Some(msg)=>
                Client_msg = "${String.fromUtf8(msg)}"
                println("客户端:服务端~ 我收到了你的消息 \"${Client_msg}\"")
            case _ =>
                WebSocket4cjClient_ck.getOrThrow().close()
                return
        }
    } catch (e: Exception) {
        Exception_message = "Exception"
    }
    return
}
func unboundTest():Unit{
    var case_name = CString("Fuzz_sendBinary")
    unsafe{
        // 根据 call_fuzz的入参类型，选择fuzz方法，例如DF_FUZZ_Int64。其他方法见secodeFuzz.cj。其中100000为定义测试次数。其他参数可不变
        DT_FUZZ_String_2(0,100000,case_name,0,call_fuzz)
        case_name.free()
    }
}
main(){
    spawn{
        serve()
    }
    sleep(1000*1000*1000*2)
    WebSocket4cjClient_ck = wsclient.connect()
    unboundTest()
    return
}