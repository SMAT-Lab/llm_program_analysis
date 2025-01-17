package opds_cj.data_stru

import std.{process.*, fs.*, convert.*, regex.*, collection.*}
import opds_cj.config.baseConfig

public class Page {
    public var width: Int64 = 0
    public var height: Int64 = 0
    public var format: String = ""
    var path: String = ""
    public var data: ArrayList<Byte> = ArrayList<Byte>()

    public static func unzip(file: String, id: String) {
        let argument: Array<String> = ["e", "-y", file, "-o./data/cache/${id}"]
        Process.run("7z", argument, stdOut: Discard)
    }

    public static func identify(path: String) {
        let output = Process.runOutput("identify", path)
        return String.fromUtf8(output[1]).split(" ")
    }

    public static func getPage(id: String, page: Int64, convert: String) {
        var pageImage = Page()
        let url = baseConfig.getFileURL(Books.getFile(id))
        if (!exists("./data/cache/${id}/")) {
            unzip(url, id)
        }
        for (file in Directory.readFrom("data/cache/${id}/")) {
            var filename = file.path.fileNameWithoutExtension
            let r = Regex("\\d+")
            let matchData = r.matcher(filename).find().getOrThrow().matchStr()
            if (Int64.parse(matchData) == page) {
                pageImage.path = file.path.toString()
                let info = identify(pageImage.path)
                pageImage.format = info[1].toAsciiLower()
                pageImage.width = Int64.parse(info[2].split("x")[0])
                pageImage.height = Int64.parse(info[2].split("x")[1])
                pageImage.convert(convert)
                return pageImage
            }
        }
        return pageImage
    }
    public func readFile() {
        this.data.appendAll(File.readFrom(this.path))
    }

    func convert(type_u: String) {
        if (type_u == "") {
            return
        }
        if (this.format != type_u) {
            if (!exists(this.path.replace(".${this.format}", ".${type_u}"))) {
                let argument: Array<String> = [this.path, this.path.replace(".${this.format}", ".${type_u}")]
                Process.run("convert", argument, stdOut: Discard)
            }
            this.path = this.path.replace(".${this.format}", ".${type_u}")
            this.format = type_u
        }
    }
}
