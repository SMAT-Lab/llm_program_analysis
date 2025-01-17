package matplot
foreign func c_scatter(
    x: CPointer<Unit>, x_len: Int64,
    y: CPointer<Unit>, y_len: Int64): CPointer<Unit>
foreign func c_scatter_with_size(
    x: CPointer<Unit>, x_len: Int64,
    y: CPointer<Unit>, y_len: Int64,
    sz: CPointer<Unit>, sz_len: Int64): CPointer<Unit>
foreign func c_scatter_with_size_and_color(
    x: CPointer<Unit>, y: CPointer<Unit>,
    sz: CPointer<Unit>, color: CPointer<Unit>, len: Int64): CPointer<Unit>
foreign func c_scatter_with_Size_and_color(
    x: CPointer<Unit>, y: CPointer<Unit>, sz: Float64,
    color: CPointer<Unit>, len: Int64): CPointer<Unit>
foreign func c_scatter_with_Size(
    x: CPointer<Unit>, y: CPointer<Unit>, sz: Float64, len: Int64): CPointer<Unit>
foreign func c_axes_scatter(
    axes: CPointer<Unit>, x: CPointer<Unit>, x_len: Int64,
    y: CPointer<Unit>, y_len: Int64): CPointer<Unit>
public func scatter(x: Vector<Float64>, y: Vector<Float64>): Line {
    let size = x.size()
    let handle = unsafe { c_scatter(x.ptr, size, y.ptr, size) }
    return Line(handle)
}
public func scatter(x: Vector<Float64>, y: Vector<Float64>, sz: Vector<Float64>): Line {
    let size = x.size()
    let handle = unsafe { c_scatter_with_size(x.ptr, size, y.ptr, size, sz.ptr, size) }
    return Line(handle)
}
public func scatter(x: Vector<Float64>, y: Vector<Float64>, sz: Vector<Float64>, color: Vector<Float64>): Line {
    let size = x.size()
    let handle = unsafe { c_scatter_with_size_and_color(x.ptr, y.ptr, sz.ptr, color.ptr, size) }
    return Line(handle)
}
public func scatter(x: Vector<Float64>, y: Vector<Float64>, sz: Float64) {
    let size = x.size()
    let handle = unsafe { c_scatter_with_Size(x.ptr, y.ptr, sz, size) }
    return Line(handle)
}
public func scatter(x: Vector<Float64>, y: Vector<Float64>, sz: Float64, color: Vector<Float64>) {
    let size = x.size()
    let handle = unsafe { c_scatter_with_Size_and_color(x.ptr, y.ptr, sz, color.ptr, size) }
    return Line(handle)
}
public func scatter(axes: AxesType, x: Vector<Float64>, y: Vector<Float64>): Line {
    let size = x.size()
    let handle = unsafe { c_axes_scatter(axes.ptr, x.ptr, size, y.ptr, size) }
    return Line(handle)
}
public func testScatterPlot1() {
    print("    - testScatterPlot1\n")
    var r : Random = Random(1)
    let x = linspace<Float64>(0.0, 3.0 * Float64.PI, num: 200)
    let y = x.apply(cos) + rand(r, 200)
    scatter(x, y)
    save("./tests/imgs/scatter_plot/scatterPlot_1.svg", "svg")
    clear()
}
public func testScatterPlot2() {
    print("    - testScatterPlot2\n")
    var r : Random = Random(1)
    let x = linspace<Float64>(0.0, 3.0 * Float64.PI, num: 200)
    let y = x.apply(cos) + rand(r, 200)
    let c = linspace<Float64>(1.0, 10.0, num: 200)
    scatter(x, y, c)
    save("./tests/imgs/scatter_plot/scatterPlot_2.svg", "svg")
    clear()
}
public func testScatterPlot3() {
    print("    - testScatterPlot3\n")
    var r : Random = Random(1)
    let x = linspace<Float64>(0.0, 3.0 * Float64.PI, num: 200)
    let y = x.apply(cos) + rand(r, 200)
    let c = linspace<Float64>(1.0, 10.0, num: 200)
    scatter(x, y, 6.0, c)
    save("./tests/imgs/scatter_plot/scatterPlot_3.svg", "svg")
    clear()
}
public func testScatterPlot4() {
    print("    - testScatterPlot4\n")
    var r : Random = Random(1)
    let x = linspace<Float64>(0.0, 3.0 * Float64.PI, num: 200)
    let y = x.apply(cos) + rand(r, 200)
    let c = linspace<Float64>(1.0, 10.0, num: 200)
    let line = scatter(x, y, 6.0, c)
    line.marker_face(true)
    save("./tests/imgs/scatter_plot/scatterPlot_4.svg", "svg")
    clear()
}
public func testScatterPlot5() {
    print("    - testScatterPlot5\n")
    var r : Random = Random(1)
    let theta = linspace<Float64>(0.0, 2.0 * Float64.PI, num: 150)
    let x = theta.apply(sin) + rand(r, 150) * 0.75
    let y = theta.apply(cos) + rand(r, 150) * 0.75
    let line = scatter(x, y, 23.0)
    line.marker(MarkerStyle.Diamond)
    save("./tests/imgs/scatter_plot/scatterPlot_5.svg", "svg")
    clear()
}
public func testScatterPlot6() {
    print("    - testScatterPlot6\n")
    var r : Random = Random(1)
    let theta = linspace<Float64>(0.0, 2.0 * Float64.PI, num: 150)
    let x = theta.apply(sin) + rand(r, 150) * 0.75
    let y = theta.apply(cos) + rand(r, 150) * 0.75
    let line = scatter(x, y, 6.0)
    line.marker_color(0.0, 0.5, 0.5)
    line.marker_face_color(0.0, 0.7, 0.7)
    save("./tests/imgs/scatter_plot/scatterPlot_6.svg", "svg")
    clear()
}
public func testScatterPlot7() {
    print("    - testScatterPlot7\n")
    var r : Random = Random(1)
    let x = linspace<Float64>(0.0, 3.0 * Float64.PI, num: 200)
    let y = x.apply(cos) + rand(r, 200)
    tiledlayout(2, 1)
    let ax1 = nexttile()
    scatter(ax1, x, y)
    let ax2 = nexttile()
    let line2 = scatter(ax2, x, y)
    line2.marker_face(true)
    line2.marker(MarkerStyle.Diamond)
    save("./tests/imgs/scatter_plot/scatterPlot_7.svg", "svg")
    clear()
}
public func testScatterPlot8() {
    print("    - testScatterPlot8\n")
    let theta = linspace<Float64>(0.0, 1.0, num: 500)
    let x = theta.apply({x: Float64 => exp(x) * sin(100.0 * x)})
    let y = theta.apply({x: Float64 => exp(x) * cos(100.0 * x)})
    let s = scatter(x, y)
    s.marker_color("b")
    s.marker_face_color(0.0, 0.5, 0.5)
    save("./tests/imgs/scatter_plot/scatterPlot_8.svg", "svg")
    clear()
}
public func testScatterPlot() {
    print("  + testScatterPlot\n")
    testScatterPlot1()
    testScatterPlot2()
    testScatterPlot3()
    testScatterPlot4()
    testScatterPlot5()
    testScatterPlot6()
    testScatterPlot7()
    testScatterPlot8()
}