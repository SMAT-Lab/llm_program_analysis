package core.bubble
public class BubbleChartModel <: BarLineChartBaseModel<BubbleData, IBubbleDataSet, BubbleEntry> & BubbleDataProvider {
    public var context2d: ?CanvasRenderingContext2D = None;
    init() {
        super();
    }
    public static func build(): BubbleChartModel {
        let model: BubbleChartModel = BubbleChartModel()
        var mAnimator: ChartAnimator = ChartAnimator(model)
        model.mRenderer = BubbleChartRenderer(model, mAnimator, model.mViewPortHandler)
        model.setHighlighter(ChartHighlighter(model))
        return model
    }
    public func invalidate() {
        if (let Some(context2d) <- this.context2d) {
            this.onDraw(context2d);
        }
    }
    public func setContext2D(context2d: CanvasRenderingContext2D) {
        this.context2d = context2d
    }
    public func onChartSizeChanged(newWidth: Float64, newHeight: Float64, oldWidth: Float64, oldHeight: Float64) {
        super.onSizeChanged(newWidth, newHeight, oldWidth, oldHeight);
    }
    public func onDraw(c: CanvasRenderingContext2D): Unit {
        super.onDraw(c);
    }
    public func getBubbleData(): ?BubbleData {
        if (let Some(data: BubbleData) <- this.mData) {
            return data
        } else {
            return None;
        }
    }
}