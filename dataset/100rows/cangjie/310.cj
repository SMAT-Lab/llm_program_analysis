package httpclient2curl4cj
public class ConfigurableCurlBuilder <: CurlBuilder {
    public static let PART_CURL: Int64 = 0
    public static let PART_OPTIONS: Int64 = 1
    public static let PART_METHOD: Int64 = 2
    public static let PART_HEADERS: Int64 = 3
    public static let PART_CONTENT_TYPE: Int64 = 4
    public static let PART_BODY: Int64 = 5
    public static let PART_URL: Int64 = 6
    protected static let DEFAULT_PARTS_ORDER: Array<Int64> = Array<Int64>([PART_CURL, PART_OPTIONS, PART_METHOD, PART_HEADERS, PART_CONTENT_TYPE, PART_BODY, PART_URL])
    protected let partsOrder: Array<Int64>
    public init(request: Request, limit: Int64, headerModifiers: ArrayList<HeaderModifier>, options: Options, delimiter: String) {
        this(request, limit, headerModifiers, options, delimiter, DEFAULT_PARTS_ORDER)
    }
    public init(request: Request, limit: Int64, headerModifiers: ArrayList<HeaderModifier>, options: Options, delimiter: String, partsOrder: Array<Int64>) {
        super(request, limit, headerModifiers, options, delimiter)
        this.partsOrder = partsOrder;
    }
    public override func build(): String {
        var parts: ArrayList<String> = ArrayList<String>()
        for (part in partsOrder) {
            match (part) {
                case 0 => addCurl(parts)
                case 1 => addOptions(parts)
                case 2 => addMethod(parts)
                case 3 => addHeaders(parts)
                case 4 => addContentType(parts)
                case 5 => addBody(parts)
                case 6 => addUrl(parts)
                case _ => ()
            }
        }
        return StringUtil.join(delimiter, parts)
    }
    private func addCurl(parts: ArrayList<String>) {
        parts.append("curl")
    }
    private func addOptions(parts: ArrayList<String>) {
        parts.appendAll(options)
    }
    private func addMethod(parts: ArrayList<String>) {
        parts.append("-X " + method.toAsciiUpper())
    }
    private func addHeaders(parts: ArrayList<String>) {
        for (header in headers) {
            parts.append("-H " + "\"" + header.getName() + header.getValue() + "\"")
        }
    }
    private func addContentType(parts: ArrayList<String>) {
        if (let Some(v) <- contentType) {
            if (!containsName(CONTENT_TYPE, headers)) {
                parts.append("-H " + "\"" + CONTENT_TYPE + ":" + v + "\"")
            }
        }
    }
    private func addBody(parts: ArrayList<String>) {
        if (let Some(v) <- body) {
            parts.append("-d " + "'" + v + "'")
        }
    }
    private func addUrl(parts: ArrayList<String>) {
        parts.append("\"" + url + "\"")
    }
}