package core.waterfall
public class WaterfallChartRenderer <: BarLineScatterCandleBubbleRenderer {
    protected var mBarBuffers: Array<WaterfallBuffer> = Array<WaterfallBuffer>();
    public var mChart: WaterfallDataProvider
    protected var mBarRect: MyRect = MyRect()
    protected var mShadowPaint: Paint
    protected var mBarBorderPaint: Paint
    public init(chart: WaterfallDataProvider, animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
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
    public func initBuffers(): Unit {
        let data: ?WaterfallData = this.mChart.getWaterfallData();
        if (let Some(d) <- data) {
            this.mBarBuffers = Array<WaterfallBuffer>(d.getDataSetCount(), item: WaterfallBuffer(0, 0, false))
            for (i in 0..this.mBarBuffers.size) {
                let dataSet: ?IWaterfallDataSet = d.getDataSetByIndex(i)
                if (let Some(ds) <- dataSet) {
                    let size: Int64 = ds.getEntryCount() * 4 * (if (ds.isStacked()) {
                        ds.getStackSize()
                    } else {
                        1
                    })
                    this.mBarBuffers[i] = WaterfallBuffer(size, d.getDataSetCount(), ds.isStacked())
                }
            }
        }
    }
    private var mWaterfallShadowRectBuffer: MyRect = MyRect();
    public func drawData(c: CanvasRenderingContext2D): Unit {
        let data: ?WaterfallData = this.mChart.getWaterfallData();
        if (let Some(d) <- data) {
            for (i in 0..d.getDataSetCount()) {
                let set: ?IWaterfallDataSet = d.getDataSetByIndex(i)
                if (let Some(ds: WaterfallDataSet) <- set) {
                    if (ds.isVisible()) {
                        this.drawDataSet(c, ds, i)
                    }
                }
            }
        }
    }
    protected func drawDataSet(c: CanvasRenderingContext2D, dataSet: WaterfallDataSet, index: Int64): Unit {
        let trans: ?Transformer = this.mChart.getTransformer(dataSet.getAxisDependency());
        this.mBarBorderPaint.setColor(Color(dataSet.getBarBorderColor()));
        this.mBarBorderPaint.setStrokeWidth(Utils.handleDataValues(dataSet.getBarBorderWidth()));
        let drawBorder: Bool = dataSet.getBarBorderWidth() > 0.0;
        var phaseX: Float64 = 1.0;
        var phaseY: Float64 = 1.0;
        if (let Some(m) <- this.mAnimator) {
            phaseX = m.getPhaseX()
            phaseY = m.getPhaseY()
        }
        // draw the bar shadow before the values
        if (this.mChart.isDrawBarShadowEnabled()) {
            this.mShadowPaint.setColor(Color(dataSet.getBarShadowColor()));
            let waterfallData: ?WaterfallData = this.mChart.getWaterfallData();
            var barWidth: Float64
            if (let Some(d) <- waterfallData) {
                barWidth = d.getBarWidth()
            } else {
                return;
            }
            let barWidthHalf: Float64 = barWidth / 2.0;
            var x: Float64 = 0.0;
            for (i in 0..Int64(min((ceil(Float64(dataSet.getEntryCount()) * phaseX)), Float64(dataSet.getEntryCount())))) {
                let e: WaterfallEntry = dataSet.getEntryForIndex(i)
                x = e.getX()
                this.mWaterfallShadowRectBuffer.left = x - barWidthHalf
                this.mWaterfallShadowRectBuffer.right = x + barWidthHalf
                if (let Some(t) <- trans) {
                    t.rectValueToPixel(this.mWaterfallShadowRectBuffer);
                }
                if (this.mViewPortHandler.isNone() ||
                    !this.mViewPortHandler().isInBoundsLeft(this.mWaterfallShadowRectBuffer.right)) {
                    continue;
                }
                if (this.mViewPortHandler.isNone() ||
                    !this.mViewPortHandler().isInBoundsRight(this.mWaterfallShadowRectBuffer.left)) {
                    break;
                }
                this.mWaterfallShadowRectBuffer.top = if (let Some(handle) <- this.mViewPortHandler) {
                    handle.contentTop()
                } else {
                    0.0
                }
                this.mWaterfallShadowRectBuffer.bottom = if (let Some(handle) <- this.mViewPortHandler) {
                    handle.contentBottom()
                } else {
                    0.0
                }
                Utils.resetContext2DStyle(c, this.mShadowPaint);
                c.beginPath();
                c.rect(this.mWaterfallShadowRectBuffer.left, this.mWaterfallShadowRectBuffer.top,
                    this.mWaterfallShadowRectBuffer.width(), this.mWaterfallShadowRectBuffer.height())
                match (this.mShadowPaint.getStyle()) {
                    case Style.STROKE => c.stroke();
                    case _ => c.fill();
                }
                c.closePath();
            }
        }
        // initialize the buffer
        let buffer: WaterfallBuffer = this.mBarBuffers[index];
        buffer.setPhases(phaseX, phaseY);
        buffer.setDataSet(index);
        buffer.setInverted(this.mChart.isInverted(dataSet.getAxisDependency()));
        let waterfallData: ?WaterfallData = this.mChart.getWaterfallData();
        if (let Some(data) <- waterfallData) {
            buffer.setBarWidth(data.getBarWidth());
        }
        let tempArray: Array<Float64> = buffer.buffer.toArray()
        buffer.feed(dataSet);
        if (let Some(t) <- trans) {
            t.pointValuesToPixel(tempArray);
        }
        let fills: ?ArrayList<Fill> = dataSet.getFills()()
        let isCustomFill: Bool = fills.isSome() && fills().size > 0
        let isSingleColor: Bool = dataSet.getColors().size == 1
        let isInverted: Bool = this.mChart.isInverted(dataSet.getAxisDependency())
        if (isSingleColor) {
            this.mRenderPaint.setColor(Color(dataSet.getColor()));
            if (dataSet.getOpacity().size != 0) {
                this.mRenderPaint.setFilter(dataSet.getOpacity());
            }
        }
        let maxTop = buffer.getArrayTop()[buffer.getArrayTop().size - 1];
        let minBottom = buffer.getArrayBottom()[0];
        if (dataSet.getEnableMaxOrMinHighlightColor()) {
            for (i in 0..Int64(min((ceil(Float64(dataSet.getEntryCount()) * phaseX)), Float64(dataSet.getEntryCount())))) {
                let e: WaterfallEntry = dataSet.getEntryForIndex(i)
                this.initMaxAndMinHighlightData(e, dataSet, maxTop, minBottom);
            }
        }
        // 获取Y轴刻度范围数据
        let yAxisSegmentList = dataSet.getYAxisSegmentationColors();
        var j: Int64 = 0
        var pos: Int64 = 0
        while (j < buffer.size()) {
            if (this.mViewPortHandler.isNone() || !this.mViewPortHandler().isInBoundsLeft(buffer.buffer[j + 2])) {
                j += 4
                continue;
            }
            if (this.mViewPortHandler.isNone() || !this.mViewPortHandler().isInBoundsRight(buffer.buffer[j])) {
                break
            }
            if (!isSingleColor) {
                // Set the color for the currently drawn value. If the index
                // is out of bounds, reuse colors.
                this.mRenderPaint.setColor(Color(dataSet.getColor(pos)));
            }
            if (isCustomFill) {
                let fill: Fill = dataSet.getFill(pos);
                fill.fillRect(c, this.mRenderPaint, buffer.buffer[j], buffer.buffer[j + 1], buffer.buffer[j + 2],
                    buffer.buffer[j + 3], if (isInverted) {
                    FillDirection.DOWN
                } else {
                    FillDirection.UP
                });
            } else {
                Utils.resetContext2DStyle(c, this.mRenderPaint);
                let left: Float64 = buffer.buffer[j];
                let bottom: Float64 = buffer.buffer[j + 1];
                let right: Float64 = buffer.buffer[j + 2];
                let top: Float64 = buffer.buffer[j + 3];
                //绘制数据
                let radius = (right - left) / 2.0;
                if (abs(top - bottom) > (right - left)) {
                    this.drawRoundedRectangles(c, left, top, right, bottom, radius);
                } else {
                    this.drawCircle(c, left, top, radius);
                }
                let e: WaterfallEntry = dataSet.getEntryForIndex(j / 4)
                //绘制Y轴刻度范围图
                for (i in 0..yAxisSegmentList.size) {
                    let h = yAxisSegmentList[i];
                    //canvas画布的y轴与图表的y轴方向相反
                    var maxY = h.getMinY();
                    var minY = h.getMaxY();
                    if (maxY > e.getMaxY() || (minY < e.getMaxY() && minY < e.getMinY())) {
                        continue;
                    }
                    maxY = if (maxY <= e.getMinY()) {
                        e.getMinY()
                    } else {
                        maxY
                    };
                    minY = if (minY >= e.getMaxY()) {
                        e.getMaxY()
                    } else {
                        minY
                    };
                    let yArray = [0.0, minY, 0.0, maxY];
                    trans?.pointValuesToPixel(yArray)
                    if (abs(yArray[1] - yArray[3]) > (right - left)) {
                        c.save();
                        //c.fillStyle = h.getColor();
                        this.newMethod(c, left, right, radius, yArray, e, minY, maxY);
                        c.restore();
                    } else {
                        if (h.getMaxY() > e.getMaxY() || h.getMinY() < e.getMinY()) {
                            continue;
                        }
                        c.save();
                        //c.fillStyle = h.getColor();
                        if (yArray[3] + 2.0 * radius > bottom) {
                            this.drawCircle(c, left, bottom - 2.0 * radius, radius);
                        } else {
                            this.drawCircle(c, left, yArray[3], radius);
                        }
                        c.restore();
                    }
                }
                let highlights = e.getHighlights();
                let topNum = this.getHighlightTop(e);
                //绘制标记点
                for (i in 0..highlights.size) {
                    let h = highlights[i];
                    //canvas画布的y轴与图表的y轴方向相反
                    let maxY = h.getMinY();
                    let minY = h.getMaxY();
                    let yArray = [0.0, minY, 0.0, maxY];
                    trans?.pointValuesToPixel(yArray)
                    if (abs(yArray[1] - yArray[3]) > (right - left)) {
                        c.save();
                        //c.fillStyle = h.getColor();
                        if (e.getHighlights().size == 1) {
                            this.drawRoundedRectangles(c, left, yArray[1], right, yArray[3], radius);
                        } else {
                            this.drawHighlights(c, left, radius, yArray, i, right, h, topNum);
                        }
                        c.restore();
                    } else {
                        c.save();
                        //c.fillStyle = h.getColor();
                        if (yArray[3] + 2.0 * radius > bottom) {
                            this.drawCircle(c, left, bottom - 2.0 * radius, radius);
                        } else {
                            this.drawCircle(c, left, yArray[3], radius);
                        }
                        c.restore();
                    }
                }
            }
            if (drawBorder) {
                Utils.resetContext2DStyle(c, this.mBarBorderPaint);
                c.beginPath();
                c.rect(buffer.buffer[j], buffer.buffer[j + 1], buffer.buffer[j + 2] - buffer.buffer[j],
                    buffer.buffer[j + 3] - buffer.buffer[j + 1]);
                c.stroke();
                c.closePath();
            }
            pos++
            j += 4
        }
        dataSet.setMaxTopHighlightEXIST(false);
        dataSet.setMinBottomHighlightEXIST(false);
    }
    private func drawHighlights(c: CanvasRenderingContext2D, left: Float64, radius: Float64, yArray: Array<Float64>,
        i: Int64, right: Float64, h: WaterfallHighlight, topNum: Float64) {
        c.beginPath();
        c.moveTo(left + radius, yArray[1]);
        if (i == 0) {
            this.brawBottomCircularCylinder(c, right, yArray, radius, left);
        } else if (h.getMaxY() == topNum) {
            c.lineTo(right - radius, yArray[1]);
            c.arc(right - radius, yArray[1] + radius, radius, 3.0 / 2.0 * Float64.PI, 0.0);
            c.lineTo(right, yArray[3]);
            c.lineTo(left, yArray[3]);
            c.lineTo(left, yArray[1] + radius);
            c.arc(left + radius, yArray[1] + radius, radius, Float64.PI, 3.0 / 2.0 * Float64.PI);
        } else {
            c.rect(left, yArray[1], right - left, yArray[3] - yArray[1]);
        }
        c.closePath();
        c.fill();
    }
    private func brawBottomCircularCylinder(c: CanvasRenderingContext2D, right: Float64, yArray: Array<Float64>,
        radius: Float64, left: Float64) {
        c.lineTo(right, yArray[1]);
        c.lineTo(right, yArray[3] - radius);
        c.arc(right - radius, yArray[3] - radius, radius, 0.0, Float64.PI / 2.0);
        c.lineTo(left + radius, yArray[3]);
        c.arc(left + radius, yArray[3] - radius, radius, Float64.PI / 2.0, Float64.PI);
        c.lineTo(left, yArray[1]);
    }
    private func getHighlightTop(e: WaterfallEntry) {
        var topNum: Float64 = 0.0;
        for (i in 0..e.getHighlights().size) {
            if (e.getHighlights()[i].getMaxY() == e.getHighlights()[i].getMinY()) {
                continue;
            }
            topNum = if (e.getHighlights()[i].getMaxY() > topNum) {
                e.getHighlights()[i].getMaxY()
            } else {
                topNum;
            }
        }
        return topNum;
    }
    private func newMethod(c: CanvasRenderingContext2D, left: Float64, right: Float64, radius: Float64,
        yArray: Array<Float64>, e: WaterfallEntry, minY: Float64, maxY: Float64) {
        c.beginPath();
        c.moveTo(left + radius, yArray[1]);
        if (e.getMaxY() == minY && e.getMinY() == maxY) {
            this.drawRoundedRectangles(c, left, yArray[1], right, yArray[3], radius);
        } else if (e.getMaxY() == minY) {
            c.lineTo(right - radius, yArray[1]);
            c.arc(right - radius, yArray[1] + radius, radius, 3.0 / 2.0 * Float64.PI, 0.0);
            c.lineTo(right, yArray[3]);
            c.lineTo(left, yArray[3]);
            c.lineTo(left, yArray[1] + radius);
            c.arc(left + radius, yArray[1] + radius, radius, Float64.PI, 3.0 / 2.0 * Float64.PI);
        } else if (e.getMinY() == maxY) {
            this.brawBottomCircularCylinder(c, right, yArray, radius, left);
        } else {
            c.rect(left, yArray[1], right - left, yArray[3] - yArray[1]);
        }
        c.closePath();
        c.fill();
    }
    private func drawCircle(c: CanvasRenderingContext2D, left: Float64, top: Float64, radius: Float64) {
        c.beginPath();
        c.arc(left + radius, top + radius, radius, 0.0, 2.0 * Float64.PI);
        c.closePath();
        c.fill();
    }
    private func drawRoundedRectangles(c: CanvasRenderingContext2D, left: Float64, top: Float64, right: Float64,
        bottom: Float64, radius: Float64) {
        c.beginPath();
        c.moveTo(left + radius, top);
        c.lineTo(right - radius, top);
        c.arc(right - radius, top + radius, radius, 3.0 / 2.0 * Float64.PI, 0.0);
        c.lineTo(right, bottom - radius);
        c.arc(right - radius, bottom - radius, radius, 0.0, Float64.PI / 2.0);
        c.lineTo(left + radius, bottom);
        c.arc(left + radius, bottom - radius, radius, Float64.PI / 2.0, Float64.PI);
        c.lineTo(left, top + radius);
        c.arc(left + radius, top + radius, radius, Float64.PI, 3.0 / 2.0 * Float64.PI);
        c.closePath();
        c.fill();
    }
    private func initMaxAndMinHighlightData(e: WaterfallEntry, dataSet: WaterfallDataSet, maxTop: Float64,
        minBottom: Float64) {
        if (maxTop == e.getMaxY() && !dataSet.getMaxTopHighlightEXIST()) {
            dataSet.setMaxTopHighLightEXIST(true);
            e.setHighlights(WaterfallHighlight(maxTop, maxTop, color:dataSet.getMaxyHighlightColor()));
        }
        if (minBottom == e.getMinY() && !dataSet.getMinBottomHighlightEXIST()) {
            dataSet.setMinBottomHighlightEXIST(true);
            e.setHighlights(WaterfallHighlight(minBottom, minBottom, color:dataSet.getMinyHighlightColor()));
        }
    }
    public func drawValues(c: CanvasRenderingContext2D): Unit {
        if (this.mChart.getWaterfallData().isNone()) {
            return;
        }
        // if values are drawn
        if (this.isDrawingValuesAllowed(this.mChart)) {
            let waterfallData: ?WaterfallData = this.mChart.getWaterfallData();
            var dataSets: ArrayList<IWaterfallDataSet>
            if (let Some(data) <- waterfallData) {
                dataSets = data.getDataSets()
            } else {
                return
            }
            let valueOffsetPlus: Float64 = .0;
            var posOffset: Float64 = 0.0;
            var negOffset: Float64 = 0.0;
            let drawValueAboveBar: Bool = this.mChart.isDrawValueAboveBarEnabled();
            for (i in 0..waterfallData().getDataSetCount()) {
                let dataSet: IWaterfallDataSet = dataSets[i];
                if (!this.shouldDrawValues(dataSet)) {
                    continue;
                }
                // apply the text-styling defined by the DataSet
                this.applyValueTextStyle(dataSet);
                let isInverted: Bool = this.mChart.isInverted(dataSet.getAxisDependency());
                // calculate the correct offset depending on the draw position of
                // the value
                let valueTextHeight: Float64 = Utils.calcTextHeight(c, this.mValuePaint, "8");
                posOffset = (if (drawValueAboveBar) {
                    -valueOffsetPlus
                } else {
                    valueTextHeight + valueOffsetPlus
                })
                negOffset = (if (drawValueAboveBar) {
                    valueTextHeight + valueOffsetPlus
                } else {
                    -valueOffsetPlus
                })
                if (isInverted) {
                    posOffset = -posOffset - valueTextHeight
                    negOffset = -negOffset - valueTextHeight
                }
                // get the buffer
                let buffer: WaterfallBuffer = this.mBarBuffers[i];
                let iconsOffset: MPPointF = MPPointF.getInstance(dataSet.getIconsOffset());
                iconsOffset.x = Utils.handleDataValues(iconsOffset.x)
                iconsOffset.y = Utils.handleDataValues(iconsOffset.y)
                let limit: Int64 = buffer.buffer.size * if (let Some(m) <- this.mAnimator) {
                    Int64(m.getPhaseX())
                } else {
                    1
                }
                for (j in 0..limit : 4) {
                    let x: Float64 = (buffer.buffer[j] + buffer.buffer[j + 2]) / 2.0;
                    if (this.mViewPortHandler.isNone() || !this.mViewPortHandler().isInBoundsRight(x)) {
                        break;
                    }
                    if (this.mViewPortHandler.isNone() || !this.mViewPortHandler().isInBoundsY(buffer.buffer[j + 1])
                        || !this.mViewPortHandler().isInBoundsLeft(x)) {
                        continue;
                    }
                    let entry: WaterfallEntry = dataSet.getEntryForIndex(j / 4)
                    let val: Float64 = entry.getY();
                    if (dataSet.isDrawValuesEnabled()) {
                        let valueFormatter: ?IValueFormatter = dataSet.getValueFormatter();
                        if (let Some(format) <- valueFormatter) {
                            this.drawValue(c, format, val, entry, i, x, (buffer.buffer[j + 3] + posOffset),
                                Color(dataSet.getValueTextColor(j / 4)));
                        }
                    }
                    let icon: ?ChartPixelMap = entry.getIcon();
                    if (let Some(i) <- icon) {
                        if (dataSet.isDrawIconsEnabled()) {
                            var px: Float64 = x;
                            var py: Float64 = if (val >= 0.0) {
                                (buffer.buffer[j + 1] + posOffset)
                            } else {
                                (buffer.buffer[j + 3] + negOffset)
                            }
                            px += iconsOffset.x
                            py += iconsOffset.y
                            Utils.drawImage(
                                c,
                                i,
                                Utils.parseInt(px),
                                Utils.parseInt(py)
                            );
                        }
                    }
                }
                MPPointF.recycleInstance(iconsOffset);
            }
        }
    }
    public func drawHighlighted(c: CanvasRenderingContext2D, indices: Array<Highlight>): Unit {
        let waterfallData: ?WaterfallData = this.mChart.getWaterfallData();
        if (waterfallData.isNone()) {
            return;
        }
        for (i in 0..indices.size) {
            let high: Highlight = indices[i];
            let set: ?IWaterfallDataSet = waterfallData().getDataSetByIndex(high.getDataSetIndex())
            if (set.isNone() || !set().isHighlightEnabled()) {
                continue;
            }
            let e: ?WaterfallEntry = set().getEntryForXValue(high.getX(), high.getY(), rounding: Rounding.CLOSEST);
            if (e.isNone()) {
                continue;
            }
            if (!this.isInBoundsX(e, set())) {
                continue;
            }
            let trans: ?Transformer = this.mChart.getTransformer(set().getAxisDependency());
            var highLightColor: UInt32 = set().getHighLightColor();
            if (highLightColor == 0) {
                highLightColor = 0x000000
            }
            this.mHighlightPaint.setColor(Color(highLightColor));
            this.mHighlightPaint.setGlobalAlpha(set().getHighLightAlpha() / 255.0);
            var y1: Float64 = 0.0;
            var y2: Float64 = 0.0;
            y1 = e().getY()
            y2 = e().getMinY()
            if (let Some(t) <- trans) {
                this.prepareBarHighlight(e().getX(), y1, y2, waterfallData().getBarWidth() / 2.0, t);
            }
            this.setHighlightDrawPos(high, this.mBarRect);
            Utils.resetContext2DStyle(c, this.mHighlightPaint);
            let round = this.mBarRect.width() / 2.0;
            if (this.mBarRect.height() >= this.mBarRect.width()) {
                c.beginPath();
                c.moveTo(this.mBarRect.left + round, this.mBarRect.top);
                c.lineTo(this.mBarRect.right - round, this.mBarRect.top);
                c.arc(this.mBarRect.right - round, this.mBarRect.top + round, round, 3.0 / 2.0 * Float64.PI, 0.0);
                c.lineTo(this.mBarRect.right, this.mBarRect.bottom - round);
                c.arc(this.mBarRect.right - round, this.mBarRect.bottom - round, round, 0.0, Float64.PI / 2.0);
                c.lineTo(this.mBarRect.left + round, this.mBarRect.bottom);
                c.arc(this.mBarRect.left + round, this.mBarRect.bottom - round, round, Float64.PI / 2.0, Float64.PI);
                c.lineTo(this.mBarRect.left, this.mBarRect.top + round);
                c.arc(this.mBarRect.left + round, this.mBarRect.top + round, round, Float64.PI, 3.0 / 2.0 * Float64.PI);
                c.closePath();
                c.fill();
            } else {
                c.beginPath();
                let centerX = this.mBarRect.left + this.mBarRect.width() / 2.0;
                let centerY = this.mBarRect.top + this.mBarRect.height() / 2.0;
                c.moveTo(centerX, centerY);
                c.arc(centerX, centerY, round, 0.0, 360.0, anticlockwise: false);
                c.fill();
                c.closePath();
            }
        }
    }
    protected func prepareBarHighlight(x: Float64, y1: Float64, y2: Float64, barWidthHalf: Float64,
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
    protected open func setHighlightDrawPos(high: Highlight, bar: MyRect): Unit {
        high.setDraw(bar.centerX(), bar.top)
    }
    public func drawExtras(c: CanvasRenderingContext2D): Unit {}
    public func drawValues(c: CanvasRenderingContext2D, isHorizontalFlip!: Bool = false): Unit {
        if (this.mChart.getWaterfallData().isNone()) {
            return
        }
        // if values are drawn
        if (this.isDrawingValuesAllowed(this.mChart)) {
            let barData: ?WaterfallData = this.mChart.getWaterfallData()
            let dataSets: ArrayList<IWaterfallDataSet> = barData().getDataSets()
            const valueOffsetPlus: Float64 = 0.0
            var posOffset: Float64 = 0.0
            var negOffset: Float64 = 0.0
            let drawValueAboveBar: Bool = this.mChart.isDrawValueAboveBarEnabled()
            for (i in 0..barData().getDataSetCount()) {
                let dataSet: IWaterfallDataSet = dataSets[i]
                if (!this.shouldDrawValues(dataSet)) {
                    continue
                }
                // apply the text-styling defined by the DataSet
                this.applyValueTextStyle((dataSet as IDataSet<EntryOhos>)())
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
                            }):4) {
                        let x: Float64 = (buffer.buffer[j] + buffer.buffer[j + 2]) / 2.0
                        if (!this.mViewPortHandler().isInBoundsRight(x)) {
                            break
                        }
                        if (!this.mViewPortHandler().isInBoundsY(buffer.buffer[j + 1]) ||
                            !this.mViewPortHandler().isInBoundsLeft(x)) {
                            continue
                        }
                        let entry: WaterfallEntry = dataSet.getEntryForIndex(j / 4)
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
                        let entry: WaterfallEntry = dataSet.getEntryForIndex(index)
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
}