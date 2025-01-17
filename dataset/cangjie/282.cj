// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from std import collection.*
from std import fs.*
from oauth4cj import oauth4cj.*
from httpclient4cj import httpclient4cj.*
main() {
    var test_01 = testOkHttpHttpClient_01()
    if (test_01 != 0){
        println(test_01)
        return test_01
    }
    test_01 = testOkHttpHttpClient_02()
    if (test_01 != 0){
        println(test_01)
        return test_01
    }
    test_01 = testOkHttpHttpClient_03()
    if (test_01 != 0){
        println(test_01)
        return test_01
    }
    test_01 = testOkHttpHttpClient_04()
    if (test_01 != 0){
        println(test_01)
        return test_01
    }
    test_01 = testOkHttpHttpClient_05()
    if (test_01 != 0){
        println(test_01)
        return test_01
    }
    test_01 = testOkHttpHttpClient_06()
    if (test_01 != 0){
        println(test_01)
        return test_01
    }
    test_01 = testOkHttpHttpClient_07()
    if (test_01 != 0){
        println(test_01)
        return test_01
    }
    return test_01
}
public func testOkHttpHttpClient_01(): Int32 {
    let config: OkHttpHttpClientConfig = OkHttpHttpClientConfig(httpclient4cj.HttpClient.builder())
    let client: OkHttpHttpClient = OkHttpHttpClient(config)
    try {
        let headers: HashMap<String, String> = HashMap<String, String>()
        headers.put(OAuthConstants.CONTENT_TYPE, "application/x-www-form-urlencoded")
        let res: Future<Any> = client.executeAsync("", headers, Verb.POST,
                                "http://127.0.0.1:8080/", Array<UInt8>(), None, None)
        res.get(1000 * 1000)
    } catch (e: Exception) {
        //e.printStackTrace()
        println(1)
        return 1
    }
    return 0
}
public func testOkHttpHttpClient_02(): Int32 {
    let config: OkHttpHttpClientConfig = OkHttpHttpClientConfig(httpclient4cj.HttpClient.builder())
    let client: OkHttpHttpClient = OkHttpHttpClient(config)
    try {
        let res: Future<Any> = client.executeAsync("", HashMap<String, String>(), Verb.GET,
                                "http://127.0.0.1:8080/", "", None, None)
        res.get(1000 * 1000)
    } catch (e: Exception) {
        //e.printStackTrace()
        println(2)
        return 2
    }
    return 0
}
public func testOkHttpHttpClient_03(): Int32 {
    let config: OkHttpHttpClientConfig = OkHttpHttpClientConfig(httpclient4cj.HttpClient.builder())
    let client: OkHttpHttpClient = OkHttpHttpClient(config)
    let filePath: Path = Path("./tempFile.txt")
    let file: File = File(filePath, OpenOption.Create(false))
    try {
        let res: Future<Any> = client.executeAsync("", HashMap<String, String>(), Verb.GET,
                                "http://127.0.0.1:8080/", file, None, None)
        res.get(1000 * 1000)
    } catch (e: Exception) {
        //e.printStackTrace()
        println(3)
        return 3
    } finally {
        file.close()
        File.delete(filePath)
    }
    return 0
}
public func testOkHttpHttpClient_04(): Int32 {
    let config: OkHttpHttpClientConfig = OkHttpHttpClientConfig(httpclient4cj.HttpClient.builder())
    let client: OkHttpHttpClient = OkHttpHttpClient(config)
    try {
        client.execute("", HashMap<String, String>(), Verb.GET, "http://127.0.0.1:8080/", "")
    } catch (e: Exception) {
        //e.printStackTrace()
        return 0
    }
    println(4)
    return 4
}
public func testOkHttpHttpClient_05(): Int32 {
    let config: OkHttpHttpClientConfig = OkHttpHttpClientConfig(httpclient4cj.HttpClient.builder())
    let client: OkHttpHttpClient = OkHttpHttpClient(config)
    let filePath: Path = Path("./tempFile.txt")
    let file: File = File(filePath, OpenOption.Create(false))
    try {
        client.execute("", HashMap<String, String>(), Verb.GET, "http://127.0.0.1:8080/", file)
    } catch (e: Exception) {
        //e.printStackTrace()
        return 0
    } finally {
        file.close()
        File.delete(filePath)
    }
    println(5)
    return 5
}
public func testOkHttpHttpClient_06(): Int32 {
    let config: OkHttpHttpClientConfig = OkHttpHttpClientConfig(httpclient4cj.HttpClient.builder())
    let client: OkHttpHttpClient = OkHttpHttpClient(config)
    try {
        client.execute("", HashMap<String, String>(), Verb.POST, "http://127.0.0.1:8080/", "")
    } catch (e: Exception) {
        //e.printStackTrace()
        return 0
    }
    println(6)
    return 6
}
public func testOkHttpHttpClient_07(): Int32 {
    let config: OkHttpHttpClientConfig = OkHttpHttpClientConfig(httpclient4cj.HttpClient.builder())
    let client: OkHttpHttpClient = OkHttpHttpClient(config)
    let filePath: Path = Path("./tempFile.txt")
    let file: File = File(filePath, OpenOption.Create(false))
    try {
        client.execute("", HashMap<String, String>(), Verb.POST, "http://127.0.0.1:8080/", file)
    } catch (e: Exception) {
        //e.printStackTrace()
        return 0
    } finally {
        file.close()
        File.delete(filePath)
    }
    println(7)
    return 7
}