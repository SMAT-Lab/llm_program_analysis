package core.bar
public open class BarChartRenderer <: BarLineScatterCandleBubbleRenderer {
    public var mChart: BarDataProvider
    protected var mBarRect: MyRect = MyRect()
    protected var mBarBuffers: Array<BarBuffer> = Array<BarBuffer>()
    protected var mShadowPaint: Paint
    protected var mBarBorderPaint: Paint
    public init(chart: BarDataProvider, animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
        super(animator, viewPortHandler)
        this.mChart = chart
        this.mHighlightPaint = Paint()
        this.mHighlightPaint.setStyle(Style.FILL)
        this.mHighlightPaint.setColor(Color.BLACK)
        // set alpha after color
        this.mHighlightPaint.setGlobalAlpha(120.0 / 255.0)
        this.mShadowPaint = Paint()
        this.mShadowPaint.setStyle(Style.FILL)
        this.mBarBorderPaint = Paint()
        this.mBarBorderPaint.setStyle(Style.STROKE)
    }
    public open func initBuffers(): Unit {
        let barData: ?BarData = this.mChart.getBarData()
        match (barData) {
            case Some(bardata) =>
                mBarBuffers = Array<BarBuffer>(bardata.getDataSetCount(), item: BarBuffer(0, 0, false))
                for (i in 0..this.mBarBuffers.size) {
                    let dataSet: ?IBarDataSet = bardata.getDataSetByIndex(i)
                    match (dataSet) {
                        case Some(dataset) =>
                            let size = if (dataset.isStacked()) {
                                dataset.getStackSize()
                            } else {
                                1
                            }
                            mBarBuffers[i] =
                                BarBuffer(dataset.getEntryCount() * 4 * size, bardata.getDataSetCount(),
                                dataset.isStacked())
                        case _ => ()
                    }
                }
            case _ => ()
        }
    }
    public func drawData(c: CanvasRenderingContext2D): Unit {
        let barData: ?BarData = this.mChart.getBarData()
        match (barData) {
            case Some(bardata) => for (i in 0..bardata.getDataSetCount()) {
                let set: ?IBarDataSet = bardata.getDataSetByIndex(i)
                match (set) {
                    case Some(ibardataset) => if (ibardataset.isVisible()) {
                        this.drawDataSet(c, ibardataset, i)
                    }
                    case _ => ()
                }
            }
            case _ => ()
        }
    }
    protected var mBarShadowRectBuffer: MyRect = MyRect()
    private func drawDataSetFunc(index: Int64, phaseX: Float64, phaseY: Float64, dataSet: IBarDataSet,
        c: CanvasRenderingContext2D, trans: ?Transformer): Unit {
        // initialize the buffer
        let buffer: BarBuffer = this.mBarBuffers[index]
        buffer.setPhases(phaseX, phaseY)
        buffer.setDataSet(index)
        buffer.setInverted(this.mChart.isInverted(dataSet.getAxisDependency()))
        let barData: ?BarData = this.mChart.getBarData()
        if (let Some(bar) <- barData) {
        	buffer.setBarWidth(bar.getBarWidth())
        }
        let drawBorder: Bool = dataSet.getBarBorderWidth() > 0.0
        buffer.feed(dataSet)
        let tempArray: Array<Float64> = buffer.buffer.toArray()
        if (let Some(tran) <- trans) {
        	tran.pointValuesToPixel(tempArray)
            buffer.buffer = ArrayList<Float64>(tempArray)
        }
        let fills: ?ArrayList<Fill> = dataSet.getFills()
        let isCustomFill: Bool = fills.isSome() && fills().size > 0
        let isSingleColor: Bool = dataSet.getColors().size == 1
        let isInverted: Bool = this.mChart.isInverted(dataSet.getAxisDependency())
        if (isSingleColor) {
            this.mRenderPaint.setColor(Color(dataSet.getColor()))
        }
        var j: Int64 = 0
        var pos: Int64 = 0
        while (j < buffer.size()) {
            if (!this.mViewPortHandler().isInBoundsLeft(buffer.buffer[j + 2])) {
                j += 4
                pos++
                continue
            }
            if (!this.mViewPortHandler().isInBoundsRight(buffer.buffer[j])) {
                break
            }
            if (!isSingleColor) {
                // Set the color for the currently drawn value. If the index
                // is out of bounds, reuse colors.
                this.mRenderPaint.setColor(Color(dataSet.getColor(pos)))
            }
            let radius: Float64 = match (barData) {
                case Some(bar) => bar.getTopRadius()
                case None => 0.0
            }
            //顶部的矩形才需要绘制圆角
            let isDrawRounded = radius != 0.0 && (j + 4 >= buffer.size() || (j + 4 < buffer.size() &&
                buffer.buffer[j] != buffer.buffer[j + 4]))
            // 圆角位置：同时受 值 和 图表是否 inverted 影响
            var cornerType: RoundCornerType = RoundCornerType.UP
            if (isInverted) {
                cornerType = if (dataSet.getEntryForIndex(pos).getY() > 0.0) {
                    RoundCornerType.DOWN
                } else {
                    RoundCornerType.UP
                }
            } else {
                cornerType = if (dataSet.getEntryForIndex(pos).getY() > 0.0) {
                    RoundCornerType.UP
                } else {
                    RoundCornerType.DOWN
                }
            }
            if (isCustomFill) {
                let fill: Fill = dataSet.getFill(pos)
                fill.fillRect(c, this.mRenderPaint, buffer.buffer[j], buffer.buffer[j + 1], buffer.buffer[j + 2],
                    buffer.buffer[j + 3], if (isInverted) {
                    FillDirection.DOWN
                } else {
                    FillDirection.UP
                }, radius: radius, cornerType: cornerType)
            } else {
                Utils.drawFillRect(isDrawRounded, c, this.mRenderPaint, buffer.buffer[j], buffer.buffer[j + 1],
                    buffer.buffer[j + 2], buffer.buffer[j + 3], radius, cornerType)
            }
            if (drawBorder) {
                Utils.drawStrokeRect(isDrawRounded, c, this.mBarBorderPaint, buffer.buffer[j], buffer.buffer[j + 1],
                    buffer.buffer[j + 2], buffer.buffer[j + 3], radius, cornerType)
            }
            j += 4
            pos++
        }
    }
    protected open func drawDataSet(c: CanvasRenderingContext2D, dataSet: IBarDataSet, index: Int64): Unit {
        let trans: ?Transformer = this.mChart.getTransformer(dataSet.getAxisDependency())
        this.mBarBorderPaint.setColor(Color(dataSet.getBarBorderColor()))
        this.mBarBorderPaint.setStrokeWidth(Utils.handleDataValues(dataSet.getBarBorderWidth()))
        var phaseX: Float64 = 1.0
        var phaseY: Float64 = 1.0
        if (let Some(m) <- this.mAnimator) {
            phaseX = m.getPhaseX()
            phaseY = m.getPhaseY()
        }
        // draw the bar shadow before the values
        if (this.mChart.isDrawBarShadowEnabled()) {
            this.mShadowPaint.setColor(Color(dataSet.getBarShadowColor()))
            let barData: BarData = match (this.mChart.getBarData()) {
            	case Some(bardata: BarData) => bardata
                case None => return
            }
            var radius = barData.getTopRadius()
            var barWidth: Float64 = barData.getBarWidth()
            var barWidthHalf: Float64 = barWidth / 2.0
            var x: Float64 = 0.0
            let count = min(Int64(ceil(Float64(dataSet.getEntryCount()) * phaseX)), dataSet.getEntryCount())
            for (i in 0..count) {
                let e: BarEntry = dataSet.getEntryForIndex(i)
                x = e.getX()
                this.mBarShadowRectBuffer.left = x - barWidthHalf
                this.mBarShadowRectBuffer.right = x + barWidthHalf
                if(let Some(t) <- trans) {
                    t.rectValueToPixel(this.mBarShadowRectBuffer)
                }
                if (!this.mViewPortHandler().isInBoundsLeft(this.mBarShadowRectBuffer.right)) {
                    continue
                }
                if (!this.mViewPortHandler().isInBoundsRight(this.mBarShadowRectBuffer.left)) {
                    break
                }
                this.mBarShadowRectBuffer.top = this.mViewPortHandler().contentTop()
                this.mBarShadowRectBuffer.bottom = this.mViewPortHandler().contentBottom()
                match (this.mShadowPaint.getStyle()) {
                    case Style.STROKE =>
                        Utils.drawStrokeRect(radius > 0.0, c, this.mShadowPaint,
                        this.mBarShadowRectBuffer.left, this.mBarShadowRectBuffer.top, this.mBarShadowRectBuffer.right,
                        this.mBarShadowRectBuffer.bottom, radius, RoundCornerType.BOTH) // 阴影上下圆角都绘制比较好
                    case Style.FILL =>
                        Utils.drawFillRect(radius > 0.0, c, this.mShadowPaint, this.mBarShadowRectBuffer.left,
                        this.mBarShadowRectBuffer.top, this.mBarShadowRectBuffer.right, this.mBarShadowRectBuffer.bottom,
                        radius, RoundCornerType.BOTH)
                    case Style.FILL_AND_STROKE =>
                        Utils.drawFillRect(radius > 0.0, c, this.mShadowPaint, this.mBarShadowRectBuffer.left,
                        this.mBarShadowRectBuffer.top, this.mBarShadowRectBuffer.right, this.mBarShadowRectBuffer.bottom,
                        radius, RoundCornerType.BOTH)
                    case _ =>
                        Utils.drawFillRect(radius > 0.0, c, this.mShadowPaint, this.mBarShadowRectBuffer.left,
                        this.mBarShadowRectBuffer.top, this.mBarShadowRectBuffer.right, this.mBarShadowRectBuffer.bottom,
                        radius, RoundCornerType.BOTH) // 阴影上下圆角都绘制比较好
                }
            }
        }
        drawDataSetFunc(index, phaseX, phaseY, dataSet, c, trans)
    }
    protected open func prepareBarHighlight(x: Float64, y1: Float64, y2: Float64, barWidthHalf: Float64,
        trans: Transformer): Unit {
        let left: Float64 = x - barWidthHalf
        let right: Float64 = x + barWidthHalf
        let top: Float64 = y1
        let bottom: Float64 = y2
        this.mBarRect.set(left, top, right, bottom)
        trans.rectToPixelPhase(
            this.mBarRect,
            if (let Some(animator) <- this.mAnimator) {
                animator.getPhaseY()
            } else {
                1.0
            }
        )
    }
    public func drawValues(c: CanvasRenderingContext2D, isHorizontalFlip!: Bool = false): Unit {
        if (this.mChart.getBarData().isNone()) {
            return
        }
        // if values are drawn
        if (this.isDrawingValuesAllowed(this.mChart)) {
            let barData: ?BarData = this.mChart.getBarData()
            if (barData.isNone()) {
                return
            }
            let dataSets: ArrayList<IBarDataSet> = barData().getDataSets()
            const valueOffsetPlus: Float64 = 0.0
            var posOffset: Float64 = 0.0
            var negOffset: Float64 = 0.0
            let drawValueAboveBar: Bool = this.mChart.isDrawValueAboveBarEnabled()
            for (i in 0..barData().getDataSetCount()) {
                let dataSet: IBarDataSet = dataSets[i]
                if (!this.shouldDrawValues(dataSet)) {
                    continue
                }
                // apply the text-styling defined by the DataSet
                this.applyValueTextStyle(dataSet)
                let isInverted: Bool = this.mChart.isInverted(dataSet.getAxisDependency())
                // calculate the correct offset depending on the draw position of
                // the value
                let valueTextHeight: Float64 = Utils.calcTextHeight(c, this.mValuePaint, "8")
                posOffset = if (drawValueAboveBar) {
                    -valueOffsetPlus
                } else {
                    valueTextHeight + valueOffsetPlus
                }
                negOffset = if (drawValueAboveBar) {
                    valueTextHeight + valueOffsetPlus
                } else {
                    -valueOffsetPlus
                }
                if (isInverted) {
                    posOffset = -posOffset - valueTextHeight
                    negOffset = -negOffset - valueTextHeight
                }
                // get the buffer
                let buffer: BarBuffer = this.mBarBuffers[i]
                let phaseY: Float64 = if (let Some(m) <- this.mAnimator) {
                    m.getPhaseY()
                } else {
                    1.0
                }
                let iconsOffset: MPPointF = MPPointF.getInstance(dataSet.getIconsOffset())
                iconsOffset.x = Utils.handleDataValues(iconsOffset.x)
                iconsOffset.y = Utils.handleDataValues(iconsOffset.y)
                // if only single values are drawn (sum)
                if (!dataSet.isStacked()) {
                    for (j in 0..buffer.buffer.size * Int64(if (let Some(animator) <- this.mAnimator) {
                                animator.getPhaseX()
                            } else {
                                1.0
                            }) : 4) {
                        let x: Float64 = (buffer.buffer[j] + buffer.buffer[j + 2]) / 2.0
                        if (!this.mViewPortHandler().isInBoundsRight(x)) {
                            break
                        }
                        if (!this.mViewPortHandler().isInBoundsY(buffer.buffer[j + 1]) ||
                            !this.mViewPortHandler().isInBoundsLeft(x)) {
                            continue
                        }
                        let entry: BarEntry = dataSet.getEntryForIndex(j / 4)
                        let val: Float64 = entry.getY()
                        if (dataSet.isDrawValuesEnabled()) {
                            let valueFormatter: ?IValueFormatter = dataSet.getValueFormatter()
                            if (let Some(formatter) <- valueFormatter) {
                                this.drawValue(c, formatter, val, entry, i, x,
                                    if (val >= 0.0) {
                                    (buffer.buffer[j + 1] + posOffset)
                                } else {
                                    (buffer.buffer[j + 3] + negOffset)
                                }, Color(dataSet.getValueTextColor(j / 4)))
                            }
                        }
                        let icon: ?ChartPixelMap = entry.getIcon()
                        if (icon.isSome() && dataSet.isDrawIconsEnabled()) {
                            var px: Float64 = x
                            var py: Float64 = if (val >= 0.0) {
                                (buffer.buffer[j + 1] + posOffset)
                            } else {
                                (buffer.buffer[j + 3] + negOffset)
                            }
                            px += iconsOffset.x
                            py += iconsOffset.y
                            Utils.drawImage(
                                c,
                                icon(),
                                Utils.parseInt(px),
                                Utils.parseInt(py)
                            )
                        }
                    }
                // if we have stacks
                } else {
                    let trans: ?Transformer = this.mChart.getTransformer(dataSet.getAxisDependency())
                    var bufferIndex: Int64 = 0
                    var index: Int64 = 0
                    while (index < dataSet.getEntryCount() * Int64(if (let Some(animator) <- this.mAnimator) {
                                animator.getPhaseX()
                            } else {
                                1.0
                            })) {
                        let entry: BarEntry = dataSet.getEntryForIndex(index)
                        let vals: ?Array<Float64> = entry.getYVals()
                        let x: Float64 = (buffer.buffer[bufferIndex] + buffer.buffer[bufferIndex + 2]) / 2.0
                        let color: UInt32 = dataSet.getValueTextColor(index)
                        // we still draw stacked bars, but there is one
                        // non-stacked
                        // in between
                        if (vals.isNone()) {
                            if (!this.mViewPortHandler().isInBoundsRight(x)) {
                                break
                            }
                            if (!this.mViewPortHandler().isInBoundsY(buffer.buffer[bufferIndex + 1]) ||
                                !this.mViewPortHandler().isInBoundsLeft(x)) {
                                continue
                            }
                            if (dataSet.isDrawValuesEnabled()) {
                                let valueFormatter: ?IValueFormatter = dataSet.getValueFormatter()
                                if (let Some(formatter) <- valueFormatter) {
                                    this.drawValue(c, formatter, entry.getY(), entry, i, x,
                                        buffer.buffer[bufferIndex + 1] + (if (entry.getY() >= 0.0) {
                                        posOffset
                                    } else {
                                        negOffset
                                    }), Color(color))
                                }
                            }
                            let icon: ?ChartPixelMap = entry.getIcon()
                            if (icon.isSome() && dataSet.isDrawIconsEnabled()) {
                                var px: Float64 = x
                                var py: Float64 = buffer.buffer[bufferIndex + 1] + (if (entry.getY() >= 0.0) {
                                    posOffset
                                } else {
                                    negOffset
                                })
                                px += iconsOffset.x
                                py += iconsOffset.y
                                Utils.drawImage(
                                    c,
                                    icon(),
                                    Utils.parseInt(px),
                                    Utils.parseInt(py)
                                )
                            }
                        // draw stack values
                        } else {
                            var transformed: Array<Float64> = Array<Float64>(vals().size * 2, item: 0.0)
                            var posY: Float64 = 0.0
                            var negY: Float64 = -entry.getNegativeSum()
                            var k: Int64 = 0
                            var idx: Int64 = 0
                            while (k < transformed.size) {
                                let value: Float64 = vals()[idx]
                                var y: Float64 = 0.0
                                if (value == 0.0 && (posY == 0.0 || negY == 0.0)) {
                                    // Take care of the situation of a 0.0 value, which overlaps a non-zero bar
                                    y = value
                                } else if (value >= 0.0) {
                                    posY += value
                                    y = posY
                                } else {
                                    y = negY
                                    negY -= value
                                }
                                transformed[k + 1] = y * phaseY
                                k += 2
                                idx++
                            }
                            if (let Some(tran) <- trans) {
                                tran.pointValuesToPixel(transformed)
                            }
                            var m: Int64 = 0
                            while (m < transformed.size) {
                                var val: Float64 = vals()[k / 2]
                                let drawBelow: Bool = (val == 0.0 && negY == 0.0 && posY > 0.0) || val < 0.0
                                let y: Float64 = transformed[k + 1] + if (drawBelow) {
                                    negOffset
                                } else {
                                    posOffset
                                }
                                if (!this.mViewPortHandler().isInBoundsRight(x)) {
                                    break
                                }
                                if (!this.mViewPortHandler().isInBoundsY(y) ||
                                    !this.mViewPortHandler().isInBoundsLeft(x)) {
                                    m += 2
                                    continue
                                }
                                if (dataSet.isDrawValuesEnabled()) {
                                    let valueFormatter: ?IValueFormatter = dataSet.getValueFormatter()
                                    if (let Some(formatter) <- valueFormatter) {
                                        this.drawValue(
                                            c,
                                            formatter,
                                            vals()[k / 2],
                                            entry,
                                            i,
                                            x,
                                            y,
                                            Color(color)
                                        )
                                    }
                                }
                                let icon: ?ChartPixelMap = entry.getIcon()
                                if (icon.isSome() && dataSet.isDrawIconsEnabled()) {
                                    Utils.drawImage(
                                        c,
                                        icon(),
                                        (x + iconsOffset.x),
                                        (y + iconsOffset.y)
                                    )
                                }
                                m += 2
                            }
                        }
                        bufferIndex = if (vals.isNone()) {
                            bufferIndex + 4
                        } else {
                            bufferIndex + 4 * vals().size
                        }
                        index++
                    }
                }
                MPPointF.recycleInstance(iconsOffset)
            }
        }
    }
    private func drawHighlighted(high: Highlight, e: ?BarEntry, barData: ?BarData): (Float64, Float64, Bool) {
        let isStack: Bool = if ((high.getStackIndex() >= 0 && e().isStacked())) {
            true
        } else {
            false
        }
        var y1: Float64 = 0.0
        var y2: Float64 = 0.0
        var drawRadius: Bool = false
        let radius = barData().getTopRadius()
        if (isStack) {
            if (this.mChart.isHighlightFullBarEnabled()) {
                y1 = e().getPositiveSum()
                y2 = -e().getNegativeSum()
            } else {
                let dataRanges: ?Array<RangeChart> = e().getRanges()
                if (let Some(ranges) <- dataRanges) {
                    let range: RangeChart = ranges[high.getStackIndex()]
                    //堆叠柱状图顶部的柱形绘制圆角
                    if (radius != 0.0 && high.getStackIndex() == ranges.size - 1) {
                        drawRadius = true
                    }
                    y1 = range.myfrom
                    y2 = range.to
                }
            }
        } else {
            if (radius != 0.0) {
                drawRadius = true
            }
            y1 = e().getY()
            y2 = 0.0
        }
        return (y1, y2, drawRadius)
    }
    public func drawHighlighted(c: CanvasRenderingContext2D, indices: Array<Highlight>): Unit {
        let barData: ?BarData = this.mChart.getBarData()
        for (i in 0..indices.size) {
            let high: Highlight = indices[i]
            let set: ?IBarDataSet = barData().getDataSetByIndex(high.getDataSetIndex())
            if (set.isNone() || !set().isHighlightEnabled()) {
                continue
            }
            let e: ?BarEntry = set().getEntryForXValue(high.getX(), high.getY(), rounding: Rounding.CLOSEST)
            if (e.isNone()) {
                continue
            }
            if (!this.isInBoundsX((e() as EntryOhos), (set as IBarLineScatterCandleBubbleDataSet<EntryOhos>)())) {
                continue
            }
            let trans: ?Transformer = this.mChart.getTransformer(set().getAxisDependency())
            var highLightColor: UInt32 = set().getHighLightColor()
            if (highLightColor == 0) {
                highLightColor = 0x000000
            }
            this.mHighlightPaint.setColor(Color(highLightColor))
            this.mHighlightPaint.setGlobalAlpha(set().getHighLightAlpha() / 255.0)
            let y1: Float64 = drawHighlighted(high, e(), barData)[0]
            let y2: Float64 = drawHighlighted(high, e(), barData)[1]
            let drawRadius: Bool = drawHighlighted(high, e(), barData)[2]
            let radius = barData().getTopRadius()
            if (let Some(tran) <- trans) {
                this.prepareBarHighlight(e().getX(), y1, y2, barData().getBarWidth() / 2.0, tran)
            }
            // 圆角位置
            var cornerType: RoundCornerType = RoundCornerType.UP
            // 当前图表是否反向
            let isInverted: Bool = this.mChart.isInverted(set().getAxisDependency())
            if (isInverted) {
                cornerType = if (e().getY() > 0.0) {
                    RoundCornerType.DOWN
                } else {
                    RoundCornerType.UP
                }
            } else {
                cornerType = if (e().getY() > 0.0) {
                    RoundCornerType.UP
                } else {
                    RoundCornerType.DOWN
                }
            }
            this.setHighlightDrawPos(high, this.mBarRect)
            Utils.drawFillRect(drawRadius, c, this.mHighlightPaint, this.mBarRect.left, this.mBarRect.top,
                this.mBarRect.right, this.mBarRect.bottom, radius, cornerType)
        }
    }
    protected open func setHighlightDrawPos(high: Highlight, bar: MyRect): Unit {
        high.setDraw(bar.centerX(), bar.top)
    }
    public func drawExtras(c: CanvasRenderingContext2D): Unit {}
}