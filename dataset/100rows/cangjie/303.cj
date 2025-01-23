package services.responseHandler
public class CopyPartResultHandler <: SaxHandler {
    private var curTag: String = ""
    private var elementText: String = ""
    private var lastModified = Option<DateTime>.None
    private var etag = ""
    public func startDocument(): Unit {
    }
    public func endDocument(): Unit {
    }
    public func startElement(name: String, attrs: ArrayList<XmlAttr>): Unit {
          println(attrs)
        curTag = name
    }
    public func getCopyPartResult(partNumber: Int64): CopyPartResult {
        var result: CopyPartResult = CopyPartResult(partNumber, etag, lastModified.getOrThrow())
        return result
    }
    public func endElement(name: String) {
        if ("LastModified" == name) {
            this.lastModified = ServiceUtils.parseIso8601Date(elementText)
        } else if ("ETag" == name) {
            etag = elementText
        }
    }
    public func characters(content: String): Unit {
        elementText = content
    }
}