package opds_cj.path.opds.v2.search

import net.http.*
import std.{time.*, convert.*, collection.*, io.ByteBuffer, io.readToEnd}
import encoding.json.stream.*
import opds_cj.config.baseConfig
import opds_cj.router.PathMap
import opds_cj.data_stru.*

class Search {
    var metadata: Metadata
    var links: Links
    var groups: ArrayList<Group> = ArrayList<Group>()
    public init(query: String, host!: String = "127.0.0.1") {
        var now = DateTime.now()
        metadata = Metadata("Search results", modified: now.toString())
        links = Links(host, "catalog", searchPage: true)
        initSeries(query, host: host)
    }

    func initSeries(query: String, host!: String = "127.0.0.1") {
        var group = Group()
        group.metadata = Metadata("Series")
        var obj = BookSeries.query(query)
        for (i in obj) {
            group
                .navigation
                .append(
                    Link(title: i.name, href: "http://${host}/opds/v2/series/${i.id}", type_u: "application/opds+json"))
        }
        this.groups.append(group)
    }

    public func toJson(): String {
        let stream = ByteBuffer()
        let w = JsonWriter(stream)
        w.startObject()
        w.writeName("metadata").writeValue(metadata)
        w.writeName("links").writeValue(links)
        w.writeName("groups").writeValue<ArrayList<Group>>(groups)
        w.endObject()
        w.flush()
        return String.fromUtf8(readToEnd(stream))
    }
}

public func pathLoad(): PathMap {
    var pathMap = PathMap(
        "/opds/v2/search",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            var query = ""
            match (httpContext.request.url.query) {
                case Some(x) => query = x.trimStart("query=")
                case None => ()
            }
            var cataLog = Search(query, host: host)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(cataLog.toJson())
        }
    )

    return pathMap
}
