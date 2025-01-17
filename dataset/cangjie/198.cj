package cbor4cj
public class MapBuilder<T> <: AbstractBuilder<T> {
    private let map: CborMap
    public init(parent: T, map: CborMap) {
        super(parent)
        this.map = map
    }
    public func put(key: DataItem, value: DataItem): MapBuilder<T> {
        map.put(key, value)
        return this
    }
    public func put(key: Int64, value: Int64): MapBuilder<T> {
        put(convert(key), convert(value))
        return this
    }
    public func put(key: Int64, value: Bool): MapBuilder<T> {
        put(convert(key), convert(value))
        return this
    }
    public func put(key: Int64, value: Float32): MapBuilder<T> {
        put(convert(key), convert(value))
        return this
    }
    public func put(key: Int64, value: Float64): MapBuilder<T> {
        put(convert(key), convert(value))
        return this
    }
    public func put(key: Int64, value: Array<UInt8>): MapBuilder<T> {
        put(convert(key), convert(value))
        return this
    }
    public func put(key: Int64, value: String): MapBuilder<T> {
        put(convert(key), convert(value))
        return this
    }
    public func put(key: String, value: Int64): MapBuilder<T> {
        put(convert(key), convert(value))
        return this
    }
    public func put(key: String, value: Bool): MapBuilder<T> {
        put(convert(key), convert(value))
        return this
    }
    public func put(key: String, value: Float32): MapBuilder<T> {
        put(convert(key), convert(value))
        return this
    }
    public func put(key: String, value: Float64): MapBuilder<T> {
        put(convert(key), convert(value))
        return this
    }
    public func put(key: String, value: Array<UInt8>): MapBuilder<T> {
        map.put(convert(key), convert(value))
        return this
    }
    public func put(key: String, value: String): MapBuilder<T> {
        put(convert(key), convert(value))
        return this
    }
    public func putArray(key: DataItem): ArrayBuilder<MapBuilder<T>> {
        let array = CborArray()
        put(key, array)
        return ArrayBuilder<MapBuilder<T>>(this, array)
    }
    public func putArray(key: Int64): ArrayBuilder<MapBuilder<T>> {
        let array = CborArray()
        put(convert(key), array)
        return ArrayBuilder<MapBuilder<T>>(this, array)
    }
    public func putArray(key: String): ArrayBuilder<MapBuilder<T>> {
        let array = CborArray()
        put(convert(key), array)
        return ArrayBuilder<MapBuilder<T>>(this, array)
    }
    public func startArray(key: DataItem): ArrayBuilder<MapBuilder<T>> {
        let array = CborArray()
        array.setChunked(true)
        put(key, array)
        return ArrayBuilder<MapBuilder<T>>(this, array)
    }
    public func startArray(key: Int64): ArrayBuilder<MapBuilder<T>> {
        return startArray(convert(key))
    }
    public func startArray(key: String): ArrayBuilder<MapBuilder<T>> {
        let array = CborArray()
        array.setChunked(true)
        put(convert(key), array)
        return ArrayBuilder<MapBuilder<T>>(this, array)
    }
    public func putMap(key: DataItem): MapBuilder<Object> {
        let nestedMap = CborMap()
        put(key, nestedMap)
        return MapBuilder<Object>(this, nestedMap)
    }
    public func putMap(key: Int64): MapBuilder<Object> {
        let nestedMap = CborMap()
        put(convert(key), nestedMap)
        return MapBuilder<Object>(this, nestedMap)
    }
    public func putMap(key: String): MapBuilder<Object> {
        let nestedMap = CborMap()
        put(convert(key), nestedMap)
        return MapBuilder<Object>(this, nestedMap)
    }
    public func startMap(key: DataItem): MapBuilder<Object> {
        let nestedMap = CborMap()
        nestedMap.setChunked(true)
        put(key, nestedMap)
        return MapBuilder<Object>(this, nestedMap)
    }
    public func startMap(key: Int64): MapBuilder<Object> {
        return startMap(convert(key))
    }
    public func startMap(key: String): MapBuilder<Object> {
        return startMap(convert(key))
    }
    public func end(): ?T {
        return getParent()
    }
}