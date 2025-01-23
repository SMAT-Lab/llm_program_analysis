package exporter
from std import collection.HashMap
import api.trace.IExporter
public class WebGateHttpExporter <: IExporter {
    private var headerValue: HashMap<String, String> = HashMap<String, String>()
    private var timeOutValue: Int64 = 3000
    private var endPointValue: String = ""
    private static let logger = ApmLogger("exporter.FileExporter")
    public override prop name: String {
        get() {
            return "webgate-http"
        }
    }
    public mut override prop timeOut: Int64 {
        get() {
            return timeOutValue
        }
        set(value) {
            timeOutValue = value
        }
    }
    public mut override prop endPoint: String {
        get() {
            return endPointValue
        }
        set(value) {
            endPointValue = value
        }
    }
    public mut override prop header: HashMap<String, String> {
        get() {
            return headerValue
        }
        set(value) {
            headerValue = value
        }
    }
    public override func export(traces: ArrayList<ITracer>): Bool {
        //webgate上报逻辑（二期），暂时日志输出
        for (trace in traces) {
            logger.info("wg exportor: ${trace}")
        }
        true
    }
    public override func shutdown(): Bool {
        true
    }
    public static func builder(): WebGateHttpExporterBuilder {
        return WebGateHttpExporterBuilder()
    }
}
public class WebGateHttpExporterBuilder {
    let exporter: WebGateHttpExporter
    public init() {
        exporter = WebGateHttpExporter()
    }
    public func setTimeOut(timeOut: Int64) {
        exporter.timeOut = timeOut
        return this;
    }
    public func setEndPoint(endPoint: String) {
        exporter.endPoint = endPoint
        return this;
    }
    public func setHeader(header: HashMap<String, String>) {
        exporter.header = header
        return this;
    }
    public func build() {
        return exporter
    }
}