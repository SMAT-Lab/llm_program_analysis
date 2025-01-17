package opds_cj.path.opds.v2.libraries

class Latest {
    var metadata: Metadata
    var links: Links
    var publications: ArrayList<Publication> = ArrayList<Publication>()
    public init(host!: String = "127.0.0.1", page!: Int64 = 0) {
        var now = DateTime.now()
        metadata = Metadata("All libraries - Latest Books", itemsPerPage: 20, currentPage: page + 1,
            numberOfItems: Books.getCount(), modified: now.toString())
        links = Links(host, "libraries/books/latest", page: page)
        var obj = Books.formDatabase(baseConfig.database, page: page + 1, count: 20)
        for (i in obj) {
            publications.append(Publication(i, host))
        }
    }
    public init(id: String, host!: String = "127.0.0.1",  page!: Int64 = 0) {
        let library = Librarys.fromId(id)
        var now = DateTime.now()
        metadata = Metadata("${library.name} - Latest Books", itemsPerPage: 20, currentPage: page + 1,
            numberOfItems: Books.getCount(libraryId: id), modified: now.toString())
        links = Links(host, "libraries/${id}/books/latest", page: page)
        var obj = Books.formDatabase(baseConfig.database, page: page + 1, count: 20, libId: id)
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