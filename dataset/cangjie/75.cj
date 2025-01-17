package opds_cj.path.opds.v2.libraries

class Reading {
    var metadata: Metadata
    var links: Links
    var publications: ArrayList<Publication> = ArrayList<Publication>()
    public init(host!: String = "127.0.0.1", userID!: String = "", page!: Int64 = 0) {
        var now = DateTime.now()
        metadata = Metadata("All libraries - Keep Reading", itemsPerPage: 20, currentPage: page + 1,
            numberOfItems: Librarys.getReadingCount(userID), modified: now.toString())
        links = Links(host, "libraries/keep-reading", page: page)
        var obj = Librarys.getReading(userID, page: page + 1, count: 20)
        for (i in obj) {
            publications.append(Publication(i, host))
        }
    }
    public init(id: String, host!: String = "127.0.0.1", userID!: String = "", page!: Int64 = 0) {
        let library = Librarys.fromId(id)
        var now = DateTime.now()
        metadata = Metadata("${library.name} - Keep Reading", itemsPerPage: 20, currentPage: page + 1,
            numberOfItems: Librarys.getReadingCount(userID), modified: now.toString())
        links = Links(host, "libraries/${id}/keep-reading", page: page)
        var obj = Librarys.getReading(userID, page: page + 1, count: 20, libraryId: id)
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