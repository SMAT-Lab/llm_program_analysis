package mp4parser
import std.os.posix.*
import std.collection.*
import std.io.*
import std.log.*
public class FileUtils {
    public init() {}
    let logger: SimpleLogger = SimpleLogger()
    public func isFilePathValid(filePath: String): (String,String) {
        let con: Option<Int64> = filePath.lastIndexOf("/")
        var lastSlash: Int64 = 0
        match (con) {
           case Some(v) => lastSlash = v
           case None => throw Exception("Invalid filepath")
        }
        let directoryName: String = filePath[0..lastSlash]
        let fileName: String = filePath[lastSlash + 1..]
        let confield: Option<Int64> = fileName.lastIndexOf(".")
        var len: Int64 = 0
        match (confield) {
           case Some(v) => len = v
           case None => throw Exception("Invalid filepath. Need to include filename")
        }
        let fields: String = fileName[len + 1..]
        logger.info("isFilePathValid lastSlash INDEX : "+"${lastSlash}"+" directoryName : "+"${directoryName}"+" fileName : "+"${fileName}")
        let isFile: Bool = isReg(fileName)
        let isDir: Bool = isDir(directoryName)
        if (!isFile) {
            logger.info("isFilePathValid isFile is  " + "${isFile}")
            throw Exception("${fileName}" + " not normal file")
        }
        if (!isDir) {
            logger.info("isFilePathValid isDir is  " + "${isDir}")
            throw Exception("isFilePathValid invalid directory")
        }
        logger.info("isFilePathValid filePath is valid")
        logger.flush()
        return (fileName,fields)
    }
}