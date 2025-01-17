package ohos_app_cangjie_entry.barPage
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
@Entry
@Component
class StackedBarChartPage {
    private var model: BarChartModel = BarChartModel.build()
    private var leftAxis: ?YAxis = Option<YAxis>.None
    private var rightAxis: ?YAxis = Option<YAxis>.None
    private var xAxis: ?XAxis = Option<XAxis>.None
    private var limitLine1: LimitLine = LimitLine(0.0, "limit1")
    private var limitLine2: LimitLine = LimitLine(0.0, "limit2")
    private var barData: BarData = BarData()
    protected override func aboutToAppear() {
        let description: Description = this.model.getDescription()
        description.setEnabled(false)
        let l: ?Legend = this.model.getLegend()
        if (let Some(l) <- l) {
            l.setEnabled(false)
        }
        // if more than 40 entries are displayed in the this.model, no values will be drawn
        this.model.setMaxVisibleValueCount(40)
        this.model.setDrawGridBackground(false)
        this.model.setGridBackgroundColor(0x500000ff)
        this.model.setDrawBarShadow(false)
        this.model.setDrawValueAboveBar(false)
        this.limitLine1 = LimitLine(120.0, "Upper Limit")
        this.limitLine1.setLineWidth(4.0)
        this.limitLine1.enableDashedLine(10, 10)
        this.limitLine1.setLabelPosition(LimitLabelPosition.RIGHT_TOP)
        this.limitLine1.setTextSize(10.0)
        this.limitLine2 = LimitLine(50.0, "Lower Limit")
        this.limitLine2.setLineWidth(4.0)
        this.limitLine2.enableDashedLine(10, 10)
        this.limitLine2.setLineColor(0xFFFF00)
        this.limitLine2.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM)
        this.limitLine2.setTextSize(10.0)
        this.leftAxis = this.model.getAxisLeft()
        if (let Some(leftAxis) <- this.leftAxis) {
            leftAxis.setAxisMinimum(0.0)
            leftAxis.setDrawLimitLinesBehindData(false)
            leftAxis.addLimitLine(this.limitLine1)
            leftAxis.addLimitLine(this.limitLine2)
        }
        this.rightAxis = this.model.getAxisRight()
        if (let Some(rightAxis) <- this.rightAxis) {
            rightAxis.setEnabled(false)
            rightAxis.setAxisMinimum(0.0)
        }
        this.xAxis = this.model.getXAxis()
        if (let Some(xAxis) <- this.xAxis) {
            xAxis.setPosition(XAxisPosition.TOP)
        }
        this.barData = this.getStackData()
        this.model.setData(this.barData)
        this.model.setVisibleXRangeMaximum(20.0)
    }
    private func getStackData(): BarData {
        let values: ArrayList<BarEntry> = ArrayList<BarEntry>()
        values.append(BarEntry(1.0, [38.0, 28.0, 39.8]))
        values.append(BarEntry(2.0, [18.2, 16.1, 16.1]))
        values.append(BarEntry(3.0, [45.8, 49.8, 26.7]))
        values.append(BarEntry(4.0, [36.5, 43.8, 15.1]))
        values.append(BarEntry(5.0, [51.5, 35.4, 24.1]))
        values.append(BarEntry(6.0, [44.9, 21.4, 15.9]))
        values.append(BarEntry(7.0, [32.9, 40.4, 32.7]))
        values.append(BarEntry(8.0, [24.3, 31.0, 47.1]))
        values.append(BarEntry(9.0, [17.4, 48.4, 49.6]))
        values.append(BarEntry(10.0, [32.0, 29.8, 20.0]))
        values.append(BarEntry(11.0, [43.9, 52.7, 27.7]))
        values.append(BarEntry(12.0, [28.4, 46.2, 51.8]))
        values.append(BarEntry(13.0, [42.6, 51.9, 44.0]))
        values.append(BarEntry(14.0, [14.8, 22.4, 31.2]))
        values.append(BarEntry(15.0, [50.3, 18.7, 18.3]))
        values.append(BarEntry(16.0, [20.7, 22.9, 40.2]))
        values.append(BarEntry(17.0, [49.4, 38.3, 41.7]))
        values.append(BarEntry(18.0, [45.9, 40.7, 29.5]))
        values.append(BarEntry(19.0, [37.1, 31.8, 42.9]))
        let set1: BarDataSet
        set1 = BarDataSet(values, "Statistics Vienna 2014")
        set1.setDrawIcons(false)
        set1.setColorsByVariable(this.getColors())
        set1.setStackLabels(["Births", "Divorces", "Marriages"])
        let dataSets: ArrayList<IBarDataSet> = ArrayList<IBarDataSet>()
        dataSets.append(set1)
        let data: BarData = BarData(dataSets)
        data.setValueTextColor(0xffffff)
        return data
    }
    private func getColors(): Array<UInt32> {
        let colors: Array<UInt32> = [UInt32(ColorTemplate.MATERIAL_COLORS[0]), UInt32(ColorTemplate.MATERIAL_COLORS[1]),
        UInt32(ColorTemplate.MATERIAL_COLORS[2])]
        return colors
    }
    func build() {
        Column {
            BarChart(model: this.model)
        }.width(100.percent).height(70.percent).backgroundColor(Color.WHITE)
    }
}