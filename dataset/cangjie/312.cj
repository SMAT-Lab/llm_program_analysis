package drawing
public interface GraphicContext <: PathBuilder {
    func beginPath(): Unit
    func getMatrixTransform(): Matrix
    func setMatrixTransform(tr: Matrix): Unit
    func composeMatrixTransform(tr: Matrix): Unit
    func rotate(angle: Float64): Unit
    func translate(tx: Float64, ty: Float64): Unit
    func scale(sx: Float64, sy: Float64): Unit
    func setStrokeColor(c: Color): Unit
    func setFillColor(c: Color): Unit
    func setFillRule(f: FillRule): Unit
    func setLineWidth(lineWidth: Float64): Unit
    func setLineCap(cap: LineCap): Unit
    func setLineJoin(join: LineJoin): Unit
    func setLineDash(dash: Array<Float64>, dashOffset: Float64): Unit
    func setFontSize(fontSize: Float64): Unit
    func setFontSize(): Float64
    func setFont(f: Font): Unit
    func gGetFont(): Font
    func drawImage(image: Image): Unit
    func save(): Unit
    func restore(): Unit
    func clear(): Unit
    func clearRect(x1: Int64, y1: Int64, x2: Int64, y2: Int64): Unit
    func setDPI(dpi: Int64): Unit
    func getDPI(): Int64
    func getStringBounds(s: String): (Float64, Float64, Float64, Float64)
    func createStringPath(text: String, x: Float64, y: Float64): Float64
    func fillString(text: String): Float64
    func fillStringAt(text: String, x: Float64, y: Float64): Float64
    func strokeString(text: String): Float64
    func strokeStringAt(text: String, x: Float64, y: Float64): Float64
    func stroke(paths: Array<Path>): Unit
    func fill(paths: Array<Path>): Unit
    func fillStroke(paths: Array<Path>): Unit
}