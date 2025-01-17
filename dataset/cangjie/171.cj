// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from std import fs.*
from std import sync.*
from gifdrawable4cj import sparkmd5.*
main (){
    var sum: Int64 = tesSparkMD5_01()
    if (sum != 0) {
        println(sum)
        return sum
    }
    sum = tesSparkMD5_02()
    if (sum != 0) {
        println(sum)
        return sum
    }
    sum = tesSparkMD5_03()
    if (sum != 0) {
        println(sum)
        return sum
    }
    return 0
}
func tesSparkMD5_01(): Int64 {
    let sparkMD5: SparkMD5 = SparkMD5()
    sparkMD5.buff = "123456789"
    let str: String = sparkMD5.buff
    println(str)
    println(sparkMD5.length)
    if (str == "123456789") {
        return 0
    }
    return 1
}
func tesSparkMD5_02(): Int64 {
    let sparkMD5: SparkMD5 = SparkMD5()
    sparkMD5.buff = "20231121:123456789"
    sparkMD5.length = 18
    let str: String = sparkMD5.buff
    println(str)
    println(sparkMD5.length)
    if (str == "20231121:123456789" && sparkMD5.length == 18) {
        return 0
    }
    return 2
}
func tesSparkMD5_03(): Int64 {
    let sparkMD5: SparkMD5 = SparkMD5()
    sparkMD5.buff = "20231121:123456789"
    sparkMD5.length = 18
    sparkMD5.hash = Array<Int32>()
    let str: String = sparkMD5.buff
    println(sparkMD5.length)
    println(sparkMD5.hash)
    if (str == "20231121:123456789" && sparkMD5.length == 18 && sparkMD5.hash.size == 0) {
        return 0
    }
    return 3
}