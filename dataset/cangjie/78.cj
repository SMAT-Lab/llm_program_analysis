package opds_cj.path.opds.v2.libraries

public class LibrariesDetail {
    var metadata: Metadata
    var links: Links
    var navigation: Navigation
    var groups: ArrayList<Group> = ArrayList<Group>()
    public init(host!: String = "127.0.0.1", id!: String = "") {
        let libr = Librarys.fromId(id)
        metadata = Metadata("${libr.name} - Recommended", modified: libr.lastModifiedDate)
        links = Links(host, "libraries/${id}")
        navigation = Navigation(host, selfPath: "libraries/${id}")
        groups.append(initReading(host, id))
        groups.append(initSeries(host, id))
        groups.append(initBooks(host, id))
    }

    static func initReading(host: String, id: String): Group {
        var reading = Group()
        let readingList = Librarys.getReading(id, libraryId: id)
        reading.metadata = Metadata("Keep Reading", itemsPerPage: 5, currentPage: 1, numberOfItems: readingList.size)
        reading.links.append(
            Link(
                title: "Keep Reading",
                rel: "self",
                href: "http://${host}/opds/v2/libraries/${id}/keep-reading",
                type_u: "application/opds+json"
            )
        )
        for (i in readingList) {
            reading.publications.append(Publication(i, host))
        }
        return reading
    }

    static func initSeries(host: String, id: String): Group {
        var series = Group()
        series.metadata = Metadata("Latest Series", itemsPerPage: 5, currentPage: 1,
            numberOfItems: BookSeries.getCount())
        series.links.append(
            Link(
                title: "Latest Series",
                rel: "self",
                href: "http://${host}/opds/v2/libraries/${id}/series/latest",
                type_u: "application/opds+json"
            )
        )
        var obj = BookSeries.formDatabase(baseConfig.database, libId: id)
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

    static func initBooks(host: String, id: String): Group {
        var series = Group()
        series.metadata = Metadata("Latest Books", itemsPerPage: 5, currentPage: 1, numberOfItems: Books.getCount())
        series.links.append(
            Link(
                title: "Latest Books",
                rel: "self",
                href: "http://${host}/opds/v2/libraries/${id}/books/latest",
                type_u: "application/opds+json"
            )
        )
        var obj = Books.formDatabase(baseConfig.database, libId: id)
        for (i in obj) {
            series.publications.append(Publication(i, host))
        }
        return series
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