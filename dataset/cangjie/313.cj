package barPage
@Entry
@Component
class ScrollBarChartPage {
    private var title: String = "scroll bar"
    private var model: BarChartModel = BarChartModel.build()
    private var leftAxis: ?YAxis = Option<YAxis>.None
    private var rightAxis: ?YAxis = Option<YAxis>.None
    private var xAxis: ?XAxis = Option<XAxis>.None
    private var limitLine1: LimitLine = LimitLine(100.0, "limit1")
    private var limitLine2: LimitLine = LimitLine(20.0, "limit2")
    private var barData: BarData = BarData()
    private var mBarWidth: String = "85"
    private var mBackgroundColor: String = "#500000ff"
    private var mLastMaxVisibleXCount: String = "20"
    private var mCurrentMaxVisibleXCount: String = "20"
    private var normalMarker: ?MarkerView = Option<MarkerView>.None
    //private var stackMarker: CustomMarkerView
    private var isChangedMaxVisibleXCount: Bool = false
    func aboutToAppear(): BarChartModel {
        this.model.setDragEnabled(false) //禁用滑动
        this.model.setScaleEnabled(false) //禁用缩放
        let description: Description = this.model.getDescription()
        description.setEnabled(true)
        let l: ?Legend = this.model.getLegend()
        if (let Some(legend) <- l) {
            legend.setEnabled(true)
        }
        this.model.setMaxVisibleValueCount(40)
        // scaling can now only be done on x- and y-axis separately
        this.model.setPinchZoom(false)
        this.model.setDrawGridBackground(false)
        this.model.setGridBackgroundColor(UInt32(0x500000ff))
        this.model.setDrawBarShadow(false)
        this.model.setDrawValueAboveBar(false)
        this.model.setHighlightFullBarEnabled(false)
        //设置长按事件自定义view
        //this.model.setLongPressMarker(LongPressMarkerView())
        this.limitLine1 = LimitLine(120.0, "Upper Limit")
        this.limitLine1.setLineWidth(4.0)
        this.limitLine1.enableDashedLine(10, 10, 0)
        this.limitLine1.setLabelPosition(LimitLabelPosition.RIGHT_TOP)
        this.limitLine1.setTextSize(10.0)
        this.limitLine2 = LimitLine(50.0, "Lower Limit")
        this.limitLine2.setLineWidth(4.0)
        this.limitLine2.enableDashedLine(10, 10, 0)
        this.limitLine2.setLineColor(0xffff00)
        this.limitLine2.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM)
        this.limitLine2.setTextSize(10.0)
        this.leftAxis = this.model.getAxisLeft()
        if (let Some(leftaxis) <- this.leftAxis) {
            leftaxis.setAxisMinimum(0.0)
            leftaxis.setDrawLimitLinesBehindData(false)
            leftaxis.addLimitLine(this.limitLine1)
            leftaxis.addLimitLine(this.limitLine2)
        }
        this.rightAxis = this.model.getAxisRight()
        if (let Some(rightaxis) <- this.rightAxis) {
            rightaxis.setEnabled(false)
            rightaxis.setAxisMinimum(0.0)
        }
        this.xAxis = this.model.getXAxis()
        if (let Some(xaxis) <- this.xAxis) {
            xaxis.setPosition(XAxisPosition.BOTTOM)
        }
        this.normalMarker = MarkerView()
        this.model.setMarker(this.normalMarker())
        //this.stackMarker = new CustomMarkerView()
        this.barData = this.getNormalData()
        this.model.setData(this.barData)
        this.model.setVisibleXRangeMaximum(20.0)
        return this.model
    }
    private func getNormalData(): BarData {
        let values: ArrayList<BarEntry> = ArrayList<BarEntry>()
        values.append(BarEntry(1.0, 73.3))
        values.append(BarEntry(2.0, 5.4))
        values.append(BarEntry(3.0, 73.9))
        values.append(BarEntry(4.0, 79.9))
        values.append(BarEntry(5.0, 69.3))
        values.append(BarEntry(6.0, 70.7))
        values.append(BarEntry(7.0, 81.2))
        values.append(BarEntry(8.0, 13.1))
        values.append(BarEntry(9.0, 34.2))
        values.append(BarEntry(10.0, 58.4))
        values.append(BarEntry(11.0, 44.7))
        values.append(BarEntry(12.0, 10.5))
        values.append(BarEntry(13.0, 15.6))
        values.append(BarEntry(14.0, 95.8))
        values.append(BarEntry(15.0, 57.4))
        values.append(BarEntry(16.0, 64.5))
        values.append(BarEntry(17.0, 21.4))
        values.append(BarEntry(18.0, 33.2))
        values.append(BarEntry(19.0, 96.9))
        let dataSet: BarDataSet = BarDataSet(values, "DataSet")
        dataSet.setHighLightColor(0x000000)
        dataSet.setDrawIcons(false)
        dataSet.setColorByColor(0xFFC0CB)
        let dataSetList: ArrayList<IBarDataSet> = ArrayList<IBarDataSet>()
        dataSetList.append((dataSet as IBarDataSet)())
        let barData: BarData = BarData(dataSetList)
        barData.setBarWidth(0.85)
        return barData
    }
    private func getGradientData(): BarData {
        let values: ArrayList<BarEntry> = ArrayList<BarEntry>()
        values.append(BarEntry(1.0, 32.9))
        values.append(BarEntry(2.0, 44.7))
        values.append(BarEntry(3.0, 2.1))
        values.append(BarEntry(4.0, 46.9))
        values.append(BarEntry(5.0, 8.8))
        values.append(BarEntry(6.0, 82.1))
        values.append(BarEntry(7.0, 86.9))
        values.append(BarEntry(8.0, 15.9))
        values.append(BarEntry(9.0, 29.4))
        values.append(BarEntry(10.0, 71.6))
        values.append(BarEntry(11.0, 55.7))
        values.append(BarEntry(12.0, 35.8))
        values.append(BarEntry(13.0, 67.7))
        values.append(BarEntry(14.0, 34.9))
        values.append(BarEntry(15.0, 50.9))
        values.append(BarEntry(16.0, 40.5))
        values.append(BarEntry(17.0, 27.1))
        values.append(BarEntry(18.0, 45.7))
        values.append(BarEntry(19.0, 26.8))
        let dataSet: BarDataSet = BarDataSet(values, "DataSet")
        dataSet.setHighLightColor(UInt32(0x000000))
        dataSet.setDrawIcons(false)
        let startColor1: UInt32 = UInt32(0xDC143C)
        let startColor2: UInt32 = UInt32(0xFFF0F5)
        let startColor3: UInt32 = UInt32(0xDB7093)
        let startColor4: UInt32 = UInt32(0xFF69B4)
        let startColor5: UInt32 = UInt32(0xFF1493)
        let endColor1: UInt32 = UInt32(0xC71585)
        let endColor2: UInt32 = UInt32(0xDA70D6)
        let endColor3: UInt32 = UInt32(0xD8BFD8)
        let endColor4: UInt32 = UInt32(0xDDA0DD)
        let endColor5: UInt32 = UInt32(0xEE82EE)
        let gradientFills: ArrayList<Fill> = ArrayList<Fill>()
        gradientFills.append(Fill(startColor1, endColor1))
        gradientFills.append(Fill(startColor2, endColor2))
        gradientFills.append(Fill(startColor3, endColor3))
        gradientFills.append(Fill(startColor4, endColor4))
        gradientFills.append(Fill(startColor5, endColor5))
        dataSet.setFills(gradientFills)
        let dataSetList: ArrayList<IBarDataSet> = ArrayList<IBarDataSet>()
        dataSetList.append((dataSet as IBarDataSet)())
        let barData: BarData = BarData(dataSetList)
        barData.setBarWidth(0.85)
        return barData
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
        set1.setColorsByArr([UInt32(0xDC143C), UInt32(0x5F9EA0), UInt32(0x7CFC00)])
        set1.setStackLabels(["Births", "Divorces", "Marriages"])
        let dataSets: ArrayList<IBarDataSet> = ArrayList<IBarDataSet>()
        dataSets.append(set1)
        let data: BarData = BarData(dataSets)
        data.setValueTextColor(UInt32(0xffffff))
        return data
    }
    func render() {
        Column {
            Text(this.title).fontSize(21).fontColor(Color.WHITE).fontWeight(FontWeight.W600).layoutWeight(1).maxLines(1)
            BarChart(model: aboutToAppear())
            Divider().width(1).padding(top: 5)
            Scroll() {
                Stack() {
                    Column() {
                        Row() {
                            Text("数据类型： ")
                            Row() {
                                Text("普通: ")
                                Radio(value: "normal", group: "dataType").checked(true).onChange(
                                    {
                                    isChecked: Bool => if (isChecked) {
                                        this.barData = this.getNormalData()
                                        //                                  if (this.normalMarker) {
                                        //                                    this.model.setMarker(this.normalMarker)
                                        //                                  }
                                        this.model.setData(this.barData)
                                        if (this.isChangedMaxVisibleXCount) {
                                            this.model.setVisibleXRangeMaximum(
                                                Float64.parse(this.mLastMaxVisibleXCount))
                                            this.model.setVisibleXRangeMinimum(
                                                Float64.parse(this.mLastMaxVisibleXCount))
                                            this.barData.notifyDataChanged()
                                            this.model.notifyDataSetChanged()
                                            this.model.invalidate()
                                        }
                                    }
                                })
                            }
                            Row() {
                                Text("渐变: ")
                                Radio(value: "gradient", group: "dataType").checked(false).onChange(
                                    {
                                    isChecked: Bool => if (isChecked) {
                                        this.barData = this.getGradientData()
                                        //                                                      if (this.normalMarker) {
                                        //                                                        this.model.setMarker(this.normalMarker)
                                        //                                                      }
                                        this.model.setData(this.barData)
                                        if (this.isChangedMaxVisibleXCount) {
                                            this.model.setVisibleXRangeMaximum(
                                                Float64.parse(this.mLastMaxVisibleXCount))
                                            this.model.setVisibleXRangeMinimum(
                                                Float64.parse(this.mLastMaxVisibleXCount))
                                            this.barData.notifyDataChanged()
                                            this.model.notifyDataSetChanged()
                                            this.model.invalidate()
                                        }
                                    }
                                })
                            }
                            Row() {
                                Text("堆叠: ")
                                Radio(value: "stack", group: "dataType").checked(false).onChange(
                                    {
                                    isChecked: Bool => if (isChecked) {
                                        this.barData = this.getStackData()
                                        //                          if (this.stackMarker) {
                                        //                            this.model.setMarker(this.stackMarker)
                                        //                          }
                                        this.model.setData(this.barData)
                                        if (this.isChangedMaxVisibleXCount) {
                                            this.model.setVisibleXRangeMaximum(
                                                Float64.parse(this.mLastMaxVisibleXCount))
                                            this.model.setVisibleXRangeMinimum(
                                                Float64.parse(this.mLastMaxVisibleXCount))
                                            this.barData.notifyDataChanged()
                                            this.model.notifyDataSetChanged()
                                            this.model.invalidate()
                                        }
                                    }
                                })
                            }
                        }.alignSelf(ItemAlign.Start)
                        Row() {
                            Text("数据类型： ")
                            Row() {
                                Text("NoData: ")
                                Radio(value: "noData", group: "dataType").checked(false).onChange(
                                    {
                                    isChecked: Bool => if (isChecked) {
                                        // this.model.setData(null)
                                        this.model.invalidate()
                                    }
                                })
                            }
                        }
                        Row() {
                            Text("NoDataSets: ")
                            Radio(value: "gradient", group: "dataType").checked(false).onChange(
                                {
                                isChecked: Bool => if (isChecked) {
                                    this.barData = BarData(ArrayList<IBarDataSet>())
                                    this.model.setData(this.barData)
                                }
                            })
                        }
                    }.alignSelf(ItemAlign.Start)
                    Row() {
                        Text("Y轴是否显示： ")
                        Row() {
                            Text("左Y轴: ")
                            Checkbox(name: "leftYAxis", group: "yAxis").select(true).onChange(
                                {
                                isChecked: Bool => if (this.leftAxis.isSome()) {
                                    this.leftAxis().setEnabled(isChecked)
                                }
                            })
                        }
                        Row() {
                            Text("右Y轴: ")
                            Checkbox(name: "rightYAxis", group: "yAxis").onChange(
                                {
                                isChecked: Bool => if (this.rightAxis.isSome()) {
                                    this.rightAxis().setEnabled(isChecked)
                                }
                            })
                        }
                    }.alignSelf(ItemAlign.Start)
                    Row() {
                        Text("左Y轴位置： ")
                        Row() {
                            Text("表外: ")
                            Radio(value: "outSideChart", group: "leftYAxisLabelPosition").checked(true).onChange(
                                {
                                isChecked: Bool => if (this.leftAxis.isSome() && isChecked) {
                                    this.leftAxis().setPosition(YAxisLabelPosition.OUTSIDE_CHART)
                                }
                            })
                        }
                        Row() {
                            Text("表内: ")
                            Radio(value: "inSideChart", group: "leftYAxisLabelPosition").checked(false).onChange(
                                {
                                isChecked: Bool => if (this.leftAxis.isSome() && isChecked) {
                                    this.leftAxis().setPosition(YAxisLabelPosition.INSIDE_CHART)
                                }
                            })
                        }.padding(left: 20)
                    }.alignSelf(ItemAlign.Start)
                    Row() {
                        Text("右Y轴位置： ")
                        Row() {
                            Text("表外: ")
                            Radio(value: "outSideChart", group: "rightYAxisLabelPosition").checked(true).onChange(
                                {
                                isChecked: Bool => if (this.rightAxis.isSome() && isChecked) {
                                    this.rightAxis().setPosition(YAxisLabelPosition.OUTSIDE_CHART)
                                }
                            })
                        }
                        Row() {
                            Text("表内: ")
                            Radio(value: "inSideChart", group: "rightYAxisLabelPosition").checked(false).onChange(
                                {
                                isChecked: Bool => if (this.rightAxis.isSome() && isChecked) {
                                    this.rightAxis().setPosition(YAxisLabelPosition.INSIDE_CHART)
                                }
                            })
                        }.padding(left: 20)
                    }.alignSelf(ItemAlign.Start)
                    Row() {
                        Text("X轴是否显示： ")
                        Row() {
                            Text("X轴: ")
                            Checkbox(name: "isShowXAxis", group: "xAxis").select(true).onChange(
                                {
                                isChecked: Bool => if (this.xAxis.isSome()) {
                                    this.xAxis().setEnabled(isChecked)
                                }
                            })
                        }
                    }.alignSelf(ItemAlign.Start)
                    Text("X轴位置").alignSelf(ItemAlign.Start)
                    Row() {
                        Column() {
                            Text("top")
                            Radio(value: "top", group: "xAxisLabelPosition").checked(false).onChange(
                                {
                                isChecked: Bool => if (this.xAxis.isSome() && isChecked) {
                                    this.xAxis().setPosition(XAxisPosition.TOP)
                                }
                            })
                        }.layoutWeight(1)
                        Column() {
                            Text("bottom")
                            Radio(value: "bottom", group: "xAxisLabelPosition").checked(true).onChange(
                                {
                                isChecked: Bool => if (this.xAxis.isSome() && isChecked) {
                                    this.xAxis().setPosition(XAxisPosition.BOTTOM)
                                }
                            })
                        }.layoutWeight(1)
                        Column() {
                            Text("both side")
                            Radio(value: "both", group: "xAxisLabelPosition").checked(false).onChange(
                                {
                                isChecked: Bool => if (this.xAxis.isSome() && isChecked) {
                                    this.xAxis().setPosition(XAxisPosition.BOTH_SIDED)
                                }
                            })
                        }.layoutWeight(1)
                        Column() {
                            Text("top")
                            Text("InSide")
                            Radio(value: "topInSide", group: "xAxisLabelPosition").checked(false).onChange(
                                {
                                isChecked: Bool => if (this.xAxis.isSome() && isChecked) {
                                    this.xAxis().setPosition(XAxisPosition.TOP_INSIDE)
                                }
                            })
                        }.layoutWeight(1)
                        Column() {
                            Text("bottom")
                            Text("InSide")
                            Radio(value: "bottomInSide", group: "xAxisLabelPosition").checked(false).onChange(
                                {
                                isChecked: Bool => if (this.xAxis.isSome() && isChecked) {
                                    this.xAxis().setPosition(XAxisPosition.BOTTOM_INSIDE)
                                }
                            })
                        }.layoutWeight(1)
                    }.alignSelf(ItemAlign.Start)
                    Row() {
                        Text("X轴标签最大显示数：")
                        TextInput(text: this.mLastMaxVisibleXCount, placeholder: "please input xAxis labels count. ").
                            layoutWeight(1).setType(InputType.Number).onChange(
                            {
                            value => this.mCurrentMaxVisibleXCount = value
                        }).onSubmit(
                            {
                            _ => if (Float64.parse(this.mCurrentMaxVisibleXCount) > 0.0) {
                                let numValue: Float64 = Float64.parse(this.mCurrentMaxVisibleXCount)
                                if (numValue <= Float64.parse(this.mLastMaxVisibleXCount) && numValue > 0.0) {
                                    this.isChangedMaxVisibleXCount = true
                                    this.mLastMaxVisibleXCount = this.mCurrentMaxVisibleXCount
                                    this.model.setVisibleXRangeMaximum(numValue)
                                    this.barData.notifyDataChanged()
                                    PromptAction.showToast(
                                        message: "X轴标签最大显示数已设置为：${this.mLastMaxVisibleXCount}"
                                    )
                                } else {
                                    PromptAction.showToast(
                                        message: "请输入小于等于${this.mLastMaxVisibleXCount}的正整数 ")
                                }
                            } else {
                                PromptAction.showToast(
                                    message: " 请输入小于等于${this.mLastMaxVisibleXCount}的正整数")
                            }
                        })
                    }.alignSelf(ItemAlign.Start)
                    Row() {
                        Text("是否绘制背景色： ")
                        Checkbox(name: "isDrawBackground", group: "isDrawBackground").select(false).onChange(
                            {
                            isChecked: Bool => this.model.setDrawGridBackground(isChecked)
                        })
                    }.alignSelf(ItemAlign.Start)
                    Row() {
                        Text("背景色： ")
                        TextInput(text: "#500000ff", placeholder: "please input background color.ex:#500000ff/#0000ff").
                            layoutWeight(1).onChange({
                            value => this.mBackgroundColor = value
                        }).onSubmit(
                            {
                            _ => if (this.mBackgroundColor != "") {
                                this.model.setGridBackgroundColor(UInt32.parse(this.mBackgroundColor))
                                PromptAction.showToast(message: "背景色已设置为：  ${this.mBackgroundColor} ")
                            }
                        })
                    }.alignSelf(ItemAlign.Start)
                    Row() {
                        Text("是否设置MarkerView: ")
                        Checkbox(name: "isShowMarkerView", group: "isShowMarkerView").select(true).onChange(
                            {
                            isChecked: Bool => this.model.setDrawMarkerViews(isChecked)
                        })
                    }.alignSelf(ItemAlign.Start)
                    Row() {
                        Text("设置柱状图显示宽度百分比：")
                        TextInput(text: "85", placeholder: "please input bar width percent.").layoutWeight(1).setType(
                            InputType.Number).onChange({
                            value => this.mBarWidth = value
                        }).onSubmit(
                            {
                                _ =>
                                let percent: Int64 = Int64.parse(this.mBarWidth)
                                if (percent > 0 && percent <= 100) {
                                    this.barData.setBarWidth(Float64(percent / 100))
                                    PromptAction.showToast(
                                        message: "柱状图显示宽度百分比已设置为：${this.mBarWidth}")
                                } else {
                                    PromptAction.showToast(message: "请输入1-100之间的正整数")
                                }
                            }
                        )
                    }.alignSelf(ItemAlign.Start)
                    Row() {
                        Text("LimitLine是否在数据后： ")
                        Checkbox(name: "isShowLimitLineBehindData", group: "isShowLimitLineBehindData").select(false).
                            onChange({
                            isChecked: Bool => this.leftAxis().setDrawLimitLinesBehindData(isChecked)
                        })
                    }.alignSelf(ItemAlign.Start)
                    Row() {
                        Column() {
                            Text("左Y轴")
                            Text("LimitLine")
                            Text("位置")
                        }
                        Column() {
                            Text("both")
                            Radio(value: "both", group: "limitLinePosition").checked(true).onChange(
                                {
                                isChecked: Bool => if (isChecked) {
                                    this.leftAxis().removeAllLimitLines()
                                    this.leftAxis().addLimitLine(this.limitLine1)
                                    this.leftAxis().addLimitLine(this.limitLine2)
                                }
                            })
                        }.layoutWeight(1)
                        Column() {
                            Text("none")
                            Radio(value: "none", group: "limitLinePosition").checked(false).onChange(
                                {
                                isChecked: Bool => if (isChecked) {
                                    this.leftAxis().removeAllLimitLines()
                                }
                            })
                        }.layoutWeight(1)
                        Column() {
                            Text("upper")
                            Radio(value: "upper", group: "limitLinePosition").checked(false).onChange(
                                {
                                isChecked: Bool => if (isChecked) {
                                    this.leftAxis().removeAllLimitLines()
                                    this.leftAxis().addLimitLine(this.limitLine1)
                                }
                            })
                        }.layoutWeight(1)
                        Column() {
                            Text("lower")
                            Radio(value: "lower", group: "limitLinePosition").checked(false).onChange(
                                {
                                isChecked: Bool => if (isChecked) {
                                    this.leftAxis().removeAllLimitLines()
                                    this.leftAxis().addLimitLine(this.limitLine2)
                                }
                            })
                        }.layoutWeight(1)
                    }.alignSelf(ItemAlign.Start)
                    Button("刷新").margin(top: 100).onClick(
                        {
                            _ =>
                            this.model.notifyDataSetChanged()
                            this.model.invalidate()
                        }
                    )
                }.align(Alignment.TopEnd)
            }.layoutWeight(1).margin(bottom: 50)
        }.width(100.percent).height(70.percent).backgroundColor(Color.WHITE)
    }
}