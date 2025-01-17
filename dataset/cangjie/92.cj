// 构建一个简单的 HTTP 服务器，可以响应 GET 与 POST 请求，并支持 JSON 数据
// cjc version: 0.55.3
import std.fs.{ File, OpenOption }
import net.http.*
import encoding.json.{ JsonObject, JsonValue }

class HttpServer {
    let server: Server
    public init(ip: String, port: UInt16) {
        server = ServerBuilder().addr(ip).port(port).build()
        println("http://${ip}:${port}")
    }

    public func route(route: String,
        callback: (req: HttpRequest, res: HttpResponseBuilder) -> Unit) {
        server.distributor.register(route, { context => 
            callback(context.request, context.responseBuilder)
        })
    }

    public func start() {
        server.serve()
    }
}

func readFile(path: String): String {
    return String.fromUtf8(File.readFrom(path))
}

main() {
    let server = HttpServer("127.0.0.1", 8080)
    // 响应 GET 请求
    server.route("/", { req, res => 
        if (req.method == "GET") {
            // 设置 http 响应头
            let Headers = HttpHeaders()
            Headers.add("Content-Type", "text/html;charset=utf-8;")
            res.setHeaders(Headers)
            // 返回读取一个 html 文件，并返回给客户端
            res.body(readFile("./index.html"))
        }
    })
    // 响应 POST 请求
    server.route("/testApi", { req, res => 
        if (req.method == "POST") {
            // 读取请求内容
            let data = Array<UInt8>(1024, repeat: 0)
            let length = req.body.read(data)
            let content = String.fromUtf8(data.slice(0, length))
            println(content)
            let object = JsonValue.fromStr(content).asObject()

            // 初始化一个空的 JsonObject，并添加键值和信息
            let response = JsonObject()
            response.put("code", JsonValue.fromStr("\"ok\""))
            let UserName = object.get("name").getOrThrow().asString().getValue()
            response.put("msg", JsonValue.fromStr("\"Cangjie：Hello ${UserName}\""))

            // 设置 http 响应头
            let headers = HttpHeaders()
            headers.add("Content-Type", "applications/json;charset=utf-8;")
            res.setHeaders(headers)

            // 将 JsonObject 转为 Json 字符串文本并响应返回
            res.body(response.toJsonString())
        }
    })
    server.start()
}
