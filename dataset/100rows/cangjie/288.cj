package barPage
@Entry
@Component
class BarChartNegativePage {
    private var title: String = "BarChart"
    private var model: BarChartModel = BarChartModel.build()
    private var leftAxis: ?YAxis = Option<YAxis>.None
    private var rightAxis: ?YAxis = Option<YAxis>.None
    private var xAxis: ?XAxis = Option<XAxis>.None
    private var barData: BarData = BarData()
    private var normalMarker: MarkerView = MarkerView()
    func aboutToAppear(): BarChartModel {
        let description: Description = this.model.getDescription()
        description.setEnabled(false)
        let l: ?Legend = this.model.getLegend()
        if (let Some(v) <- l) {
            v.setEnabled(false)
        }
        // if more than 40 entries are displayed in the this.model, no values will be drawn
        this.model.setMaxVisibleValueCount(60)
        // scaling can now only be done on x- and y-axis separately
        this.model.setPinchZoom(false)
        this.model.setDrawGridBackground(false)
        this.model.setGridBackgroundColor(0x500000ff)
        this.model.setDrawBarShadow(false)
        this.model.setDrawValueAboveBar(true)
        this.model.setHighlightFullBarEnabled(false)
        this.leftAxis = this.model.getAxisLeft()
        if (let Some(leftaxis) <- this.leftAxis) {
            leftaxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART)
            leftaxis.setDrawLabels(false)
            leftaxis.setSpaceTop(25.0)
            leftaxis.setSpaceBottom(25.0)
            leftaxis.setDrawAxisLine(false)
            leftaxis.setDrawGridLines(false)
            leftaxis.setDrawZeroLine(true)
            leftaxis.setDrawLimitLinesBehindData(false)
            leftaxis.setZeroLineWidth(0.7)
        }
        this.rightAxis = this.model.getAxisRight()
        if (let Some(rightaxis) <- this.rightAxis) {
            rightaxis.setEnabled(false)
        }
        this.xAxis = this.model.getXAxis()
        if (let Some(xaxis) <- this.xAxis) {
            xaxis.setPosition(XAxisPosition.BOTTOM)
            xaxis.setDrawLabels(false)
            xaxis.setDrawGridLines(false)
            xaxis.setDrawAxisLine(false)
            xaxis.setCenterAxisLabels(true)
            xaxis.setLabelCount(5, true)
            xaxis.setGranularity(1.0)
        }
        this.normalMarker = MarkerView()
        this.model.setMarker(this.normalMarker)
        this.setData(4, 110)
        return this.model
    }
    private func setData(count: Int64, range: Int64): Unit {
        let startAxis: Int64 = 0
        let endAxis: Int64 = startAxis + count
        let values: ArrayList<BarEntry> = ArrayList<BarEntry>()
        let valueColors: ArrayList<UInt32> = ArrayList<UInt32>()
        for (i in startAxis..endAxis) {
            let val = Random().nextFloat64() * Float64(range) - Float64(range / 2)
            values.append(BarEntry(Float64(i), val))
        }
        for (i in 0..values.size) {
            if (values[i].getY() > 0.0) {
                valueColors.append(0xD34A58)
            } else {
                valueColors.append(0x6EBE66)
            }
        }
        let dataSet: BarDataSet = BarDataSet(values, "DataSet")
        dataSet.setValueTextColors(valueColors)
        dataSet.setColorsByVariable(valueColors.toArray())
        dataSet.setDrawValues(true)
        let dataSetList: ArrayList<IBarDataSet> = ArrayList<IBarDataSet>()
        dataSetList.append(dataSet)
        let barData: BarData = BarData(dataSetList)
        barData.setBarWidth(0.8)
        this.model.setData(barData)
        this.model.setBorderWidth(5.0)
        this.model.setBorderColor(0xfff4ee)
        this.model.setDrawBorders(true)
    }
    func render() {
        Column {
            Text(this.title).fontSize(21).fontColor(Color.WHITE).fontWeight(FontWeight.W600).layoutWeight(1).maxLines(1)
            BarChart(model: aboutToAppear())
        }.width(100.percent).height(70.percent).backgroundColor(Color.WHITE)
    }
}