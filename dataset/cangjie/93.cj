package cj_debounce_throttle
import cj_debounce_throttle.macros.*

func debounceAction(action: () -> Unit) {
    action()

    sleep(Duration.millisecond * 10)
    action()

    sleep(Duration.millisecond * 20)
    action()

    sleep(Duration.millisecond * 30)
    action()
}

func throttleAction(action: () -> Unit) {
    action()

    sleep(Duration.millisecond * 20)
    action()

    sleep(Duration.millisecond * 40)
    action()

    sleep(Duration.millisecond * 80)
    action()
}

func debounceRepeater() {
    let start = getNowTime()
    // let config = RepeaterConfig(interval: Duration.millisecond * 100, leading: false, trailing: true)
    // Repeater(throttle: false, config: config){}
    Repeater(throttle: false, mode: Trailing(100)) {
        println('testDebounce执行间隔 ${getNowTime()-start}')
    }
}

func throttleRepeater() {
    let start = getNowTime()
    Repeater(throttle: true, mode: Trailing(50)) {
        println('testThrottle执行间隔 ${getNowTime()-start}')
    }
}

let start = getNowTime()
@Debounce[100]
func debounceFunc() {
    println('myDebounce执行间隔 ${getNowTime()-start}')
}

@Throttle[50]
func throttleFunc() {
    println('myThrottle执行间隔 ${getNowTime()-start}')
}

class RepeaterMemberMacro {
    let start = getNowTime()

    @Debounce[100]
    func myDebounce() {
        println('myDebounce执行间隔 ${getNowTime()-start}')
    }

    @Throttle[50]
    func myThrottle() {
        println('myThrottle执行间隔 ${getNowTime()-start}')
    }
}

main(): Int64 {
    // 直接使用Repeater
    // debounceAction(debounceRepeater().call)
    // throttleAction(throttleRepeater().call)
    // 全局函数 使用宏
    // debounceAction(debounceFunc)
    // throttleAction(throttleFunc)
    // 类的实例成员方法 使用宏
    // debounceAction(RepeaterMemberMacro().myDebounce)
    throttleAction(RepeaterMemberMacro().myThrottle)

    sleep(Duration.second * 2)
    return 0
}
