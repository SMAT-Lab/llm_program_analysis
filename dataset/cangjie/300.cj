external record SquareLoss {
    let reduce_: Bool
    let average_: Bool
    init(reduce: Bool, average: Bool)
    {
        reduce_ = reduce
        average_ = average
    }
    init(reduction!: String = "mean")
    {
        ASSERT(reduction.isIn(@{"mean", "sum", "none"}), "SquareLoss reduction method ${reduction} is not supported.")
        if (reduction == "sum") {
            average_ = false
        } else {
            average_ = true
        }
        if (reduction == "none") {
            reduce_ = false
        } else {
            reduce_ = true
        }
    }
}
extend SquareLoss <: CellBinary {
    @differentiable[stage: 2, except: [this, label]]
    operator func ()(data: Tensor, label: Tensor): Tensor
    {
        let diff = SquareOp(data - label)
        let inputDtype = stopGradient<Tensor>(data).GetDtype()
        // CastOp(data, 0)表示将data转换到Float32类型
        let dF32 = CastOp(diff, 0)
        let output0 = MulOp(1.0, dF32)
        let axis = cacuSquareLossAxis(stopGradient<Tensor>(data))
        let output1: Tensor = if (this.reduce_) {
            if (average_) {
                ReduceMeanOp(output0, axis)
            } else {
                ReduceSumOp(output0, axis)
            }
        } else {
            output0
        }
        let output2 = CastOp(output1, inputDtype)
        return output2
    }
}