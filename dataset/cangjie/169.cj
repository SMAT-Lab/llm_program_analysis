//已知限制：无法拓展空间
public class Deque<T> {
    var arr: Array<Any> = Array<Any>(2000000, item: 0)
    //numbers of value
    public var size: Int64 = 0
    var head: Int64 = 1000001
    var tail: Int64 = 1000000
    public init() {
        size = 0
    }
    public init(max_size: Int64) {
        arr = Array<Any>(max_size * 2, item: 0)
        size = 0
    }
    public init(initArr: Array<T>) {
        size = initArr.size
        tail = size - 1
        for (i in 0..arr.size) {
            this.arr[i + 1000001] = initArr[i]
        }
    }
    public init(maxSize: Int64, initArr: Array<T>) {
        arr = Array<Any>(maxSize, item: 0)
        size = initArr.size
        tail += size
        for (i in 0..arr.size) {
            this.arr[i + 1000001] = initArr[i]
        }
    }
    public func pushBack(val: T) {
        this.tail++
        arr[tail] = val
        this.size++
    }
    public func popBack() {
        if (size == 0) {
            try {
                var exc: IndexOutOfBoundsException = IndexOutOfBoundsException("The queue is empty")
                throw (exc)
            } catch (exc: IndexOutOfBoundsException) {
                println("${exc}");
            }
        } else {
            this.arr[tail] = 0
            this.tail--
            this.size--
        }
    }
    public func pushFront(val: T) {
        if (this.head == 0) {
            try {
                throw IndexOutOfBoundsException("There are too many elements in the front end of the deque")
            } catch (exc: IndexOutOfBoundsException) {
                println("${exc}")
            }
        } else {
            this.head--
            this.arr[head] = val
            this.size++
        }
    }
    public func popFront()
    {
        if (size == 0) {
            try {
                var exc: IndexOutOfBoundsException = IndexOutOfBoundsException("The queue is empty")
                throw (exc)
            } catch (exc: IndexOutOfBoundsException) {
                println("${exc}");
            }
        } else {
            this.arr[head] = 0
            this.head++
            this.size--
        }
    }
    public func front() {
        return arr[head]
    }
    public func back() {
        return arr[tail]
    }
    public func empty(): Bool {
        return (this.size == 0)
    }
    public operator func [](i: Int64) {
        return arr[i+1000001]
    }
}