package cbor4cj
public class ArrayBuilder<T> <: AbstractBuilder<T> {
    private let array: CborArray
    public init(parent: T, array: CborArray) {
        super(parent)
        this.array = array
    }
    public func add(dataItem: DataItem): ArrayBuilder<T> {
        array.add(dataItem)
        return this
    }
    public func add(value: Int64): ArrayBuilder<T> {
        add(convert(value))
        return this
    }
    public func add(value: Bool): ArrayBuilder<T> {
        add(convert(value))
        return this
    }
    public func add(value: Float32): ArrayBuilder<T> {
        add(convert(value))
        return this
    }
    public func add(value: Float64): ArrayBuilder<T> {
        add(convert(value))
        return this
    }
    public func add(bytes: Array<UInt8>): ArrayBuilder<T> {
        add(convert(bytes))
        return this
    }
    public func add(string: String): ArrayBuilder<T> {
        add(convert(string))
        return this
    }
    public func addArray(): ArrayBuilder<Object> {
        let nestedArray = CborArray()
        add(nestedArray)
        return ArrayBuilder<Object>(this, nestedArray)
    }
    public func startArray(): ArrayBuilder<Object> {
        let nestedArray = CborArray()
        nestedArray.setChunked(true)
        add(nestedArray)
        return ArrayBuilder<Object>(this, nestedArray)
    }
    public func addMap(): MapBuilder<Object> {
        let nestedMap = CborMap()
        add(nestedMap)
        return MapBuilder<Object>(this, nestedMap)
    }
    public func startMap(): MapBuilder<Object> {
        let nestedMap = CborMap()
        nestedMap.setChunked(true)
        add(nestedMap)
        return MapBuilder<Object>(this, nestedMap)
    }
    public func end(): ?T {
        if (array.isChunked()) {
            add(SimpleValue.BREAK)
        }
        return getParent()
    }
}