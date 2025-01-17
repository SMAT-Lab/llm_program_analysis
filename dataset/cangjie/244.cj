package drawing
public class DashVertexConverter <: Flattener {
    let next: Flattener
    var x: Float64
    var y: Float64
    var distance: Float64
    let dash: Array<Float64>
    var currentDash: Int64
    var dashOffset: Float64
    public init(dash: Array<Float64>, dashOffset: Float64, flattener: Flattener) {
        this.dash = dash
        this.currentDash = 0
        this.dashOffset = dashOffset
        this.next = flattener
        this.x = 0.0
        this.y = 0.0
        this.distance = 0.0
    }
    public func lineTo(x: Float64, y: Float64): Unit {
        var rest = this.dash[this.currentDash] - this.distance
        while (rest < 0.0) {
            this.distance = this.distance - this.dash[this.currentDash]
            this.currentDash = (this.currentDash + 1) % this.dash.size
            rest = this.dash[this.currentDash] - this.distance
        }
        var d = computeDistance(this.x, this.y, x, y)
        while (d >= rest) {
            let k = rest / d
            let lx = this.x + k * (x - this.x)
            let ly = this.y + k * (y - this.y)
            if (this.currentDash % 2 == 0) {
                // line
                this.next.lineTo(lx, ly)
            } else {
                // gap
                this.next.end()
                this.next.moveTo(lx, ly)
            }
            d = d - rest
            (this.x, this.y) = (lx, ly)
            this.currentDash = (this.currentDash + 1) % this.dash.size
            rest = this.dash[this.currentDash]
        }
        this.distance = d
        if (this.currentDash % 2 == 0) {
            // line
            this.next.lineTo(x, y)
        } else {
            // gap
            this.next.end()
            this.next.moveTo(x, y)
        }
        if (this.distance >= this.dash[this.currentDash]) {
            this.distance = this.distance - this.dash[this.currentDash]
            this.currentDash = (this.currentDash + 1) % this.dash.size
        }
        (this.x, this.y) = (x, y)
    }
    public func moveTo(x: Float64, y: Float64): Unit {
        this.next.moveTo(x, y)
        (this.x, this.y) = (x, y)
        this.distance = this.dashOffset
        this.currentDash = 0
    }
    public func lineJoin(): Unit {
        this.next.lineJoin()
    }
    public func close(): Unit {
        this.next.close()
    }
    public func end(): Unit {
        this.next.end()
    }
}