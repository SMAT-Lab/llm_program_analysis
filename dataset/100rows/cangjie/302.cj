package memorycache
import encoding.json.JsonObject
import std.sync.AtomicInt64
import std.collection.concurrent.ConcurrentHashMap
import std.collection.concurrent.BlockingQueue
public class FifoCache <: Cache {
    private var cache: ConcurrentHashMap<String, String>
    private var capacity: Int64
    private var fn: AtomicInt64
    private var trackingQueue: BlockingQueue<String>
    public init(capacity: Int64) {
        if (capacity < 1) {
            throw MemoryCacheException("capacity must be greater than 0")
        }
        this.capacity = capacity
        this.cache = ConcurrentHashMap<String, String>()
        this.fn = AtomicInt64(0)
        this.trackingQueue = BlockingQueue<String>()
    }
    public func contains(key: String): Bool {
        return cache.contains(key)
    }
    public func getCapacity(): Int64 {
        return capacity
    }
    public func setCapacity(capacity: Int64) {
        if (capacity < 1) {
            throw MemoryCacheException("capacity must be greater than 0")
        }
        this.capacity = capacity
        while (fn.load() > capacity) {
            var key = trackingQueue.dequeue()
            cache.remove(key)
            fn.fetchSub(1)
        }
    }
    public func clear(): Unit {
        cache = ConcurrentHashMap<String, String>()
        trackingQueue = BlockingQueue<String>()
    }
    public func get(key: String): Option<String> {
        return cache.get(key)
    }
    public func put(key: String, value: String) {
        match (cache.putIfAbsent(key, value)) {
            case None => if (fn.fetchAdd(1) >= capacity) {
                cache.remove(trackingQueue.dequeue())
                trackingQueue.enqueue(key)
            } else {
                trackingQueue.enqueue(key)
            }
            case Some(_) => ()
        }
    }
    public func remove(): Option<String> {
        if (fn.load() == 0) {
            return None
        }
        var res = cache.remove(trackingQueue.dequeue())
        if (res.isSome()) {
            fn.fetchSub(1)
        }
        return res
    }
}