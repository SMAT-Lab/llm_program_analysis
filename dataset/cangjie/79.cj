package opds_cj.path.opds.v2.libraries

import opds_cj.macros.*

@Json
class Series {
    var metadata: Metadata
    var links: Links
    var navigation: ArrayList<Link> = ArrayList<Link>()
    public init(host!: String = "127.0.0.1", page!: Int64 = 0) {
        var now = DateTime.now()
        metadata = Metadata("All libraries - Latest Series", itemsPerPage: 20, currentPage: page + 1,
            numberOfItems: BookSeries.getCount(), modified: now.toString())
        links = Links(host, "libraries/series/latest", page: page)
        var obj = BookSeries.formDatabase(baseConfig.database, page: page, count: 20)
        for (i in obj) {
            navigation.append(
                Link(
                    title: i.name,
                    href: "http://${host}/opds/v2/series/${i.id}",
                    type_u: "application/opds+json"
                )
            )
        }
    }
    public init(id: String, host!: String = "127.0.0.1",  page!: Int64 = 0) {
        let library = Librarys.fromId(id)
        var now = DateTime.now()
        metadata = Metadata("${library.name} - Latest Series", itemsPerPage: 20, currentPage: page + 1,
            numberOfItems: BookSeries.getCount(id: id), modified: now.toString())
        links = Links(host, "libraries/${id}/series/latest", page: page)
        var obj = BookSeries.formDatabase(baseConfig.database, page: page, count: 20, libId: id)
        for (i in obj) {
            navigation.append(
                Link(
                    title: i.name,
                    href: "http://${host}/opds/v2/series/${i.id}",
                    type_u: "application/opds+json"
                )
            )
        }
    }
}