package sdk.trace.samplers
from std import format.*
from std import convert.*
from std import sync.AtomicInt64
from std import sync.*
public interface ISampler {
    func shouldSample(): SamplingResult
    func getDescription(): String
    func new() {
        return this
    }
    static func recording(decision: SamplingDecision): Bool {
        SamplingDecision.RECORD_ONLY.equals(decision) || SamplingDecision.RECORD_AND_SAMPLE.equals(decision)
    }
    static func convert(recording: Bool): Int64 {
        if (recording) {
            return 1
        }
        return 0
    }
}
public enum AlwaysOffSampler <: ISampler {
    INSTANCE
    public override func shouldSample(): SamplingResult {
        SamplingResult.drop()
    }
    public override func getDescription(): String {
        "AlwaysOffSampler"
    }
}
public enum AlwaysOnSampler <: ISampler {
    INSTANCE
    public override func shouldSample(): SamplingResult {
        SamplingResult.recordAndSample()
    }
    public override func getDescription(): String {
        "AlwaysOnSampler"
    }
}
public class GloabalRatioBasedSampler <: ISampler {
    private let ratio: Int64
    private let description: String
    private var scope = AtomicInt64(0)
    private let base = 100
    private var left: Int64 = 0
    private var ratioFloat: Float64
    private let mtx = ReentrantMutex()
    //采样率精度1/10000检测，做大支持小数点后4
    public init(ratioFloat: Float64) {
        this.ratioFloat = ratioFloat
        this.ratio = Int64.parse((ratioFloat * Float64.parse(base.toString())).format("0.0"))
        this.left = base - ratio
        this.description = "GloabalRatioBased{" + ratio.toString() + "}"
    }
    public static func create(ratio: Float64): GloabalRatioBasedSampler {
        if (!(ratio < 0.0) && !(ratio > 1.0)) {
            return GloabalRatioBasedSampler(ratio)
        }
        throw Exception("ratio must be in range [0.0, 1.0]")
    }
    public override func shouldSample(): SamplingResult {
        synchronized(mtx) {
            if (scope.load() <= 0 && ratio != 0) {
                scope.fetchAdd(left)
                return SamplingResult.recordAndSample()
            } else {
                scope.fetchSub(ratio)
                return SamplingResult.drop()
            }
        }
    }
    public override func getDescription(): String {
        this.description
    }
    public override func new(): ISampler {
        return GloabalRatioBasedSampler(this.ratioFloat)
    }
}