package log4cj
public interface CJLoggerFileWriter {
    func prepare(config: LogConfig): Unit
    func write(config: LogConfig, level: LogLevel, msg: Array<UInt8>): Unit
    func checkFileRolling(config: LogConfig, filePath: Path): Bool
    func rollingFile(config: LogConfig, filePath: Path): Unit
}