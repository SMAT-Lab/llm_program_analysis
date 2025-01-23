package cjorm.builder
public struct IsNull <: Cond {
    let data: String
    public init(data: String) {
        this.data = data
    }
    public func writeTo(w: CondWriter): Unit {
        w.write("${this.data} IS NULL")
    }
    public func and(condition: Cond): Cond {
        buildAnd([this, condition])
    }
    public func or(condition: Cond): Cond {
        buildOr([this, condition])
    }
    public func isValid(): Bool {
        this.data.size > 0
    }
}
public struct NotNull <: Cond {
    let data: String
    public init(data: String) {
        this.data = data
    }
    public func writeTo(w: CondWriter): Unit {
        w.write("${this.data} IS NOT NULL")
    }
    public func and(condition: Cond): Cond {
        buildAnd([this, condition])
    }
    public func or(condition: Cond): Cond {
        buildOr([this, condition])
    }
    public func isValid(): Bool {
        this.data.size > 0
    }
}