package opds_cj.path.opds.v2.series

import net.http.*
import encoding.json.stream.*
import std.{io.ByteBuffer, io.readToEnd, collection.*, convert.*}
import opds_cj.config.baseConfig
import opds_cj.router.PathMap
import opds_cj.data_stru.*

class Series {
    var metadata: Metadata
    var links: Links
    var publications: ArrayList<Publication> = ArrayList<Publication>()
    public init(id: String, host!: String = "127.0.0.1", page!: Int64 = 0) {
        let series = BookSeries.fromId(id)
        metadata = Metadata(series.name, itemsPerPage: 20, currentPage: page + 1,
            numberOfItems: BookSeries.getCount(id: id), modified: series.lastModifiedDate)
        metadata.addBookDesc(id)
        links = Links(host, "series/${id}", page: page)
        var obj = Books.formDatabase(baseConfig.database, page: page + 1, count: 20, seriesId: id)
        for (i in obj) {
            publications.append(Publication(i, host))
        }
    }
    public func toJson(): String {
        let stream = ByteBuffer()
        let w = JsonWriter(stream)
        w.startObject()
        w.writeName("metadata").writeValue(metadata)
        w.writeName("links").writeValue(links)
        w.writeName("publications").writeValue<ArrayList<Publication>>(publications)
        w.endObject()
        w.flush()
        return String.fromUtf8(readToEnd(stream))
    }
}

public func pathLoad(): PathMap {
    var pathMap = PathMap(
        "/opds/v2/series/:id",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            let id = httpContext.request.url.path.split("/")[4]
            var page = 0
            match (httpContext.request.url.query) {
                case Some(x) => page = Int64.parse(x.trimStart("page="))
                case None => ()
            }
            var cataLog = Series(id, host: host, page: page)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(cataLog.toJson())
        }
    )

    return pathMap
}
