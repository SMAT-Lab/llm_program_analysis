from std import random.*
from std import math.*
from std import sort.*
public class FCM {
    private let cluster_num: Int64
    private let cluster_centers: Array<Array<Float64>>
    private let cluster_dim:Int64
    private var max_iter: Int64 = 1000
    private var m: Float64 = 2.0
    private let samples:Array<Array<Float64>>
    private let sample_num:Int64
    private let sample_dim:Int64
    private let name:String
    private let U:Array<Array<Float64>>
    private func euclidean(A: Array<Float64>, B: Array<Float64>) {
        var temp_res = array_sub(A, B)
        var sum_dist: Float64 = 0.0
        for (i in temp_res) {
            sum_dist = sum_dist + (i ** 2)
        }
        var dist: Float64 = sqrt(sum_dist)
        return dist
    }
    private func array_sub(A: Array<Float64>, B: Array<Float64>) {
        let sum_index: Int64 = A.size
        var temp_array = Array<Float64>(sum_index, item: 0.0)
        let indexs = 0..=(sum_index - 1)
        for (i in indexs) {
            temp_array[i] = A[i] - B[i]
        }
        return temp_array
    }
    private func array_sum(A: Array<Float64>, B: Array<Float64>) {
        let item_num: Int64 = A.size
        var temp_array = Array<Float64>(item_num, item: 0.0)
        let indexs = 0..=(item_num - 1)
        for (i in indexs) {
            temp_array[i] = A[i] + B[i]
        }
        return temp_array
    }
    private func array_mul(A: Array<Float64>, B: Array<Float64>) {
        let item_num: Int64 = A.size
        var temp_array = Array<Float64>(item_num, item: 0.0)
        for (i in 0..item_num) {
            temp_array[i] = A[i] * B[i]
        }
        return temp_array
    }
    private func array_multiplier(A: Array<Float64>, num: Float64) {
        let item_num: Int64 = A.size
        var temp_array = Array<Float64>(item_num, item: 0.0)
        for (i in 0..item_num) {
            temp_array[i] = A[i] ** num
        }
        return temp_array
    }
    private func array_mul_num(A: Array<Float64>, num: Float64) {
        let item_num: Int64 = A.size
        var temp_array = Array<Float64>(item_num, item: 0.0)
        for (i in 0..item_num) {
            temp_array[i] = A[i] * num
        }
        return temp_array
    }
    private func array_div_num(A: Array<Float64>, num: Float64) {
        let item_num: Int64 = A.size
        var temp_array = Array<Float64>(item_num, item: 0.0)
        for (i in 0..item_num) {
            temp_array[i] = A[i] / num
        }
        return temp_array
    }
    private func sum(y: Array<Float64>) {
        var s = 0.0
        for (j in y) {
            s += j
        }
        return s
    }
    private func sqrt(X: Float64) {
        if (X < 0.0) {
            return -1.0
        } else {
            return X ** 0.5
        }
    }
    private func copy_1D_arry(a: Array<Float64>) {
        var temp = Array<Float64>(a.size, item: 0.0)
        for (i in 0..a.size) {
            temp[i] = a[i]
        }
        return temp
    }
    private func argmax(a: Array<Float64>) {
        var max:Float64 = a[0]
        var idx:Int64 = 0
        for (i in 0..a.size){
            if(max < a[i]) {
                max = a[i]
                idx = i
            }
        }
        return (max,idx)
    }
    private func init_U(sample_num: Int64, cluster_num: Int64) {
        let rnd: Random = Random()
        for (i in 0..sample_num) {
            for (j in 0..cluster_num) {
                this.U[i][j] = rnd.nextFloat64()
            }
            var temp_sum = sum(this.U[i])
            for (j in 0..cluster_num) {
                this.U[i][j] = this.U[i][j] / temp_sum
            }
        }
        // println("U:${U[0..10].toString()}")
    }
    func init_centers() {
        for (i in 0..this.cluster_num) {
            this.cluster_centers[i] = this.samples[i]
        }
        println("init cluster_centers:${cluster_centers.toString()}")
    }
    init(name:String, cluster_num:Int64, samples: Array<Array<Float64>>,  m:Float64, max_iter: Int64) {
        this.name = name
        this.samples = samples
        this.cluster_num = cluster_num
        this.m = m
        this.max_iter = max_iter
        this.sample_num = samples.size
        this.sample_dim = samples[0].size
        this.cluster_dim = samples[0].size
        this.U = Array<Array<Float64>>(sample_num,{i=>Array<Float64>(cluster_num, item:0.0)})
        this.cluster_centers = Array<Array<Float64>>(cluster_num, {i=>Array<Float64>(samples[0].size, item:0.0)})
        init_U(sample_num, cluster_num)
        init_centers()
        println("name       :${this.name}")
        println("cluster_num:${this.cluster_num}")
        println("cluster_dim:${this.cluster_dim}")
        println("sample_num :${this.cluster_num}")
        println("sample_dim :${this.sample_dim}")
    }
    private func compute_U() {
        for (i in 0..this.sample_num) {
            var dist = Array<Float64>(this.sample_num, item: 0.0)
            for (j in 0..this.cluster_num) {
                dist[j] = euclidean(this.samples[i], this.cluster_centers[j])
                if (dist[j] == 0.0) {
                    dist[j] = 1e-05
                }
            }
            var denominator = 0.0
            for (j in 0..this.cluster_num) {
                var temp_sum = 0.0
                for (k in 0..this.cluster_num) {
                    temp_sum = temp_sum + (dist[j] / dist[k]) ** (2.0 / (this.m - 1.0))
                }
                denominator = temp_sum
                this.U[i][j] = 1.0 / denominator
            }
        }
        return this.U
    }
    private func compute_centers() {
        let data_dim = this.samples[0].size
        let data_num = this.samples.size
        var sum_U = Array<Float64>(this.cluster_num, item: 0.0)
        for (i in 0..data_num) {
            sum_U = array_sum(sum_U, array_multiplier(this.U[i], m))
        }
        var center_temp = Array<Float64>(data_dim, item: 0.0)
        for (j in 0..cluster_num){
            var sum_numerator = Array<Float64>(data_dim, item: 0.0)
            for (i in 0..data_num){
                sum_numerator = array_sum(sum_numerator, array_mul_num(this.samples[i], U[i][j] ** m))
            }
            center_temp = array_div_num(sum_numerator, sum_U[j])
            this.cluster_centers[j] = center_temp
        }
        return this.cluster_centers
    }
    public func cluster() {
        let num_of_data = this.samples.size
        let num_of_dim = this.samples[0].size
        var m: Float64 = 2.0
        if (num_of_dim < 5) {
            m = 2.0
        } else {
            m = Float64(min(num_of_data, (num_of_dim - 1)) / (min(num_of_data, (num_of_dim - 1)) - 2))
        }
        for (i in 0..max_iter) {
            compute_centers()
            compute_U()
        }
        return this.cluster_centers
    }
    public func defuzzify() {
        let num_of_data = this.sample_num
        let num_of_cluster = this.cluster_num
        var label = Array<Int64>(num_of_data, item: 0)
        var sample_with_label = Array<(Float64, Float64, Int64)>(num_of_data, {i=>(0.0,0.0,0)})
        for (i in 0..num_of_data) {
            let data = argmax(this.U[i])
            let value = data[0]
            let label = data[1]
            sample_with_label[i] = (this.samples[i][0], this.samples[i][1], label)
        }
        return sample_with_label
    }
}
public func getData(start: Int64, end:Int64){
    let gap:UInt64 = UInt64(end - start)
    let rnd: Random = Random()
    var x = rnd.nextUInt64()
    if (x > gap) {
        x = x % gap
    }
    x = x + UInt64(start)
    return Float64(x)
}
public func prepareData(){
    var data: Array<Array<Float64>> = Array<Array<Float64>>(300, item:Array<Float64>(2, item:0.0))
    for (i in 0..100){
        let x = getData(20,40)
        let y = getData(20,40)
        data[i]= [x,y]
    }
    for (i in 100..200) {
        let x = getData(80,100)
        let y = getData(80,100)
        data[i]= [x,y]
    }
    for (i in 200..300) {
        let x = getData(120,160)
        let y = getData(30,60)
        data[i]= [x,y]
    }
    return data
}
main(){
    println("prepare sample data...")
    var data:Array<Array<Float64>> = prepareData()
    println("FCM clustering...")
    var fcm:FCM = FCM("RGB", 3, data, 2.0, 1000)
    var centers = fcm.cluster()
    println("final centers:${centers}")
    var sample_with_label = fcm.defuzzify()
    for(i in 0..sample_with_label[0..10].size){
        println("sample:[${sample_with_label[i][0]} , ${sample_with_label[i][1]}], label:${sample_with_label[i][2]}")
    }
}