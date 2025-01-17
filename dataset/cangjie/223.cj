package util
public interface Resposibility<C, A, R> {
    //检查指定条件是否满足执行当前策略的要求
    func check(condition: C): Bool
    //执行当前策略
    func execute(arg: A): R
}
public interface ValidationResposibility<C, A> <: Resposibility<C, A, Unit> {
    func execute(arg: A): Unit {}
}
public class ResposibilityChain<C, A, R> {
    private let resposibilities = ArrayList<Resposibility<C, A, R>>()
    public init() {}
    public init(resposibilities: Iterable<Resposibility<C, A, R>>) {
        this.resposibilities.appendAll(resposibilities)
    }
    //注册一个策略
    public func register(resposibility: Resposibility<C, A, R>): ResposibilityChain<C, A, R> {
        resposibilities.append(resposibility)
        this
    }
    public func register<S>(resposibilities: Iterable<S>): Unit where S <: Resposibility<C, A, R> {
        this.resposibilities.appendAll(
            IterableConverter<S, Resposibility<C, A, R>>(resposibilities, throwIfNotMatch: true))
    }
    public func execute(condition: C, arg: A): R {
        for (r in resposibilities) {
            if (r.check(condition)) {
                return r.execute(arg)
            }
        }
        throw IllegalAccessException("there is no strategy to match current condition")
    }
    public func executeAll(condition: C, arg: A): Unit {
        for (r in resposibilities where r.check(condition)) {
            r.execute(arg)
        }
    }
}