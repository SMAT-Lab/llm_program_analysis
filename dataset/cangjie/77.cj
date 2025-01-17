package opds_cj.path.opds.v2.libraries

public class CataLog {
    var metadata: Metadata
    var links: Links
    var navigation: Navigation
    var groups: ArrayList<Group> = ArrayList<Group>()
    public init(host!: String = "127.0.0.1") {
        var now = DateTime.now()
        metadata = Metadata("All libraries - Recommended", modified: now.toString())
        links = Links(host, "libraries")
        navigation = Navigation(host)
        groups.append(initLibrarys(host))
        groups.append(initSeries(host))
        groups.append(initBooks(host))
    }

    static func initSeries(host: String): Group {
        var series = Group()
        series.metadata = Metadata("Latest Series", itemsPerPage: 5, currentPage: 1,
            numberOfItems: BookSeries.getCount())
        series.links.append(
            Link(
                title: "Latest Series",
                rel: "self",
                href: "http://${host}/opds/v2/libraries/series/latest",
                type_u: "application/opds+json"
            )
        )
        var obj = BookSeries.formDatabase(baseConfig.database)
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

    static func initLibrarys(host: String): Group {
        var libraries = Group()
        libraries.metadata = Metadata("Libraries")
        libraries.links.append(
            Link(
                rel: "self",
                href: "http://${host}/opds/v2/libraries"
            )
        )
        var obj = Librarys.formDatabase(baseConfig.database)
        for (i in obj) {
            libraries.navigation.append(
                Link(
                    title: i.name,
                    href: "http://${host}/opds/v2/libraries/${i.id}",
                    type_u: "application/opds+json"
                )
            )
        }
        return libraries
    }

    static func initBooks(host: String): Group {
        var series = Group()
        series.metadata = Metadata("Latest Books", itemsPerPage: 5, currentPage: 1, numberOfItems: Books.getCount())
        series.links.append(
            Link(
                title: "Latest Books",
                rel: "self",
                href: "http://${host}/opds/v2/libraries/books/latest",
                type_u: "application/opds+json"
            )
        )
        var obj = Books.formDatabase(baseConfig.database)
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