package opds_cj.path.api.v1.books

import std.{collection.*,io.*}
import encoding.json.stream.*

class Manifest{
    var metadata: Metadata
    var links: ArrayList<Link> = ArrayList<Link>()
    var readingOrder: ReadingOrder
    var resources: ArrayList<Link> = ArrayList<Link>()
    public init(id: String,host: String){
        let book = Books.formID(id)
        this.metadata = Metadata(book.name,
                                conformsTo: "https://readium.org/webpub-manifest/schema/webpub-manifest.jsonld",
                                modified: book.lastModifiedDate,
                                numberOfPages: book.getPageCount())
        this.metadata.addSeriesBelongTo(book)
        this.links.append(Link(rel: "self", 
                               href: "http://${host}/api/v1/books/${id}/manifest", 
                               type_u: "application/divina+json"))
        this.links.append(Link(rel: "http://opds-spec.org/acquisition", 
                               href: "http://${host}/api/v1/books/${id}/file", 
                               type_u: "application/vnd.comicbook+zip"))
        this.readingOrder = ReadingOrder(id,host,book.getPageCount())
        this.resources.append(Link(href: "http://${host}/api/v1/books/${id}/thumbnail", 
                                   type_u: "image/jpeg"))
    }
    public func toJson(): String {
        let stream = ByteBuffer()
        let w = JsonWriter(stream)
        w.startObject()
        w.writeName("context").writeValue("https://readium.org/webpub-manifest/context.jsonld")
        w.writeName("metadata").writeValue(metadata)
        w.writeName("links").writeValue<ArrayList<Link>>(links)
        w.writeName("images").startArray()
        w.endArray()
        w.writeName("readingOrder").writeValue(readingOrder)
        w.writeName("resources").writeValue<ArrayList<Link>>(resources)
        w.writeName("toc").startArray()
        w.endArray()
        w.writeName("landmarks").startArray()
        w.endArray()
        w.writeName("pageList").startArray()
        w.endArray()
        w.endObject()
        w.flush()
        return String.fromUtf8(readToEnd(stream))
    }        
}

class ReadingOrder <: JsonSerializable{
    var pages: ArrayList<Page> = ArrayList<Page>()
    var host: String = ""
    var id: String = ""
    init(id: String,host: String,count: Int64) {
        this.host = host
        this.id = id
        for (i in 1..=count) {
            this.pages.append(Page.getPage(id, i, ""))
        }
    }
    public func toJson(w: JsonWriter): Unit {
        w.startArray()
        for (i in 0..pages.size) {
            w.startObject()
            w.writeName("href").writeValue("http://${host}/api/v1/books/${id}/pages/${i+1}")
            w.writeName("type").writeValue("image/${pages[i].format}")
            w.writeName("width").writeValue(pages[i].width)
            w.writeName("height").writeValue(pages[i].height)
            if (pages[i].format != "jpeg"){
                w.writeName("alternate").startArray()
                w.startObject()
                w.writeName("href").writeValue("http://${host}/api/v1/books/${id}/pages/${i+1}?convert=jpeg")
                w.writeName("type").writeValue("image/jpeg")
                w.writeName("width").writeValue(pages[i].width)
                w.writeName("height").writeValue(pages[i].height)
                w.endObject()
                w.endArray()
            }
            w.endObject()   
        }
        w.endArray()
    }
}