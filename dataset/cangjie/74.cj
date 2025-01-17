package opds_cj.path.opds.v2.libraries

class Brower {
    var metadata: Metadata
    var links: Links
    var navigation: Navigation
    var groups: ArrayList<Group> = ArrayList<Group>()

    static func initSeries(host: String, publisher: String): Group {
        var series = Group()
        series.metadata = Metadata("Series")
        var obj: ArrayList<BookSeries>
        if (publisher != "") {
            obj = BookSeries.formPublisher(publisher)
        } else {
            let numberOfItems = BookSeries.getCount()
            obj = BookSeries.formDatabase(baseConfig.database, count: numberOfItems)
        }
        for (i in obj) {
            series.navigation.append(
                Link(
                    title: i.name,
                    href: "http://${host}/opds/v2/series/${i.id}",
                    type_u: "application/opds+json"
                )
            )
        }
        return series
    }

    static func initSeries(id: String, host: String, publisher: String): Group {
        var series = Group()
        series.metadata = Metadata("Series")
        var obj: ArrayList<BookSeries>
        if (publisher != "") {
            obj = BookSeries.formPublisher(publisher)
        } else {
            let numberOfItems = BookSeries.getCount(id: id)
            obj = BookSeries.formDatabase(baseConfig.database, count: numberOfItems, libId: id)
        }
        for (i in obj) {
            series.navigation.append(
                Link(
                    title: i.name,
                    href: "http://${host}/opds/v2/series/${i.id}",
                    type_u: "application/opds+json"
                )
            )
        }
        return series
    }

    static func initPublisher(host: String): Group {
        var publisher = Group()
        publisher.metadata = Metadata("Publisher")
        var obj = BookSeries.getPublishList()
        for (i in obj) {
            var arg = Form("publisher=${i}")
            publisher.navigation.append(
                Link(
                    title: i,
                    href: "http://${host}/opds/v2/libraries/browse?${arg.toEncodeString()}",
                    type_u: "application/opds+json"
                )
            )
        }
        return publisher
    }

    public init(host!: String = "127.0.0.1", publisher!: String = "") {
        var now = DateTime.now()
        metadata = Metadata("All libraries", modified: now.toString())
        links = Links(host, "libraries/browse")
        navigation = Navigation(host)
        groups.append(initSeries(host, publisher))
        groups.append(initPublisher(host))
    }

    public init(id: String, host!: String = "127.0.0.1", publisher!: String = "") {
        let libr = Librarys.fromId(id)
        metadata = Metadata(libr.name, modified: libr.lastModifiedDate)
        links = Links(host, "libraries/${id}/browse")
        navigation = Navigation(host, selfPath: "libraries/${id}")
        groups.append(initSeries(id, host, publisher))
        groups.append(initPublisher(host))
    }

    public func toJson(): String {
        let stream = ByteBuffer()
        let w = JsonWriter(stream)
        w.startObject()
        w.writeName("metadata").writeValue(metadata)
        w.writeName("links").writeValue(links)
        w.writeName("navigation").writeValue(navigation)
        w.writeName("groups").writeValue<ArrayList<Group>>(groups)
        w.endObject()
        w.flush()
        return String.fromUtf8(readToEnd(stream))
    }
}