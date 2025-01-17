// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from std import fs.*
from std import sync.*
from gifdrawable4cj import parser.*
main (){
    var sum: Int64 = createFile01()
    if (sum != 0) {
        println(sum)
        return sum
    }
    return 0
}
//测试[文件不存在]：writeNewFile(path: String, data: String | Array<Byte>)
func createFile01(): Int64 {
    let path: String = "testWriteNewFile_I8KRL5.json"
    let fileUtils: FileUtil = FileUtil.getInstance()
    fileUtils.writeNewFile(path, "123456789")
    var arr: Array<Byte> = fileUtils.readFile(path)
    var str: String = String.fromUtf8(arr)
    if (str != "123456789") {
        fileUtils.deleteFile(path)
        return 1
    }
    fileUtils.writeNewFile(path, "ceshi 20231201")
    arr = fileUtils.readFile(path)
    str = String.fromUtf8(arr)
    if (str != "ceshi 20231201") {
        fileUtils.deleteFile(path)
        return 2
    }
    fileUtils.deleteFile(path)
    return 0
}