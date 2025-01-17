package drawing
public class FtLineBuilder <: Flattener {
    public let adder: Adder
    public init(adder: Adder) {
        this.adder = adder
    }
    public func lineTo(x: Float64, y: Float64): Unit {
        this.adder.add1(Point26_6(Int32(x * 64.0), Int32(y * 64.0)))
    }
    public func moveTo(x: Float64, y: Float64): Unit {
        this.adder.start(Point26_6(Int32(x * 64.0), Int32(y * 64.0)))
    }
    public func lineJoin(): Unit {
    }
    public func close(): Unit {
    }
    public func end(): Unit {
    }
}