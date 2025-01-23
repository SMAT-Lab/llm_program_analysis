package okhttp_okcj
public enum HttpMethod {
    GET |
    POST |
    PUT |
    DELETE |
    HEAD |
    PATCH |
    OPTIONS |
    TRACE
    public operator func == (that: HttpMethod): Bool {
        match ((this, that)) {
            case (GET, GET) => true
            case (POST, POST) => true
            case (PUT, PUT) => true
            case (DELETE, DELETE) => true
            case (HEAD, HEAD) => true
            case (PATCH, PATCH) => true
            case (OPTIONS, OPTIONS) => true
            case (TRACE, TRACE) => true
            case _ => false
        }
    }
    public operator func != (that: HttpMethod): Bool {
        return !(this == that)
    }
    public func toString(): String {
        return match(this) {
            case GET                => "GET"
            case POST          => "POST"
            case PUT               => "PUT"
            case DELETE   => "DELETE"
            case HEAD            => "HEAD"
            case PATCH       => "PATCH"
            case OPTIONS       => "OPTIONS"
            case TRACE       => "TRACE"
        }
    }
}