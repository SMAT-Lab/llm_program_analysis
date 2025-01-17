// 本示例演示访问 DeepSeek 大模型，可前往以下网址申请 API Key
// https://platform.deepseek.com/api_keys
// 仓颉语言团队 刘俊杰 2024.10.24
import std.io.*
import net.http.*
import net.tls.*
import encoding.json.*

const DEEPSEEK_API_KEY = '-------Your DeepSeek Key--------'

extend Client {
    public func chat(question: String) {
        let info = """
        {
            "model": "deepseek-chat",
            "messages": [
                {"role": "system", "content": "你是我的全能助手，你的名字叫仓颉"},
                {"role": "user", "content": "${question}"}
            ],
            "stream": false
        }
        """
        let request = HttpRequestBuilder()
            .url('https://api.deepseek.com/chat/completions')
            .header('Authorization', 'Bearer ${DEEPSEEK_API_KEY}')
            .header('Content-Type', 'application/json')
            .body(info)
            .post()
            .build()
        let response = this.send(request)
        let text = StringReader(response.body).readToEnd()
        return parse(text) + '\n---------------------------'
    }
}

func parse(text: String) {
    let json = JsonValue.fromStr(text).asObject()
    let choices = json.getFields()['choices'].asArray()
    let message = choices[0].asObject().getFields()['message'].asObject()
    let content = message.getFields()['content'].asString().getValue()
    return content
}

main() {
    var config = TlsClientConfig()
    config.verifyMode = TrustAll
    let client = ClientBuilder()
        .tlsConfig(config)
        .readTimeout(Duration.Max) // AI 服务响应有时候比较慢，这里设置为无限等待
        .build()
    println(client.chat("你好呀，请做个自我介绍吧"))
    println(client.chat("周杰伦在 2000 到 2010 年之间出过哪些专辑"))
    println(client.chat("请背诵《卜算子·送鲍浩然之浙东》"))
    println(client.chat("在编程框架中，网络拦截器的作用是什么"))
    client.close()
}
