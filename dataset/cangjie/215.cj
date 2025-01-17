package core.bar
public class XBounds {
    public var mins: Int64 = 0
    public var maxs: Int64 = 0
    public var range: Int64 = 0
    public var mAnimator: ?ChartAnimator = None
    public init(animator: ChartAnimator) {
        this.mAnimator = animator
    }
    public func set<D,S,E>(
        chart: BarLineScatterCandleBubbleDataProvider<D,S,E>,
        dataSet: S
    ): Unit where D <: ChartData<S, E>, S <: IDataSet<E>, E <: EntryOhos{
        let getPhaseX: Float64 = if (let Some(m) <- this.mAnimator) {
            m.getPhaseX()
        } else {
            1.0
        }
        let phaseX: Float64 = max(0.0, min(1.0, getPhaseX))
        let low: Float64 = chart.getLowestVisibleX()
        let high: Float64 = chart.getHighestVisibleX()
        let entryFrom: ?E = dataSet.getEntryForXValue(low, Float64.NaN, rounding: Rounding.DOWN)
        let entryTo: ?E = dataSet.getEntryForXValue(high, Float64.NaN, rounding: Rounding.UP)
        if (entryFrom.isSome() && entryTo.isSome()) {
            this.mins = if (let Some(ef) <- entryFrom) {
                dataSet.getEntryIndexByEntry(ef)
            } else {
                0
            }
            this.maxs = if (let Some(et) <- entryTo) {
                dataSet.getEntryIndexByEntry(et)
            } else {
                0
            }
            this.range = Int64(floor(Float64(this.maxs - this.mins) * phaseX))
        }
    }
}
public abstract class BarLineScatterCandleBubbleRenderer <: DataRenderer {
    protected var mXBounds: ?XBounds = None
    public init(animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
        super(animator, viewPortHandler)
        if (let Some(m) <- this.mAnimator) {
            this.mXBounds = XBounds(m)
        }
    }
    protected func shouldDrawValues<S, E>(dataSet: S): Bool where S <: IDataSet<E>, E <: EntryOhos {
        return dataSet.isVisible() && (dataSet.isDrawValuesEnabled() || dataSet.isDrawIconsEnabled())
    }
    protected func isInBoundsX<E>(e: ?E, dataSet: IBarLineScatterCandleBubbleDataSet<E>): Bool where E <: EntryOhos {
        if (let Some(entry) <- e) {
            let entryIndex = dataSet.getEntryIndexByEntry(entry)
            if (entryIndex >= dataSet.getEntryCount() * (if (let Some(m) <- this.mAnimator) {
                Int64(m.getPhaseX())
            } else {
                1
            })) {
                return false
            } else {
                return true
            }
        }
        return false
    }
}