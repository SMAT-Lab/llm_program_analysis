from std import sync.*
from std import time.*
var mon = Monitor()
var flag: Bool = true
main(): Int64 {
    let fut = spawn { =>
        mon.lock()
        while (flag) {
            println("New thread: before wait")
            // Monitor 对象执行 wait 时，必须在锁的保护下进行，
            // 否则 wait 中释放锁的操作会抛出异常。
            mon.wait()
            println("New thread: after wait")
        }
        mon.unlock()
    }
    // sleep for 10ms, make sure the new thread can be executed
    sleep(10 * Duration.millisecond)
    mon.lock()
    println("Main thread: set flag")
    flag = false
    mon.unlock()
    mon.lock()
    println("Main thread: notify")
    mon.notify()
    mon.unlock()
    // wait for the new thread nished
    fut.get()
    return 0
}