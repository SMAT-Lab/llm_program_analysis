package persistent.collections.hash_tree
import persistent.collections.interfaces.PersistentMap
import persistent.collections.impl.*
import std.collection.ArrayList
public class PersistentHashMap<K, V> <: PersistentMap<K, V> & PrettyPrintable {
    private PersistentHashMap(
        private let root: ?HashTreeElement<(K, V)>,
        private let size_: Int64,
        private let hasher: (K) -> Int64,
        private let eq: (K, K) -> Bool
    ) {}
    init(hasher: (K) -> Int64, eq: (K, K) -> Bool) {
        this.root = None
        this.size_ = 0
        this.hasher = hasher
        this.eq = eq
    }
    private func keyEq(entry: (K, V), key: K) { eq(entry[0], key) }
    private func entryEq(lentry: (K, V), rentry: (K, V)) { eq(lentry[0], rentry[0]) }
    private func entryHasher(entry: (K, V)) { hasher(entry[0]) }
    func keyHashCode(key: K): Int64 { hasher(key) }
    func copy(
        root !: ?HashTreeElement<(K, V)> = this.root,
        size !: Int64 = this.size_,
        hasher !: (K) -> Int64 = this.hasher,
        eq !: (K, K) -> Bool = this.eq
    ) {
        PersistentHashMap(root, size, hasher, eq)
    }
    public override prop size: Int64 {
        get() { size_ }
    }
    public override func iterator() { HashTreeIterator(root) }
    public override func clear(): PersistentHashMap<K, V> { copy(root: None, size: 0) }
    public override func put(key: K, value: V): PersistentHashMap<K, V> {
        if (let Some(root) <- root) {
            let sizeRef = Box(size_)
            let result = root.insert((key, value), entryHasher, entryEq, sizeRef, overwrite: true)
            copy(root: result, size: sizeRef.value)
        } else {
            copy(root: Leaf<(K, V)>((key, value)), size: 1)
        }
    }
    public override func putAll(elements: Iterable<(K, V)>): PersistentHashMap<K, V> {
        var self = this
        for (e in elements) {
            self = self.put(e[0], e[1])
        }
        return self
    }
    public override func removeKey(key: K): PersistentHashMap<K, V> {
        if (let Some(root) <- root) {
            let sizeRef = Box(size_)
            let result = root.remove<K>(key, entryHasher, keyEq, sizeRef, hash: hasher(key))
            copy(root: result, size: sizeRef.value)
        } else {
            clear()
        }
    }
    public override func containsKey(key: K): Bool {
        root?.contains<K>(key, entryHasher, keyEq, hash: hasher(key)) ?? false
    }
    public override func get(key: K): ?V {
        let entry = root?.get<K>(key, entryHasher, keyEq, hash: hasher(key)) ?? None
        entry?[1]
    }
    func dumpDot() {
        let collectible = ArrayList<String>()
        collectible.append("digraph HAMT {")
        collectible.append("nodesep=0.8;")
        collectible.append("ranksep=4.0;")
        root?.dumpDot("root", collectible)
        collectible.append("}")
        joinToString(collectible, prefix: "", suffix: "", separator: "\n\n")
    }
    public func pprintTo(indent: String, sb: StringBuilder): Unit {
        dumpValue(root, indent: indent, to: sb)
    }
}
extend <K, V> PersistentHashMap<K, V> where K <: Equatable<K> & Hashable {
    public static func create(): PersistentHashMap<K, V> {
        PersistentHashMap<K, V>({ k => k.hashCode() }, { a, b => a == b })
    }
    public static func of(array: Array<(K, V)>): PersistentHashMap<K, V> {
        create().putAll(array)
    }
}
extend <K, V> PersistentHashMap<K, V> <: Hashable where V <: Hashable {
    public func hashCode() {
        var hasher = DefaultHasher(res: 0)
        for ((k, v) in this) {
            hasher.write(keyHashCode(k))
            hasher.write(v.hashCode())
        }
        hasher.finish()
    }
}
extend <K, V> PersistentHashMap<K, V> <: ToString where K <: ToString, V <: ToString {
    public func toString() {
        let sb = StringBuilder("{")
        let it = iterator()
        if (let Some(kv) <- it.next()) {
            let (k, v) = kv
            sb.append(k.toString())
            sb.append(": ")
            sb.append(v.toString())
        }
        for ((k, v) in it) {
            sb.append(", ")
            sb.append(k.toString())
            sb.append(": ")
            sb.append(v.toString())
        }
        sb.append("}")
        sb.toString()
    }
}
extend <K, V> PersistentHashMap<K, V> <: Equatable<PersistentMap<K, V>> where V <: Equatable<V> {
    public func containsEntry(entry: (K, V)) {
        this.get(entry[0]) == Option.Some(entry[1])
    }
    public func containsAllEntries(iterable: Iterable<(K, V)>) {
        for (kv in iterable) {
            if (!containsEntry(kv)) {
                return false
            }
        }
        return true
    }
    public operator func ==(that: PersistentMap<K, V>) {
        size == that.size && containsAllEntries(that)
    }
    public operator func !=(that: PersistentMap<K, V>) {
        !(this == that)
    }
}
extend <K, V> PersistentHashMap<K, V> <: Equatable<PersistentHashMap<K, V>> where V <: Equatable<V> {
    public operator func ==(that: PersistentHashMap<K, V>) {
        size == that.size && containsAllEntries(that)
    }
    public operator func !=(that: PersistentHashMap<K, V>) {
        !(this == that)
    }
}