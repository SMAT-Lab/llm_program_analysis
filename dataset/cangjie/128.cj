package rpc4cj.http2.proto
internal import std.log.*
let initialHeaderTableSize: Int64 = 4096
let initEnablePush: Int64 = 0
let defaultMaxConcurrentStreams = 100
let globalinitialWindowSize: Int64 = 65535 // 6.9.2 Initial Flow Control Window Size
let initialMaxFrameSize: Int64 = 16384
let initialMaxHeadListSize = 1048896
public class H2Config {
    private var headerTableSize: Int64
    private var enablePush: Int64
    private var maxConcurrentStreams: Int64
    private var initialWindowSize: Int64
    private var maxFrameSize: Int64
    private var maxHeaderListSize: Int64
    public mut prop HEADER_TABLE_SIZE: Int64 {
        get() {
            return headerTableSize
        }
        set(v) {
            if (v > 0) {
                headerTableSize = v
            } else {
                throw Exception()
            }
        }
    }
    public mut prop ENABLE_PUSH: Int64 {
        get () {
            return enablePush
        }
        set (v) {
            if (v == 0 || v == 1) {
                enablePush = v
            } else {
                throw ProtocolErrorException("Any value other than 0 or 1 must be considered PROTOCOL_ ERROR type connection error (Section 5.4.1).")  //
            }
        }
    }
    // The value of 0 is prohibit the creation of new streams
    public mut prop MAX_CONCURRENT_STREAMS: Int64 {
        get () {
            return maxConcurrentStreams
        }
        set (v) {
            if (v >= 0) {
                maxConcurrentStreams = v
            } else {
                throw ProtocolErrorException()
            }
        }
    }
    public mut prop INITIAL_WINDOW_SIZE: Int64 {
        get () {
            return initialWindowSize
        }
        set (v) {
            if (v >= 0 && v <= Int64(Int32.Max)) {
                initialWindowSize = v
            } else {
                throw FlowControlErrorException()
            }
        }
    }
    public mut prop MAX_FRAME_SIZE: Int64 {
        get () {
            return maxFrameSize
        }
        set (v) {
            if (v > 16777215 || v < 16384) {
                throw ProtocolErrorException("The value of the endpoint broadcast must be between this initial value and the maximum allowed frame size (2 ^ 24-1 or 16777215 octets), including both. Values outside this range must be considered PROTOCOL_ ERROR type connection error (Section 5.4.1).")
            }
            maxFrameSize = v
        }
    }
    public mut prop MAX_HEADER_LIST_SIZE: Int64 {
        get () {
            return maxHeaderListSize
        }
        set (v) {
            if (v > 0) {
                maxHeaderListSize = v
            } else {
                throw ProtocolErrorException()
            }
        }
    }
    public init (){
        this.headerTableSize = initialHeaderTableSize
        this.enablePush = 1
        this.maxConcurrentStreams = defaultMaxConcurrentStreams
        this.initialWindowSize = globalinitialWindowSize
        this.maxFrameSize = initialMaxFrameSize
        this.maxHeaderListSize = initialMaxHeadListSize
    }
    public init(headerTableSize: Int64, enablePush: Int64, maxConcurrentStreams: Int64, initialWindowSize: Int64, maxFrameSize: Int64, maxHeaderListSize: Int64) {
        this.headerTableSize = if (headerTableSize > 0) {
            headerTableSize
        } else {
            throw Exception()
        }
        this.enablePush = if (enablePush == 0 || enablePush == 1) {
            enablePush
        } else {
            throw ProtocolErrorException("Any value other than 0 or 1 must be considered PROTOCOL_ ERROR type connection error (Section 5.4.1).")  //
        }
        this.maxConcurrentStreams = if (maxConcurrentStreams >= 0) {
            maxConcurrentStreams
        } else {
            throw ProtocolErrorException()
        }
        this.initialWindowSize = if (initialWindowSize >= 0 && initialWindowSize <= Int64(Int32.Max)) {
            initialWindowSize
        } else {
            throw FlowControlErrorException()
        }
        this.maxFrameSize = if (maxFrameSize > 16777215 || maxFrameSize < 16384) {
            throw ProtocolErrorException("The value of the endpoint broadcast must be between this initial value and the maximum allowed frame size (2 ^ 24-1 or 16777215 octets), including both. Values outside this range must be considered PROTOCOL_ ERROR type connection error (Section 5.4.1).")
        }else {
            maxFrameSize
        }
        this.maxHeaderListSize = if (maxHeaderListSize > 0) {
            maxHeaderListSize
        } else {
            throw ProtocolErrorException()
        }
    }
    public operator func [](key: Int64, value!: Int64): Unit{
        match (key) {
            case 0x01 => this.HEADER_TABLE_SIZE = value
            case 0x02 => this.ENABLE_PUSH = value
            case 0x03 => this.MAX_CONCURRENT_STREAMS = value
            case 0x04 => this.INITIAL_WINDOW_SIZE = value
            case 0x05 => this.MAX_FRAME_SIZE = value
            case 0x06 => this.MAX_HEADER_LIST_SIZE = value
            case _ => throw ProtocolErrorException()
        }
    }
    public operator func [](key: Int64): Int64 {
        return match (key) {
            case 0x01 => this.HEADER_TABLE_SIZE
            case 0x02 => this.ENABLE_PUSH
            case 0x03 => this.MAX_CONCURRENT_STREAMS
            case 0x04 => this.INITIAL_WINDOW_SIZE
            case 0x05 => this.MAX_FRAME_SIZE
            case 0x06 => this.MAX_HEADER_LIST_SIZE
            case _ => throw ProtocolErrorException()
        }
    }
}
// PROTOCOL_ERROR
public class ProtocolErrorException <: Exception {
    public init(){
        super()
    }
    public init(string: String) {
        super("ProtocolErrorException: ${string}")
    }
}
// FLOW_CONTROL_ERROR
public class FlowControlErrorException <: Exception {
    public init(){
        super()
    }
    public init(string: String) {
        super("FlowControlErrorException: ${string}")
    }
}
// FRAME_SIZE_ERROR
public class FrameSizeErrorException <: Exception {
    public init(){
        super()
    }
    public init(string: String) {
        super("FrameSizeErrorException: ${string}")
    }
}