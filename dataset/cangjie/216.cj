package log.impl
from std import console.Console
from std import log.* as stdlog.*
from std import sync.ReentrantMutex
from std import time.DateTime
import base.exception.*
import io.WrappedOutputStream
public import log.*
import log.exception.*
let _ = ConsoleLoggerAppender.register()//将本实现注册到LoggerAppenderCreator
public class ConsoleLoggerAppender <: AsyncLogger {
    public init(name!: String, level!: LogLevel, pattern!: LogPattern) {
        super(name, level, pattern, Console.stdOut)
    }
    public static func register(): Unit {
        LoggerAppenderCreator.register("console") {
            name, cfg => if (let Some(appender) <- cfg.getConf("console", name)) {
                ConsoleLoggerAppender(
                    name: name,
                    level: cfg.getLevelConf(appender),
                    pattern: cfg.getPatternConf(appender)
                )
            } else {
                NoneLogAppender.instance
            }
        }
    }
    public prop closable: Bool {
        get() {
            false
        }
    }
}