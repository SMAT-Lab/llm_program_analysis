package core.pie
public class BubbleEntry <: EntryOhos {
    private var mSize: Float64 = 0.0
    public init(x: Float64, y: Float64, size!: Float64 = 0.0, icon!: ?ChartPixelMap = Option<ChartPixelMap>.None, data!: ?Any = Option<Any>.None) {
        super(x, y, icon: icon, data: data);
        this.mSize = size
    }
    public func copy(): BubbleEntry {
        let data: ?Any = this.getData()
        if (let Some(d) <- data) {
            return BubbleEntry(this.getX(), this.getY(), size: this.mSize, data: data)
        } else {
            return BubbleEntry(this.getX(), this.getY(), size: this.mSize)
        }
    }
    public func getSize(): Float64 {
        return this.mSize
    }
    public func setSize(size: Float64): Unit {
        this.mSize = size
    }
}