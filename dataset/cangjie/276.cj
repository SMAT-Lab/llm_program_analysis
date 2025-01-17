package utils
from std import math.*
from std import random.*
public type Vector = Array<Float64>
public type Matrix = Array<Array<Float64>>
public type Matrices = Array<Array<Array<Float64>>>
public var random = Random()
// 获取矩阵的形状
public func shape(m : Matrix) : (Int64, Int64){
    let row_size = m.size
    let col_size = m[0].size
    (row_size, col_size)
}
// 获取矩阵的形状
public func shapeString(m : Matrix) : String{
    let row_size = m.size
    let col_size = m[0].size
    "row : ${row_size}, col : ${col_size}"
}
// 生成元素值符合正态分布的矩阵
public func randomMatrix(xsize : Int64, ysize : Int64) : Matrix {
    Matrix(xsize, { i =>
        Vector(ysize, {j =>
             random.nextGaussianFloat64()
        })
    })
}
// 生成元素相同的矩阵
public func constantMatrix(xsize : Int64, ysize : Int64, value : Float64) : Matrix {
    Matrix(xsize, { i =>
        Vector(ysize, {j =>
             value
        })
    })
}
// 矩阵的转置
public func transpose(m : Matrix) : Matrix {
    let matrix_shape = shape(m)
    let xsize = matrix_shape[0]
    let ysize = matrix_shape[1]
    Matrix(ysize, { i =>
        Vector(xsize, {j =>
            m[j][i]
        })
    })
}
// 数量积
public func multiply(a : Matrix, b : Matrix) : Matrix {
    let matrix_shape_a = shape(a)
    let matrix_shape_b = shape(b)
    if (matrix_shape_a != matrix_shape_b) {
        throw Exception("Matrix multiply : The shape of matrices is not match!")
    }
    let xsize = matrix_shape_a[0]
    let ysize = matrix_shape_a[1]
    Matrix(xsize, { i =>
        Vector(ysize, {j =>
             a[i][j] * b[i][j]
        })
    })
}
// 数量积
public func multiply(m : Matrix, value : Float64) : Matrix {
    let matrix_shape = shape(m)
    let xsize = matrix_shape[0]
    let ysize = matrix_shape[1]
    Matrix(xsize, { i =>
        Vector(ysize, {j =>
             m[i][j] * value
        })
    })
}
// 矩阵点乘
public func dot(a : Matrix, b : Matrix) : Matrix {
    let matrix_shape_a = shape(a)
    let matrix_shape_b = shape(b)
    if (matrix_shape_a[1] != matrix_shape_b[0]) {
        throw Exception("Matrix dot : The shape of matrices is not match!" + shapeString(a) + "," + shapeString(b))
    }
    let xsize = matrix_shape_a[0]
    let ysize = matrix_shape_b[1]
    Matrix(xsize, { i =>
        Vector(ysize, {j =>
            var value = .0
            for (k in 0..matrix_shape_a[1]) {
                value += (a[i][k] * b[k][j])
            }
            value
        })
    })
}
// 矩阵加和
public func add(a : Matrix, b : Matrix) : Matrix {
    let matrix_shape_a = shape(a)
    let matrix_shape_b = shape(b)
    if (matrix_shape_a != matrix_shape_b) {
        throw Exception("Matrix add : The shape of matrices is not match!")
    }
    let xsize = matrix_shape_a[0]
    let ysize = matrix_shape_a[1]
    Matrix(xsize, { i =>
        Vector(ysize, {j =>
             a[i][j] + b[i][j]
        })
    })
}
// 矩阵相减
public func subtract(a : Matrix, b : Matrix) : Matrix {
    let matrix_shape_a = shape(a)
    let matrix_shape_b = shape(b)
    if (matrix_shape_a != matrix_shape_b) {
        throw Exception("Matrix subtract : The shape of matrices is not match!")
    }
    let xsize = matrix_shape_a[0]
    let ysize = matrix_shape_a[1]
    Matrix(xsize, { i =>
        Vector(ysize, {j =>
             a[i][j] - b[i][j]
        })
    })
}
// Matrices加和
public func add(a : Matrices, b : Matrices) : Matrices {
    if (a.size != b.size) {
        throw Exception("Matrices add : The shape of matrices is not match!")
    }
    Matrices(a.size, { i =>
        add(a[i], b[i])
    })
}
// sigmoid函数
public func sigmoid(v : Vector) : Vector{
    Vector(v.size, {i =>
        sigmoid(v[i])
    })
}
// sigmoid函数
public func sigmoid(m : Matrix) : Matrix{
    let matrix_shape = shape(m)
    let xsize = matrix_shape[0]
    let ysize = matrix_shape[1]
    Matrix(xsize, { i =>
        Vector(ysize, {j =>
            sigmoid(m[i][j])
        })
    })
}
// sigmoid函数的导数
public func sigmoid_prime(v : Vector) : Vector {
    Vector(v.size, {i =>
        sigmoid_prime(v[i])
    })
}
// sigmoid函数的导数
public func sigmoid_prime(m : Matrix) : Matrix {
    let matrix_shape = shape(m)
    let xsize = matrix_shape[0]
    let ysize = matrix_shape[1]
    Matrix(xsize, { i =>
        Vector(ysize, {j =>
            sigmoid_prime(m[i][j])
        })
    })
}
// 随机下标列表
public func randomIndexes(size : Int64) : Array<Int64> {
    let arr = ArrayList<Int64>(size, {i => i})
    let indexes = Array<Int64>(size, {i =>
        let index = abs(random.nextInt64(arr.size))
        let value = arr[index]
        arr.remove(index)
        value
    })
    indexes
}
// 元素随机排列
public func shuffle(m : Vector) : Vector{
    let size = m.size
    let indexes = randomIndexes(size)
    Vector(size, {i =>
        let index = indexes[i]
        m[index]
    })
}