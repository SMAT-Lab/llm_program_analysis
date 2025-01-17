package test
// main declaration
class Simple {
    let str = ""
    var x: Int64
    public Simple(x: Int64) {
        this.x = x
    }
    public init(a: String) {
        this.x = 1
    }
    public static func buildDefault() {
        Simple(0)
    }
}
open class Base {}
class Child <: Base {}
class WithGeneric<T> {}
class WithThis {
    public func returnThis(): This {
        this
    }
}
struct SimpleStruct {
    public func funcInStrcut(): Unit {}
}
enum SimpleEnum {
    | EnumA
    | EnumB
}
interface SimpleInterface {}