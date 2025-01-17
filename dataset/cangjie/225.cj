package ohos_app_cangjie_entry.readmeTest
import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.{ArrayList}
import std.math.*
import std.random.*
import chart.pie.*
import chart.utils.*
import chart.bar.*
import chart.charts.*
import chart.components.*
@Entry
@Component
class BarChartPageReadme {
    private var model: BarChartModel = BarChartModel.build()
    private var leftAxis: ?YAxis = Option<YAxis>.None
    private var rightAxis: ?YAxis = Option<YAxis>.None
    private var xAxis: ?XAxis = Option<XAxis>.None
    private var barData: BarData = BarData()
    protected override func aboutToAppear() {
        let description: Description = this.model.getDescription() // 获取图表描述部件
        description.setEnabled(false) //设置图表描述部件不可用
        let l: ?Legend = this.model.getLegend() // 获取图表图例部件，设置图表图例部件不可用
        if (let Some(v) <- l) {
            v.setEnabled(true) //设置图表图例部件可用
            v.setOrientation(LegendOrientation.HORIZONTAL) // 设置图例方向为垂直
            v.setVerticalAlignment(LegendVerticalAlignment.BOTTOM) // 设置图例垂直对齐方式为底部
            v.setHorizontalAlignment(LegendHorizontalAlignment.CENTER) // 设置图例水平对齐方式为左侧
            v.setDrawInside(false) // 设置图例绘制在图表外部
        }
        this.model.setMaxVisibleValueCount(60) // 设置图表最大可见数值数量
        this.model.setDrawGridBackground(false) // 设置图表网格背景色
        this.model.setGridBackgroundColor(0x500000ff) // 设置图表网格背景颜色
        this.model.setDrawBarShadow(false) // 设置不绘制图的柱体阴影背景
        this.model.setDrawValueAboveBar(true) // 设置瀑布图的数值在柱体上方
        this.leftAxis = this.model.getAxisLeft()
        if (let Some(leftaxis) <- this.leftAxis) {
            leftaxis.setAxisMinimum(0.0) // 设置左侧Y轴的最小值为 0
            leftaxis.setDrawLimitLinesBehindData(true) // 设置是否在数据后绘制限制线
            leftaxis.setSpaceTop(30.0) //设置距离顶部距离
            leftaxis.enableGridDashedLine(10, 10) //设置网格样式
        }
        this.rightAxis = this.model.getAxisRight()
        if (let Some(rightaxis) <- this.rightAxis) {
            rightaxis.setEnabled(false) // 设置右侧 Y 轴是否显示
            rightaxis.setDrawGridLines(false) //不绘制 Y 轴网格线
            rightaxis.setLabelCount(6, false) // 设置右侧 Y 轴标签数量
            rightaxis.setSpaceTop(11.0) //设置距离顶部距离
        }
        this.xAxis = this.model.getXAxis()
        if (let Some(xaxis) <- this.xAxis) {
            xaxis.setLabelCount(5, false) // 设置 X 轴标签数量
            xaxis.setPosition(XAxisPosition.BOTTOM) // 设置X轴位置在底部
        }
        if (this.xAxis.isSome() && this.leftAxis.isSome()) {
            this.setData(5, 110)
        }
    }
    private func setData(count: Int64, range: Int64): Unit {
        let groupSpace: Float64 = 0.08
        let barSpace: Float64 = 0.03
        let barWidth: Float64 = 0.2
        let startYear: Int64 = 1980
        let endYear: Int64 = startYear + count
        let values1: ArrayList<BarEntry> = ArrayList<BarEntry>()
        let values2: ArrayList<BarEntry> = ArrayList<BarEntry>()
        let values3: ArrayList<BarEntry> = ArrayList<BarEntry>()
        let values4: ArrayList<BarEntry> = ArrayList<BarEntry>()
        let randomMultiplier: Int64 = range
        for (i in startYear..endYear) {
            values1.append(BarEntry(Float64(i), (Random().nextFloat64() * Float64(randomMultiplier))))
            values2.append(BarEntry(Float64(i), (Random().nextFloat64() * Float64(randomMultiplier))))
            values3.append(BarEntry(Float64(i), (Random().nextFloat64() * Float64(randomMultiplier))))
            values4.append(BarEntry(Float64(i), (Random().nextFloat64() * Float64(randomMultiplier))))
        }
        var set1: ?BarDataSet
        var set2: ?BarDataSet
        var set3: ?BarDataSet
        var set4: ?BarDataSet
        if (this.model.getBarData().isSome() && this.model.getBarData()().getDataSetCount() > 0) {
            set1 = this.model.getBarData()().getDataSetByIndex(0) as BarDataSet
            set2 = this.model.getBarData()().getDataSetByIndex(1) as BarDataSet
            set3 = this.model.getBarData()().getDataSetByIndex(2) as BarDataSet
            set4 = this.model.getBarData()().getDataSetByIndex(3) as BarDataSet
            set1().setEntries(values1)
            set2().setEntries(values2)
            set3().setEntries(values3)
            set4().setEntries(values4)
            this.model.getBarData()().notifyDataChanged()
            this.model.notifyDataSetChanged()
        } else {
            set1 = BarDataSet(values1, "Company A")
            set1().setColorsByArr([0x2b89ab]) // 设置柱状图颜色
            set2 = BarDataSet(values2, "Company B")
            set2().setColorsByArr([0xcd4e2e])
            set3 = BarDataSet(values3, "Company C")
            set3().setColorsByArr([0xacc045])
            set4 = BarDataSet(values4, "Company D")
            set4().setColorsByArr([0x224058])
            let dataSets: ArrayList<IBarDataSet> = ArrayList<IBarDataSet>()
            dataSets.append(set1())
            dataSets.append(set2())
            dataSets.append(set3())
            dataSets.append(set4())
            let data: BarData = BarData(dataSets)
            this.model.setData(data)
        }
        this.model.getBarData()().setBarWidth(barWidth) // 设置柱状图宽度
        this.xAxis().setAxisMinimum(Float64(startYear)) // 设置轴最小值
        this.xAxis().setAxisMaximum(
            Float64(startYear) + this.model.getBarData()().getGroupWidth(groupSpace, barSpace) * Float64(count)) // 设置轴最大值
        this.model.groupBars(Float64(startYear), groupSpace, barSpace) // 设置柱状图分组
        this.model.invalidate() //手动触发图表重新绘制
    }
    func build() {
        Column {
            // 为组件设置配置构建类，如果需要在页面初始化就显示图表，则需要在 aboutToAppear 方法中完成图表数据构建
            // 如果在之后通过事件触发，
            // 可通过 barData.notifyDataSetChanged() 来触发数据更新，
            // 可通过 this.model.notifyDataSetChanged() 来触发坐标轴数据更新，
            // 可通过 this.model.invalidate() 来触发绘制更新。
            BarChart(model: this.model)
        }.width(100.percent).height(70.percent).backgroundColor(Color.WHITE)
    }
}
extend<T> Option<T> {
    operator func ()(): T {
        this.getOrThrow()
    }
}