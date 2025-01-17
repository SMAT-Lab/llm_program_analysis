package opds_cj.path.opds.v2.libraries

import net.http.*
import opds_cj.router.PathMap
internal import std.{collection.*, time.*, convert.*, io.ByteBuffer, io.readToEnd}
internal import opds_cj.config.baseConfig
internal import opds_cj.data_stru.*
internal import encoding.{url.*, json.stream.*}

public func pathLoad(): PathMap {
    var pathMap = PathMap(
        "/opds/v2/libraries",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            var cataLog = CataLog(host: host)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(cataLog.toJson())
        }
    )

    pathMap.add(
        "/opds/v2/libraries/browse",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            var publisher = ""
            match (httpContext.request.url.query) {
                case Some(x) => publisher = x.trimStart("publisher=")
                case None => ()
            }
            var brower = Brower(host: host, publisher: publisher)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(brower.toJson())
        }
    )

    pathMap.add(
        "/opds/v2/libraries/:id/browse",
        {
            httpContext =>
            let id = httpContext.request.url.toString().split("/")[4]
            let host = httpContext.request.headers.get("host").toArray()[0]
            var publisher = ""
            match (httpContext.request.url.query) {
                case Some(x) => publisher = x.trimStart("publisher=")
                case None => ()
            }
            var brower = Brower(id, host: host, publisher: publisher)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(brower.toJson())
        }
    )

    pathMap.add(
        "/opds/v2/libraries/:id",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            let id = httpContext.request.url.toString().split("/")[4]
            var brower = LibrariesDetail(host: host, id: id)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(brower.toJson())
        }
    )

    pathMap.add(
        "/opds/v2/libraries/keep-reading",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            var page = 0
            match (httpContext.request.url.query) {
                case Some(x) => page = Int64.parse(x.trimStart("page="))
                case None => ()
            }
            let user = User(httpContext.request.headers.getFirst("Authorization"))
            if (user.id == "") {
                httpContext.responseBuilder.status(401).body("unauthorized".toArray())
                return
            }
            var brower = Reading(host: host, userID: user.id, page: page)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(brower.toJson())
        }
    )

    pathMap.add(
        "/opds/v2/libraries/:id/keep-reading",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            let id = httpContext.request.url.toString().split("/")[4]
            var page = 0
            match (httpContext.request.url.query) {
                case Some(x) => page = Int64.parse(x.trimStart("page="))
                case None => ()
            }
            let user = User(httpContext.request.headers.getFirst("Authorization"))
            if (user.id == "") {
                httpContext.responseBuilder.status(401).body("unauthorized".toArray())
                return
            }
            var brower = Reading(id, host: host, userID: user.id, page: page)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(brower.toJson())
        }
    )

    pathMap.add(
        "/opds/v2/libraries/:id/books/latest",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            let id = httpContext.request.url.toString().split("/")[4]
            var page = 0
            match (httpContext.request.url.query) {
                case Some(x) => page = Int64.parse(x.trimStart("page="))
                case None => ()
            }
            var brower = Latest(id, host: host, page: page)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(brower.toJson())
        }
    )

    pathMap.add(
        "/opds/v2/libraries/books/latest",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            var page = 0
            match (httpContext.request.url.query) {
                case Some(x) => page = Int64.parse(x.trimStart("page="))
                case None => ()
            }
            var brower = Latest(host: host, page: page)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(brower.toJson())
        }
    )

    pathMap.add(
        "/opds/v2/libraries/:id/series/latest",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            let id = httpContext.request.url.toString().split("/")[4]
            var page = 0
            match (httpContext.request.url.query) {
                case Some(x) => page = Int64.parse(x.trimStart("page="))
                case None => ()
            }
            var brower = Series(id, host: host, page: page)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(brower.toJson())
        }
    )

    pathMap.add(
        "/opds/v2/libraries/series/latest",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            var page = 0
            match (httpContext.request.url.query) {
                case Some(x) => page = Int64.parse(x.trimStart("page="))
                case None => ()
            }
            var brower = Series(host: host, page: page)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(brower.toJson())
        }
    )
    return pathMap
}
