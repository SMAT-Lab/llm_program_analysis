package collection
from std import collection.{EquatableCollection, HashMapIterator}
public interface Arr<T> where T<:Comparable<T> {
    operator func [](index: Int64): T
    operator func [](index: Int64, value!: T): Unit
    func count(item: T): Int64
    func index(item: T): Int64
    func reverse(): Unit
    // func sort(key!: ?(T)->Comparable<Any>, reverse!: Bool, stable!: Bool): Unit
    // func clone(): Arr<T>
}
public interface List<T> <: Arr<T> where T <: Comparable<T>{
    func append(item: T): Unit
    func extend2(items: Collection<T>): Unit
    func insert(index: Int64, item: T): Unit
    func pop(index!: Int64): T
    func delete(item: T): Unit
    func clear(): Unit
}
public interface Dict<K, V> where K<:Equatable<K> & Hashable {
    func clear(): Unit
    func copy(): Dict<K, V>
    static func fromkeys<R>(seq:Array<K>, value!: ?R): Dict<K, ?R> where R<:V
    func getV(key:K, default!:?V): ?V
    func items(): HashMapIterator<K, V>
    func keys(): EquatableCollection<K>
    func values(): Collection<V>
    func setdefault(key: K, default: V): V
    func update(dict: HashMap<K, V>): Unit
    func pop(key: K, default!: ?V): ?V
    func popitem(): (K, V)
}