//下例中，成员函数 g 中不能修改成员变量 i 的值
struct Foo {
    var i = 0
    public func g() {
        //i = 1 // 'i' cannot be modified in immutable function
    }
}
// Mut 函数与普通的实例成员函数相比，多一个 mut 关键字来修饰。
struct Foo1 {
    var i = 0
    public mut func g() {
        i = 1
    }
}
// mut 只能修饰实例成员函数，不能修饰静态成员函数。
struct A {
    public mut func f() {} // ok
    //public mut static func g() // error: 'static' and 'mut' modifiers conflict on function declaration
}
// Mut 函数中的 this 不能被捕获，也不能作为表达式。不能在 mut 函数中对 struct 的实例成员变量进行捕获。
struct Foo2 {
    var i = 0
    // public mut func f(): Foo2 {
    //     let f1 = { => this } // 'this' cannot be captured in the mutable function 'f'
    //     let f4 = { => i } // 'i' cannot be captured in the mutable function
    //     this // 'this' cannot be used as an expression in the mutable function
    // }
}
interface I {
    mut func f1(): Unit
    func f2(): Unit
}
struct A1 <: I {
    public mut func f1(): Unit {} // ok,as in the interface, the 'mut' modifier is used
    public func f2(): Unit {}
}
class C1 <: I {
    public func f1(): Unit {} // ok, not struct
    public func f2(): Unit {} // ok, not struct
}
interface I1 {
    mut func f(): Unit
}
struct Foo3 <: I1 {
    public var v = 0
    public mut func f(): Unit {
        v = 1
    }
}
// 为避免逃逸，非 mut 的实例成员函数（包括 lambda 表达式）不能直接访问所在类型的 mut 函数，反之可以
struct Foo4 {
    var i = 0
    public mut func f(): Unit {
        i = 1
        g() // ok
    }
    public func g(): Unit {
        //f() // error: immutable function 'g' cannot access mutable function 'f'
    }
}
interface I2 {
    mut func f(): Unit {
        g() // ok
    }
    func g(): Unit {
        //f() // error:immutable function 'g' cannot access mutable function 'f'
    }
}
main() {
    // 当 struct 的实例赋值给 interface 类型时是拷贝语义，
    // 因此 interface 的 mut 函数并不能修改 struct 实例的值。
    var a = Foo3()
    var b: I1 = a
    b.f()
    println(a.v)
    // 因为 struct 是值类型，所以如果一个变量是 struct 类型且使用 let 声明，
    // 那么不能通过这个变量访问该类型的 mut 函数
    let a1 = Foo3()
    //a1.f()
    let c: I1 = Foo3()
    c.f() // ok
    //为避免逃逸，如果一个变量的类型是 struct 类型，那么这个变量不能将该类型使
    //用 mut 修饰的函数作为一等公民来使用，只能调用这些 mut 函数
    var a2 = Foo3()
    //var fn = a2.f //mutable function 'f' cannot be used alone as reference
    var b2: I1 = Foo3()
    var fn = b2.f // ok
}