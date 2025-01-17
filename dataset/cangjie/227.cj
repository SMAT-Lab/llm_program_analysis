package quartz.org.quartz.utils
import std.collection.*
public open class DirtyFlagMap<K,V> <: Map<K, V> where K <: Hashable & Equatable<K>  {
    private var dirty : Bool
    private var map : HashMap<K,V>
    public init() {
        this.dirty = false
        this.map = HashMap<K,V>()
    }
    public init(initialCapacity: Int64) {
        this.dirty = false
        this.map = HashMap<K,V>(initialCapacity)
    }
    public func get(key: K): ?V {
        return map.get(key)
    }
    public func contains(key: K): Bool {
        return map.contains(key)
    }
    public func containsAll(keys: Collection<K>): Bool {
        return map.containsAll(keys)
    }
    public func put(key: K, value: V): ?V {
        this.dirty = true
        return map.put(key,value)
    }
    // public func putIfAbsent(key: K, value: V): EntryView<K, V> {
    //     this.dirty = !contains(key)
    //     return map.putIfAbsent(key,value)
    // }
    public func putAll(elements: Collection<(K, V)>): Unit {
        if (!elements.isEmpty()) {
            dirty = true;
        }
        map.putAll(elements)
    }
    public func remove(key: K): ?V {
        let old = map.remove(key)
        if( old.isPresent() ) {
            dirty = true
        }
        return old
    }
    public func removeAll(keys: Collection<K>): Unit {
        for( k in keys ) {
            let old = remove(k)
            if( old.isPresent() ) {
                dirty = true
            }
        }
    }
    public func removeIf(predicate: (K, V) -> Bool): Unit {
        let set = HashSet<K>()
        for( (k,v) in map ) {
            if( predicate(k,v) ) {
                dirty = true
                set.put(k)
            }
        }
        map.removeAll(set)
    }
    public func clear(): Unit {
        if (!map.isEmpty()) {
            dirty = true;
        }
        map.clear()
    }
    // public func version(): Int64 {
    //     return map.version()
    // }
    // public func reserve(additional: Int64): Unit {
    //     map.reserve(additional)
    // }
    // public func capacity(): Int64 {
    //     return map.capacity()
    // }
    public func keys(): EquatableCollection<K> {
        return DirtyFlagMapKeys(map.keys())
    }
    public func values(): Collection<V> {
        throw Exception("values is not supported")
    }
    public func iterator(): Iterator<(K, V)> {
        return DirtyFlagHashMapIterator(map.iterator())
    }
    public prop size: Int64 {
        get() {
            return map.size
        }
    }
    public func isEmpty(): Bool {
        return map.isEmpty()
    }
    public operator func [](key: K, value!: V): Unit {
        this.dirty = true
        map[key] = value
    }
    public operator func [](key: K): V {
        return map[key]
    }
    public func clearDirtyFlag() :Unit {
        this.dirty = false;
    }
    public func isDirty() :Bool {
        return dirty;
    }
    public func getWrappedMap() : Map<K,V> {
        return map;
    }
    public func containsKey(key: K) : Bool {
        return map.contains(key);
    }
    public func containsValue<T>(val : T) : Bool where T <: Equatable<T> {
        for(v in map.values() ) {
            let vv = v as T
            if( !vv.isPresent() ) {
                continue;
            }
            if( vv == val) {
                return true
            }
        }
        return false
    }
    public func clone(): HashMap<K,V> {
        return map.clone()
    }
}
class DirtyFlagMapKeys<T> <: EquatableCollection<T>  where T <: Equatable<T>   {
    public DirtyFlagMapKeys(private let keys: EquatableCollection<T>) {
    }
    public func iterator(): Iterator<T> {
        return keys.iterator()
    }
    public prop size: Int64 {
        get() {
            return keys.size
        }
    }
    public func isEmpty(): Bool {
        return keys.isEmpty()
    }
    public func contains(element: T): Bool {
        return keys.contains(element)
    }
    public func containsAll(elements: Collection<T>) : Bool {
        return keys.containsAll(elements)
    }
    public func remove(element: T): Bool {
         throw Exception("remove is not supported")
    }
    public func removeAll(elements: Collection<T>): Unit {
         throw Exception("removeAll is not supported")
    }
    public func removeIf(predicate: (T) -> Bool): Unit {
        throw Exception("removeIf is not supported")
    }
    public func clear(): Unit {
        throw Exception("clear is not supported")
    }
}
class DirtyFlagHashMapIterator<K,V> <: Iterator<(K,V)> where K <: Hashable & Equatable<K> {
    public DirtyFlagHashMapIterator(private let hmi: HashMapIterator<K, V>) {
    }
    // public func iterator(): Iterator<(K,V)> {
    //     return hmi.iterator()
    // }
    public func next(): Option<(K,V)> {
        return hmi.next()
    }
}