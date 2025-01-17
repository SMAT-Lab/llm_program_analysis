package pool
from std import collection.ArrayList
from std import sync.{AtomicBool, AtomicInt64, Timer}
from std import time.{DateTime, Duration}
from std import os.process.Process
import base.ZERO_TIMER
import collection.SyncDeque
import concurrent.AtomicInteger
import log.LoggerFactory
import pool.exception.PoolException
public class Pool<T> <: Resource where T <: Object {
    private static let logger = LoggerFactory.getLogger("fountain/pool.Pool")
    private var checkTimer: Timer = ZERO_TIMER
    public Pool(
        private let initSize!: Int64 = 0, //初始化大小
        private let minSize!: Int64 = 0, //池中最小对象数
        private let maxSize!: Int64 = 10, //池中最大对象数
        private let checkDuration!: Duration = Duration.second, //对象有效性检查周期
        private let creationRetries!: Int64 = 1, //对象创建失败的重试次数
        private let creator!: () -> T, //创建对象
        private let checker!: (T) -> Bool = {o => true}, //检查对象有效性
        private let destroier!: (T) -> Unit = {o => } //销毁对象
    ) {
        queue = SyncDeque<T>.create(maxSize: maxSize)
        creationEvent.put(initSize)
        checkTimer = Timer.after(checkDuration, check)
        makeThread()
        Process.current.atExit(close)
    }
    public init(
        initSize!: Int64 = 0,
        minSize!: Int64 = 0,
        maxSize!: Int64 = 10,
        checkDuration!: Duration = Duration.second,
        creationRetries!: Int64 = 1,
        creator!: Creator<T>,
        checker!: Checker<T>,
        destroier!: Destroier<T>
    ) {
        this(
            initSize: initSize,
            minSize: minSize,
            maxSize: maxSize,
            checkDuration: checkDuration,
            creationRetries: creationRetries,
            creator: creator.create,
            checker: checker.check,
            destroier: destroier.destroy
        )
    }
    public init(
        initSize!: Int64 = 0,
        minSize!: Int64 = 0,
        maxSize!: Int64 = 10,
        checkDuration!: Duration = Duration.second,
        creationRetries!: Int64 = 1,
        manager!: Manager<T>
    ) {
        this(
            initSize: initSize,
            minSize: minSize,
            maxSize: maxSize,
            checkDuration: checkDuration,
            creationRetries: creationRetries,
            creator: manager.create,
            checker: manager.check,
            destroier: manager.destroy
        )
    }
    private let queue: SyncDeque<T> //储存对象的集合
    private let currentSize = AtomicInt64(0) //池的当前大小
    private let creationEvent = SyncDeque<Int64>.create(maxSize: 10) //创建对象的事件，程序判定需要创建对象时会向这个队列推需要创建的对象数
    prop size: Int64 {
        get() {
            currentSize.load()
        }
    }
    //有专门的线程创建对象
    private let closed = AtomicBool(false) //维持当前池有没有关闭的状态
    public func isClosed(): Bool {
        closed.load()
    }
    public func close(): Unit {
        checkTimer.cancel()
        closed.store(true)
        while (true) {
            match (queue.take(timeout: Duration.second)) {
                case Some(x) =>
                    destroy(x)
                    currentSize.fetchSub(1)
                case _ => break
            }
        }
    }
    public func getObject(timeout!: Duration = Duration.Max): Option<T> {
        if (isClosed()) {
            return None<T>
        }
        var remainder = timeout
        let start = DateTime.now()
        while ((timeout == Duration.Max || remainder > Duration.nanosecond) && !isClosed()) {
            let opt = queue.take(timeout: remainder)
            if (let Some(o) <- opt) {
                if (check(o)) {
                    return opt
                } else {
                    destroy(o)
                }
            }
            let size = currentSize.load()
            if (size < initSize) {
                creationEvent.put(initSize - size, timeout: Duration.nanosecond)
            } else if (size < maxSize) {
                creationEvent.put(1, timeout: Duration.nanosecond)
            }
            if (timeout != Duration.Max) {
                remainder = timeout - Duration.since(start)
            }
        }
        None<T>
    }
    public func returnObject(object: T): Unit {
        checkThenDoOrDestroy(object) {queue.offer(object)}
    }
    public func call<R>(timeout: Duration, toThrowFn: ?() -> Exception, fn: (T) -> ?R): ?R {
        let o: T
        try {
            o = if (let Some(x) <- getObject(timeout: timeout)) {
                x
            } else if (let Some(exf) <- toThrowFn) {
                throw exf()
            } else {
                return None<R>
            }
            return fn(o)
        } finally {
            returnObject(o)
        }
    }
    public func call<R>(timeout: Duration, toThrow: Bool, fn: (T) -> ?R): ?R {
        if (toThrow) {
            call<R>(timeout, { => PoolException("get none")}, fn)
        } else {
            call<R>(timeout, None<() -> Exception>, fn)
        }
    }
    public func call<R>(toThrow: Bool, fn: (T) -> ?R): ?R {
        call<R>(Duration.Max, toThrow, fn)
    }
    public func call<R>(timeout: Duration, fn: (T) -> ?R): ?R {
        call<R>(timeout, true, fn)
    }
    public func call<R>(toThrowFn: () -> Exception, fn: (T) -> ?R): ?R {
        call<R>(Duration.Max, toThrowFn, fn)
    }
    public func call<R>(fn: (T) -> ?R): ?R {
        call<R>(true, fn)
    }
    private func checkThenDoOrDestroy(object: T, fn: () -> Unit): Bool {
        let curSize = currentSize.load()
        if (curSize <= maxSize && !isClosed() && check(object)) {
            fn()
            true
        } else {
            destroy(object)
            false
        }
    }
    private func destroy(object: T): Unit {
        try {
            destroier(object)
            if (logger.debugEnabled) {
                logger.debug("One object destroied, current size of Pool is ${currentSize.subFetch(1)}.")
            } else {
                currentSize.fetchSub(1)
            }
        } catch (e: Exception) {
            logger.error("error on destroing", e)
        }
    }
    private func makeThread(): Unit {
        spawn {
            while (!isClosed()) {
                if (let Some(target) <- creationEvent.take()) {
                    try {
                        make(target)
                    } catch (e: Exception) {
                        logger.warn(e)
                    }
                }
            }
        }
    }
    private func make(targetSize: Int64): Unit {
        if (isClosed()) {
            return
        }
        var size = if (targetSize > initSize) {
            initSize
        } else {
            targetSize
        }
        let curSize = currentSize.load()
        if (curSize + size > maxSize) {
            size = maxSize - curSize
        }
        while (size > 0 && !isClosed()) {
            make()
            size--
        }
    }
    private func make(): Unit {
        var retried = 0
        while (retried < creationRetries && !isClosed()) {
            try {
                let object = creator()
                if (!check(object)) {
                    destroy(object)
                    retried++
                    continue
                }
                queue.offer(object)
                if (logger.debugEnabled) {
                    logger.debug("New object created, current size of Pool is ${currentSize.addFetch(1)}.")
                } else {
                    currentSize.fetchAdd(1)
                }
                return
            } catch (e: Exception) {
                retried++
                logger.warn("failure on initializing", e)
            }
        }
        logger.warn(
            "object creation failed, tried ${retried} times, max attempts is ${creationRetries} and pool status is ${isClosed()}."
        )
    }
    private func check(): ?Duration {
        if (isClosed()) {
            return None
        }
        queue.removeIf {o => !checkThenDoOrDestroy(o) {}}
        let size = currentSize.load()
        if (size < initSize) {
            creationEvent.put(initSize - size)
        }
        checkDuration
    }
    private func check(object: T): Bool {
        try {
            checker(object)
        } catch (e: Exception) {
            logger.error("check failure", e)
            false
        }
    }
}
public interface Creator<T> {
    func create(): T
}
public interface Checker<T> {
    func check(v: T): Bool {
        true
    }
}
public interface Destroier<T> {
    func destroy(v: T): Unit {}
}
public interface Manager<T> <: Creator<T> & Checker<T> & Destroier<T> {}