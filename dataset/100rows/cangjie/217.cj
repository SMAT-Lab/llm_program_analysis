// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from httpclient4cj import httpclient4cj.*
from encoding import url.*
from net import http.*
//覆盖设置cookie对报文的影响，Max-Age 为负数设置为最小值
main() {
    CookieUtil()
    let c = CookieUtil.parse(URL.parse("http://example.com/foo/bar/baz"),
        "acw_tc=0a324fb[ID]e76052a825b3fafab5db4e52bcc6530fe5a0e; path=/; HttpOnly; Max-Age=1800")
    println(c.getOrThrow().toSetCookieString())
}