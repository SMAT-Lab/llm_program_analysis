package httpclient
from std import io.*
from std import collection.*
from std import fs.*
public class FileDownload {
    public init () {}
    public func builder (pathname: String, fileData: String) {
        var filePathValid = FileUtils().isFilePathValid(pathname)
        var fs: File = File(pathname,Open(false, true))
        if (fs.canWrite()) {
        	let toWrite: Array<UInt8> = fileData.toUtf8Array()
        	let writeFile = fs.write(toWrite)
        	fs.flush()
        	fs.close()
        } else {
            throw WriteException("Can not write file")
        }
    }
}