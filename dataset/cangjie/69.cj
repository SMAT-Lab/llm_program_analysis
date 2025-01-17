package opds_cj.path.api.v1.books

import std.{io.*,fs.*,convert.*}
import net.http.*
import opds_cj.router.PathMap
import opds_cj.config.baseConfig
internal import opds_cj.data_stru.*

public func pathLoad(): PathMap {
    var pathMap = PathMap(
        "/api/v1/books/:id/thumbnail",
        {
            httpContext =>
            let id = httpContext.request.url.toString().split("/")[4]
            let data = Books.getThumb(id)
            httpContext.responseBuilder.header("content-type", Books.getThumbType(id))
            httpContext.responseBuilder.body(data)
        }
    )
    pathMap.add(
        "/api/v1/books/:id/file",
        {
            httpContext =>
            let id = httpContext.request.url.toString().split("/")[4]
            let data = baseConfig.getFileURL(Books.getFile(id))
            let path = data.split("/")
            httpContext.responseBuilder.header("content-disposition", "attachment; filename=" + path[path.size - 1])
            httpContext.responseBuilder.header("content-type", Books.getFileType(id))
            httpContext.responseBuilder.body(File.readFrom(data))
        }
    )

    pathMap.add(
        "/api/v1/books/:id/pages/:page",
        {
            httpContext =>
            let id = httpContext.request.url.toString().split("/")[4]
            let page = Int64.parse(httpContext.request.url.path.split("/")[6])
            var convert = ""
            match (httpContext.request.url.query) {
                case Some(x) => convert = x.trimStart("convert=")
                case None => ()
            }
            let pageImage = Page.getPage(id, page, convert)
            pageImage.readFile()
            httpContext.responseBuilder.header("content-type", "image/${pageImage.format}")
            httpContext.responseBuilder.body(pageImage.data.toArray())
        }
    )
    pathMap.add(
        "/api/v1/books/:id/manifest",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            let id = httpContext.request.url.path.split("/")[4]
            var manifest= Manifest(id, host)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(manifest.toJson())
        }
    )
    return pathMap
}
