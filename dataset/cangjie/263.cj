package rpc4cj.http2.proto
internal import std.io.*
let errNilRequestURL: String = "http2: Request.URI is nil"
let errRequestHeaderListSize: String = "http2: request header list larger than peer's advertised limit"
let errReqBodyTooLong: String = "http2: request body larger than specified content length"
    // abort request body write; don't send cancel
let errStopReqBodyWrite: String = "http2: aborting request body write"
let errClientConnClosed: String = "http2: client conn is closed"
public class H2ClientStream {
    public let ID: Int64
    protected var cc: H2ClientConn
    var state: StreamState = IDLE
    protected let resp: H2Response
    protected let isEndStream: SyncQueue<Int8> = SyncQueue<Int8>()
    protected let isPushedStream: SyncQueue<Int8> = SyncQueue<Int8>()
    protected let isPushed: AtomicBool = AtomicBool(true)
    protected var req: ?H2Request = None
    protected var requestedGzip: Bool = false
    protected var sentEndStream: Bool = false
    protected var reqBody: ?InputStream
    protected var reqBodyContentLength: Int64 = 0
    protected var reqBodyClosed: Bool = false
    public var allHttp2Frame: LinkedListHttp2<Http2Frame> = LinkedListHttp2<Http2Frame>()
    protected var pushedFile: ?File = None
    protected var dataLength = 0
    public init (ids: Int64, cc: H2ClientConn, reqBody: InputStream) {
        this.ID = ids
        this.cc = cc
        this.state = IDLE
        this.reqBody = reqBody
        this.resp = H2Response(cc.decode)
        let bas: ByteBuffer = ByteBuffer(4096)
        let buffer: Array<Byte> = Array<Byte>(4096, repeat: 0)
        while (true) {
            let num: Int64 = reqBody.read(buffer)
            if (num < 4096) {
                bas.write(buffer[0..num])
                break
            }
            bas.write(buffer)
        }
        this.reqBodyContentLength = bas.length
        this.reqBody = bas
        cc.streamMap.put(ids, this)
    }
    public func rawCreatResponse() {
        this.resp.rawCreatResponse(this.req.getOrThrow())
    }
    public func rawCreateStreamResponse() {
        this.resp.doCreateStreamResponse(this.req.getOrThrow())
    }
    protected func clear() {
        allHttp2Frame.clear()
        pushedFile = None
        req = None
        match(reqBody) {
            case _ => ()
        }
        reqBody = None
    }
    public static func newStream(ids: Int64, cc: H2ClientConn, reqBody: InputStream): H2ClientStream {
        return H2ClientStream(ids, cc, reqBody)
    }
    func doRequestHttp2(req: H2Request): Unit {
        this.req = req
        let _: String = this.writeRequest(req)
    }
    protected func getFrames(): Collection<Http2Frame> {
        return allHttp2Frame
    }
    func encodeHeaders(req: H2Request, addGzipHeader: Bool, trailers: String, contentLength: Int64, _: Encoder): (Array<UInt8>, String) {
        if (req.url.toString().isEmpty()) {
            return (EMPTY_ARRAY, errNilRequestURL)
        }
        var host: String = req.url.hostName+":"+req.url.port
        if (host.isEmpty()) {
           host = req.url.hostName+":"+req.url.port
        }
        var (hostp, err): (String, String) = punycodeHostPort(host)
        host = hostp
        if (!err.isEmpty()) {
            return (EMPTY_ARRAY, err)
        }
        var path: String = req.url.path
        for ((k, vv) in req.header) {
            if (!validHeaderFieldName(k)) {
                return (EMPTY_ARRAY, "invalid HTTP header name ${k}")
            }
            for (v in vv) {
                if (!validHeaderFieldValue(v)) {
                    return (EMPTY_ARRAY, "invalid HTTP header value for header ${k}")
                }
            }
        }
        let arrHeaderField: LinkedListHttp2<HeaderField> = LinkedListHttp2<HeaderField>()
        var hlSize: Int64 = enumerateHeaders(host, path, req, addGzipHeader, trailers, contentLength, true, arrHeaderField)
        if (hlSize > cc.conf.MAX_HEADER_LIST_SIZE) {
            return (EMPTY_ARRAY, errRequestHeaderListSize)
        }
        this.enumerateHeaders(host, path, req, addGzipHeader, trailers, contentLength, false, arrHeaderField)
        let arrhbuf: Array<UInt8> = this.cc.encode.encode(arrHeaderField)
        return (arrhbuf, "")
    }
    func encodeStreamHeaders(streamreq: H2Request, addGzipHeader: Bool, trailers: String, _: Encoder): (Array<UInt8>, String) {
        if (streamreq.url.toString().isEmpty()) {
            return (EMPTY_ARRAY, errNilRequestURL)
        }
        var host: String = streamreq.url.hostName+":"+streamreq.url.port
        if (host.isEmpty()) {
            host = streamreq.url.hostName+":"+streamreq.url.port
        }
        var (hostp, err): (String, String) = punycodeHostPort(host)
        host = hostp
        if (!err.isEmpty()) {
            return (EMPTY_ARRAY, err)
        }
        var path: String = streamreq.requestURI
        if (!validPseudoPath(path)) {
            let orig: String = path
            path = path.removePrefix(streamreq.url.scheme+"://"+host)
            if (!validPseudoPath(path)) {
                if (!streamreq.url.opaque.isEmpty()) {
                    return (EMPTY_ARRAY, "invalid request :path ${orig} from URL.Opaque = ${streamreq.url.opaque}")
                } else {
                    return (EMPTY_ARRAY, "invalid request :path ${orig}")
                }
            }
        }
        for ((k, vv) in streamreq.header) {
            if (!validHeaderFieldName(k)) {
                return (EMPTY_ARRAY, "invalid HTTP header name ${k}")
            }
            for (v in vv) {
                if (!validHeaderFieldValue(v)) {
                    return (EMPTY_ARRAY, "invalid HTTP header value for header ${k}")
                }
            }
        }
        let arrHeaderField: LinkedListHttp2<HeaderField> = LinkedListHttp2<HeaderField>()
        var hlSize: Int64 = enumerateStreamHeaders(host, path, streamreq, addGzipHeader, trailers, true, arrHeaderField)
        if (hlSize > cc.conf.MAX_HEADER_LIST_SIZE) {
            return (EMPTY_ARRAY, errRequestHeaderListSize)
        }
        enumerateStreamHeaders(host, path, streamreq, addGzipHeader, trailers, false, arrHeaderField)
        let arrhbuf: Array<UInt8> = this.cc.encode.encode(arrHeaderField)
        return (arrhbuf, "")
    }
    private func enumerateHeaders(host: String, path: String, req: H2Request, addGzipHeader: Bool,
                                    trailers: String, contentLength: Int64, isFirst: Bool,
                                    arr: LinkedListHttp2<HeaderField>): Int64 {
        var hlSize: Int64 = 0
        hlSize += enumerateHeader(":authority", host, isFirst, arr)
        hlSize += enumerateHeader(":method", req.method.toString(), isFirst, arr)
        hlSize += enumerateHeader(":path", path, isFirst, arr)
        hlSize += enumerateHeader(":scheme", req.url.scheme, isFirst, arr)
        if (!trailers.isEmpty()) {
            hlSize += enumerateHeader("trailer", trailers, isFirst, arr)
        }
        let (hlnum, didUA, cleanUA): (Int64, Bool, Bool) = enumerateHeadersUtil(req, isFirst, arr)
        hlSize += hlnum
        if (shouldSendReqContentLength(req.method.toString(), contentLength)) {
            hlSize += enumerateHeader("content-length", formatInt(contentLength, 10), isFirst, arr)
        }
        if (addGzipHeader) {
            hlSize += enumerateHeader("accept-encoding", "gzip", isFirst, arr)
        }
        if (cleanUA) { req.header.del("User-Agent") }
        if (!didUA) {
            hlSize += enumerateHeader("user-agent", defaultUserAgent, isFirst, arr)
        }
        return hlSize
    }
    private func enumerateStreamHeaders(host: String, path: String, streamreq: H2Request, addGzipHeader: Bool,
                                    trailers: String, isFirst: Bool,
                                    arr: LinkedListHttp2<HeaderField>): Int64 {
        var hlSize: Int64 = 0
        hlSize += enumerateHeader(":authority", host, isFirst, arr)
        hlSize += enumerateHeader(":method", streamreq.method.toString(), isFirst, arr)
        hlSize += enumerateHeader(":path", path, isFirst, arr)
        hlSize += enumerateHeader(":scheme", streamreq.url.scheme, isFirst, arr)
        if (!trailers.isEmpty()) {
            hlSize += enumerateHeader("trailer", trailers, isFirst, arr)
        }
        let (hlnum, didUA, cleanUA): (Int64, Bool, Bool) = enumerateHeadersUtil(streamreq, isFirst, arr)
        hlSize += hlnum
        if (addGzipHeader) {
            hlSize += enumerateHeader("accept-encoding", "gzip", isFirst, arr)
        }
        if (cleanUA) { streamreq.header.del("User-Agent") }
        if (!didUA) {
            hlSize += enumerateHeader("user-agent", defaultUserAgent, isFirst, arr)
        }
        return hlSize
    }
    private func enumerateHeadersUtil(req: H2Request, isFirst: Bool, arr: LinkedListHttp2<HeaderField>): (Int64, Bool, Bool) {
        var hlSize: Int64 = 0
        var didUA: Bool = false
        var cleanUA: Bool = false
        for ((k, value) in req.header) {
            var vv: ArrayList<String> = collectArrayList<String>(value)
            if (asciiEqualFold(k, "host") || asciiEqualFold(k, "content-length")) {
                continue
            } else if (asciiEqualFold(k, "connection") ||
                asciiEqualFold(k, "proxy-connection") ||
                asciiEqualFold(k, "transfer-encoding") ||
                asciiEqualFold(k, "upgrade") ||
                asciiEqualFold(k, "keep-alive")) {
                continue
            } else if (asciiEqualFold(k, "user-agent")) {
                for (str in vv) {
                    if (str == "cangjie-http-client/1.1") {
                        cleanUA = true
                    }
                }
                if (!cleanUA) {
                    didUA = true
                    if (vv.size < 1) {
                        continue
                    }
                    vv = vv.slice(0 .. 1)
                    if (vv[0].isEmpty()) {
                        continue
                    }
                }
            } else if (asciiEqualFold(k, "cookie")) {
                hlSize += handleHeaderCookie(vv, isFirst, arr)
                continue
            }
            for (v in vv) {
                hlSize += enumerateHeader(k.toAsciiLower(), v, isFirst, arr)
            }
        }
        return (hlSize, didUA, cleanUA)
    }
    func handleHeaderCookie(vv: ArrayList<String>, isFirst: Bool, arr: LinkedListHttp2<HeaderField>): Int64 {
        var hlSize: Int64 = 0
        for (v in 0..vv.size) {
            var str: String = vv[v]
            while(true) {
                var p: Int64 = str.indexOf(";").getOrDefault({=> -1})
                if (p < 0) {
                    break
                }
                hlSize += enumerateHeader("cookie", str[0..p], isFirst, arr)
                p++
                while (p + 1 <= str.size && UInt32(str[p]) == UInt32(r' ')) {
                    p++
                }
                str = str[p..str.size]
            }
            if (str.size > 0) {
                hlSize += enumerateHeader("cookie", str, isFirst, arr)
            }
        }
        return hlSize
    }
    func enumerateHeader(name: String, value: String, isFirst: Bool, arr: LinkedListHttp2<HeaderField>): Int64 {
        var num: Int64 = 0
        if (isFirst) {
            num = name.size + value.size + 32
        } else {
            arr.append(HeaderField(name, value))
        }
        return num
    }
    func writeHeaders(streamID: Int64, endStream: Bool, maxFrameSize: Int64, hdrsArr: Array<UInt8>): Unit {
        // first frame written (HEADERS is first, then CONTINUATION)
        var first: Bool = true
        var hdrs: Array<UInt8> = hdrsArr
        while (hdrs.size > 0) {
            var chunk: Array<UInt8> = hdrs
            if (chunk.size > maxFrameSize) {
                chunk = chunk[0..maxFrameSize]
            }
            if (chunk.size == hdrs.size) {
                hdrs = Array<UInt8>()
            } else {
                hdrs = hdrs[chunk.size..hdrs.size]
            }
            let endHeaders: Bool = hdrs.size == 0
            if (first) {
                let headersFrame: Http2Frame = writeHeadersFrame(streamID, chunk, endStream, endHeaders, 0)
                this.allHttp2Frame.append(headersFrame)
                first = false
            } else {
                let continuationFrame: Http2Frame = writeContinuation(streamID, endHeaders, chunk)
                allHttp2Frame.append(continuationFrame)
            }
        }
    }
    // WriteData writes a DATA frame
    func writeData(streamID: Int64, endStream: Bool, chunk: Array<UInt8>, padLength: Int64): String {
        let dataFrame: Http2Frame = writeDataPadded(streamID, endStream, chunk, padLength)
        allHttp2Frame.append(dataFrame)
        this.dataLength += dataFrame.length + 9
        return ""
    }
    func encodeTrailers(trailer: HttpHeaders, encode: Encoder): (Array<UInt8>, String) {
        var hlSize: Int64 = 0
        for ((k, vv) in trailer) {
            for (v in vv) {
                hlSize += k.size + v.size + 32
            }
        }
        if (hlSize > cc.conf.MAX_HEADER_LIST_SIZE) {
            return (EMPTY_ARRAY, errRequestHeaderListSize)
        }
        for ((k, vv) in trailer) {
            let (lowKey, ascii): (String, Bool) = asciiToLower(k)
            if (!ascii) {
                continue
            }
            for (v in vv) {
                writeHeader(lowKey, v, encode)
            }
        }
        return (Array<Byte>(2028, repeat: 0), "")
    }
    func writeHeader(name: String, value: String, _: Encoder) {
        let hf: HeaderField = HeaderField(name, value)
        this.cc.encode.encode([hf])
    }
    private func writeRequest(req: H2Request): String {
        var err: String = ""
        let ae: Collection<String> = req.header.get("Accept-Encoding")
        let range: Collection<String> = req.header.get("Range")
        if (ae.size <= 0 && range.size <= 0) {
            requestedGzip = true
        }
        err = encodeAndWriteHeaders(req)
        if (!err.isEmpty()) {
            return err
        }
        if (reqBodyContentLength == 0) {
            sentEndStream = true
        } else {
            err = writeRequestBody(req)
            allHttp2Frame.append(WindowUpdateFrame(0, this.dataLength))
            allHttp2Frame.append(PING)
            if (!err.isEmpty()) {
                if (err != errStopReqBodyWrite) {
                    return err
                }
            } else {
                sentEndStream = true
            }
        }
        return err
    }
    func writeStreamRequest(req: H2Request): String {
        this.req = req
        var err: String = ""
        let ae: Collection<String> = req.header.get("Accept-Encoding")
        let range: Collection<String> = req.header.get("Range")
        if (ae.size <= 0 && range.size <= 0) {
            requestedGzip = true
        }
        err = encodeAndWriteStreamHeaders(req)
        if (!err.isEmpty()) {
            return err
        }
        sentEndStream = false
        return err
    }
    func encodeAndWriteStreamHeaders(streamReq: H2Request): String {
        sb.reset()
        var frist = true
        for ((name,_) in streamReq.trailer) {
            if (!frist) {
                sb.append(",")
            }
            frist = false
            let k: String = canonicalHeaderKey(name)
            if (k == "Transfer-Encoding" || k == "Trailer" || k == "Content-Length") {
                return "invalid Trailer key ${k}"
            }
            sb.append(k)
        }
        let (hdrs, errEH): (Array<UInt8>, String) = this.encodeStreamHeaders(streamReq, requestedGzip, sb.toString(),this.cc.encode)
        if (!errEH.isEmpty()) {
            return errEH
        }
        // Write the request.
        this.writeHeaders(ID, this.reqBodyContentLength == 0 && sb.size == 0, cc.conf.MAX_FRAME_SIZE, hdrs)
        return ""
    }
    func writeRequestBody(req: H2Request): String {
        var body: InputStream = this.reqBody.getOrThrow()
        var sentEnd: Bool = false // whether we sent the final DATA frame END_STREAM
        let trailerNum: Int64 = getHeaderSize(req.trailer)
        var remainLen: Int64 = reqBodyContentLength
        let hasContentLen: Bool = remainLen != -1
        let maxFrameSize: Int64 = Int64(cc.conf.MAX_FRAME_SIZE)
        let scratchLen: Int64 = frameScratchBufferLen(cc.conf.MAX_FRAME_SIZE)
        var buf: Array<Byte> = Array<Byte>(scratchLen, repeat: 0)
        var sawEOF: Bool = false
        while (!sawEOF) {
            let n: Int64 = body.read(buf)
            var err: String = ""
            if (hasContentLen) {
                remainLen -= n
                if (remainLen == 0) {
                    err = "EOF"
                }
                if (remainLen < 0) {
                    err = errReqBodyTooLong
                    return err
                }
            }
            if (!err.isEmpty()) {
                let bodyClosed: Bool = reqBodyClosed
                if (bodyClosed) {
                    return errStopReqBodyWrite
                } else if (err == "EOF") {
                    sawEOF = true
                    err = ""
                } else {
                    return err
                }
            }
            let (errFlag, sentEndFlag): (String, Bool) = writeRequestBodyUtil(n, buf, err, sentEnd, sawEOF, trailerNum)
            err = errFlag
            sentEnd = sentEndFlag
            if (!err.isEmpty()) {
                return err
            }
        }
        if (sentEnd) {
            return ""
        }
        return writeRequestBodyEnd(req, maxFrameSize, trailerNum)
    }
    func writeRequestBodyUtil(n: Int64, buf: Array<UInt8>, errFlag: String, sentEndFlag: Bool, sawEOF: Bool, trailerNum: Int64): (String, Bool) {
        var err: String = errFlag
        var sentEnd: Bool = sentEndFlag
        let hasTrailers: Bool = trailerNum != 0
        var remain: Array<UInt8> = buf[0..n]
        while (remain.size > 0 && err.isEmpty()) {
            var (allowed, erral): (Int64, String) = awaitFlowControl(remain.size)
            err = erral
            if (!err.isEmpty()) {
                return (err, sentEnd)
            }
            var data: Array<UInt8> = remain
            if (allowed < remain.size) {
                data = remain[0..allowed]
                remain = remain[allowed..remain.size]
            } else {
                remain = Array<UInt8>()
            }
            sentEnd = sawEOF && remain.size == 0 && !hasTrailers
            err = this.writeData(ID, sentEnd, data, 0)
        }
        if (!err.isEmpty()) {
            return (err, sentEnd)
        }
        return (err, sentEnd)
    }
    func writeRequestBodyEnd(req: H2Request, maxFrameSize: Int64, trailerNum: Int64): String {
        let trailer: HttpHeaders = req.trailer
        var trls: Array<UInt8> = Array<UInt8>()
        var err: String = ""
        if (trailerNum > 0) {
            let (trlsArr, errtrls): (Array<UInt8>, String) = this.encodeTrailers(trailer, this.cc.encode)
            trls = trlsArr
            err = errtrls
            if (!err.isEmpty()) {
                return err
            }
        }
        // Two ways to send END_STREAM: either with trailers, or with an empty DATA frame.
        if (trls.size > 0) {
            this.writeHeaders(ID, true, maxFrameSize, trls)
        } else {
            err = this.writeData(ID, true, Array<UInt8>(), 0)
        }
        return err
    }
    func awaitFlowControl(maxBytes: Int64): (Int64, String) {
        var take: Int64 = maxBytes
        if (cc.closed.load()) {
            return (0, errClientConnClosed)
        }
        if (reqBodyClosed) {
            return (0, errStopReqBodyWrite)
        }
        if (maxBytes > Int64(cc.conf.MAX_FRAME_SIZE)) {
            take = Int64(cc.conf.MAX_FRAME_SIZE)
        }
        return (take, "")
    }
    func frameScratchBufferLen(maxFrameSize: Int64): Int64 {
        let max: Int64 = 512 << 10
        var n: Int64 = Int64(maxFrameSize)
        if (n > max) {
            n = max
        }
        let cl: Int64 = reqBodyContentLength
        if (cl != -1 && (cl + 1) < n) {
            n = cl + 1
        }
        if (n < 1) {
            return 1
        }
        return n // doesn't truncate; max is 512K
    }
    let sb = StringBuilder()
    func encodeAndWriteHeaders(req: H2Request): String {
        sb.reset()
        var frist = true
        for ((name,_) in req.trailer) {
            if (!frist) {
                sb.append(",")
            }
            frist = false
            let k: String = canonicalHeaderKey(name)
            if (k == "Transfer-Encoding" || k == "Trailer" || k == "Content-Length") {
                return "invalid Trailer key ${k}"
            }
            sb.append(k)
        }
        let (hdrs, errEH): (Array<UInt8>, String) = this.encodeHeaders(req, requestedGzip, sb.toString(), this.reqBodyContentLength, this.cc.encode)
        if (!errEH.isEmpty()) {
            return errEH
        }
        // Write the request.
        this.writeHeaders(ID, this.reqBodyContentLength == 0 && sb.size == 0, cc.conf.MAX_FRAME_SIZE, hdrs)
        return ""
    }
}