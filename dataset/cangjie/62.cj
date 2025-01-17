package opds_cj.data_stru

import opds_cj.sqlite.*
import encoding.json.stream.*
import std.{io.*,collection.*}
import opds_cj.config.baseConfig

func sqlRun(location: String, sql: String): String {
    var ppDb: CPointer<CPointer<Unit>> = sqlOpen(location)
    var ppStmt = sqlPrepare(ppDb, sql)
    var jsonStrList = ""
    while (sqlStep(ppStmt) != SQLITE_DONE) {
        jsonStrList = sqlColumnText(ppStmt, 0)
    }
    sqlFinalize(ppStmt)
    sqlClose(ppDb)
    return jsonStrList
}

public class BookSeries <: JsonDeserializable<BookSeries> {
    public var id: String = "0F00000000000"
    public var name: String = "name"
    public var bookCount: Int64 = 0
    public var url: String = ""
    public var createdDate: String = ""
    public var lastModifiedDate: String = ""
    public var fileLastModified: String = ""

    public static func fromJson(r: JsonReader): BookSeries {
        var res = BookSeries()
        while (let Some(v) <- r.peek()) {
            match (v) {
                case BeginObject =>
                    r.startObject()
                    while (r.peek() != EndObject) {
                        let n = r.readName()
                        match (n) {
                            case "ID" => res.id = r.readValue<String>()
                            case "NAME" => res.name = r.readValue<String>()
                            case "BOOK_COUNT" => res.bookCount = r.readValue<Int64>()
                            case "URL" => res.url = r.readValue<String>()
                            case "CREATED_DATE" => res.createdDate = r.readValue<String>()
                            case "LAST_MODIFIED_DATE" => res.lastModifiedDate = r.readValue<String>()
                            case "FILE_LAST_MODIFIED" => res.fileLastModified = r.readValue<String>()
                            case _ => ()
                        }
                    }
                    r.endObject()
                    break
                case _ => throw Exception()
            }
        }
        return res
    }

    public static func fromJsonToArray(r: JsonReader): ArrayList<BookSeries> {
        var res = ArrayList<BookSeries>()
        while (let Some(v) <- r.peek()) {
            match (v) {
                case BeginArray =>
                    r.startArray()
                    while (r.peek() != EndArray) {
                        res.append(BookSeries.fromJson(r))
                    }
                    r.endArray()
                    break
                case _ => throw Exception()
            }
        }
        return res
    }

    public static func query(query:String): ArrayList<BookSeries> {
        var sql = "SELECT json_group_array(json_object('ID', ID, 'NAME', NAME,'BOOK_COUNT',BOOK_COUNT,'URL',URL,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE,'FILE_LAST_MODIFIED',FILE_LAST_MODIFIED)) FROM SERIES WHERE NAME LIKE '%${query}%';"
        var jsonStrList = sqlRun(baseConfig.database, sql)

        var bas = ByteBuffer()
        unsafe { bas.write(jsonStrList.rawData()) }
        var reader = JsonReader(bas)
        return BookSeries.fromJsonToArray(reader)
    }    

    public static func formDatabase(location: String, page!: Int64 = 0,count!: Int64 = 5,libId!: String = ""): ArrayList<BookSeries> {
        var sql = "SELECT json_group_array(json_object('ID', ID, 'NAME', NAME,'BOOK_COUNT',BOOK_COUNT,'URL',URL,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE,'FILE_LAST_MODIFIED',FILE_LAST_MODIFIED)) FROM ( SELECT * FROM SERIES ORDER BY LAST_MODIFIED_DATE DESC LIMIT ${count} OFFSET ${page * count} )"
        if (libId != "") {
            sql = "SELECT json_group_array(json_object('ID', ID, 'NAME', NAME,'BOOK_COUNT',BOOK_COUNT,'URL',URL,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE,'FILE_LAST_MODIFIED',FILE_LAST_MODIFIED)) FROM ( SELECT * FROM SERIES WHERE LIBRARY_ID = '${libId}' ORDER BY LAST_MODIFIED_DATE DESC LIMIT ${count} OFFSET ${page * count} )"
        }
        var jsonStrList = sqlRun(location, sql)

        var bas = ByteBuffer()
        unsafe { bas.write(jsonStrList.rawData()) }
        var reader = JsonReader(bas)
        return BookSeries.fromJsonToArray(reader)
    }

    public static func formPublisher(publisher: String): ArrayList<BookSeries> {
        var sql = "SELECT json_group_array(json_object('ID', ID, 'NAME', NAME,'BOOK_COUNT',BOOK_COUNT,'URL',URL,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE,'FILE_LAST_MODIFIED',FILE_LAST_MODIFIED)) FROM SERIES WHERE ID IN ( SELECT SERIES_ID FROM SERIES_METADATA WHERE PUBLISHER = '${publisher}' );"

        var jsonStrList = sqlRun(baseConfig.database, sql)

        var bas = ByteBuffer()
        unsafe { bas.write(jsonStrList.rawData()) }
        var reader = JsonReader(bas)
        return BookSeries.fromJsonToArray(reader)
    }

    public static func getCount(id!:String="") {
        var sql = "SELECT COUNT(*) FROM SERIES;"
        if (id!=""){
            sql = "SELECT COUNT(*) FROM SERIES WHERE LIBRARY_ID = '${id}'";
        }
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var number = 1
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            number = sqlColumnInt64(ppStmt, 0)
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)

        return number
    }

    public static func getDesc(id: String) {
        var sql = "SELECT SUMMARY FROM SERIES_METADATA WHERE SERIES_ID = '${id}'"
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var desc = ""
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            desc = sqlColumnText(ppStmt, 0)
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)

        return desc
    }

    public static func fromId(id: String): BookSeries {
        var sql = "SELECT json_object('ID', ID, 'NAME', NAME,'BOOK_COUNT',BOOK_COUNT,'URL',URL,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE,'FILE_LAST_MODIFIED',FILE_LAST_MODIFIED) FROM SERIES WHERE ID = '${id}'"
        var jsonStrList = sqlRun(baseConfig.database, sql)
        var bas = ByteBuffer()
        unsafe { bas.write(jsonStrList.rawData()) }
        var reader = JsonReader(bas)
        return BookSeries.fromJson(reader)
    }
    public static func getPublishList(): ArrayList<String>{
        var sql = "SELECT DISTINCT PUBLISHER FROM SERIES_METADATA;"
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var listStr = ArrayList<String>()
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            for (i in 0..sqlColumnCount(ppStmt)){
                listStr.append(sqlColumnText(ppStmt, i))
            }
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)

        return listStr
    }
}

public class Books <: JsonDeserializable<Books> {
    public var id: String = "0F00000000000"
    public var seriesId: String = "0F00000000000"
    public var libraryId: String = "0F00000000000"
    public var name: String = "name"
    public var number: Int64 = 0
    public var pageCount: Int64 = 0
    public var url: String = ""
    public var createdDate: String = ""
    public var lastModifiedDate: String = ""
    public var fileLastModified: String = ""

    public static func fromJson(r: JsonReader): Books {
        var res = Books()
        while (let Some(v) <- r.peek()) {
            match (v) {
                case BeginObject =>
                    r.startObject()
                    while (r.peek() != EndObject) {
                        let n = r.readName()
                        match (n) {
                            case "ID" => res.id = r.readValue<String>()
                            case "SERIES_ID" => res.seriesId = r.readValue<String>()
                            case "LIBRARY_ID" => res.libraryId = r.readValue<String>()
                            case "NAME" => res.name = r.readValue<String>()
                            case "NUMBER" => res.number = r.readValue<Int64>()
                            case "URL" => res.url = r.readValue<String>()
                            case "CREATED_DATE" => res.createdDate = r.readValue<String>()
                            case "LAST_MODIFIED_DATE" => res.lastModifiedDate = r.readValue<String>()
                            case "FILE_LAST_MODIFIED" => res.fileLastModified = r.readValue<String>()
                            case _ => ()
                        }
                    }
                    r.endObject()
                    break
                case _ => throw Exception()
            }
        }
        res.pageCount = res.getPageCount()
        return res
    }

    public static func getCount(libraryId!: String="") {
        var sql = "SELECT COUNT(*) FROM BOOK;"
        if (libraryId != "") {
            sql = "SELECT COUNT(*) FROM BOOK WHERE LIBRARY_ID = '${libraryId}';"
        }
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var number = 1
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            number = sqlColumnInt64(ppStmt, 0)
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)

        return number
    }

    public func getPageCount() {
        var sql = "SELECT PAGE_COUNT FROM MEDIA WHERE BOOK_ID = '${id}'"
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var number = 1
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            number = sqlColumnInt64(ppStmt, 0)
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)

        return number
    }

    public static func getThumbType(id:String): String {
        var sql = "SELECT MEDIA_TYPE FROM THUMBNAIL_BOOK WHERE BOOK_ID = '${id}'"
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var type_u = ""
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            type_u = sqlColumnText(ppStmt, 0)
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)

        return type_u
    }

    public static func getFileType(id:String): String {
        var sql = "SELECT MEDIA_TYPE FROM MEDIA WHERE BOOK_ID = '${id}'"
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var type_u = ""
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            type_u = sqlColumnText(ppStmt, 0)
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)

        return type_u
    }

    public static func getFile(id:String): String {
        var sql = "SELECT URL FROM BOOK WHERE ID = '${id}'"
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var url = ""
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            url = sqlColumnText(ppStmt, 0)
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)

        return url
    }

    public static func getThumb(id:String): Array<UInt8>{
        var sql = "SELECT THUMBNAIL FROM THUMBNAIL_BOOK WHERE BOOK_ID = '${id}'"
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var imageData:ArrayList<UInt8>=ArrayList<UInt8>()
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            var size:Int64 = sqlColumnBytes(ppStmt, 0).position()
            imageData.reserve(size)
            unsafe{
                var cur = sqlColumnBlob(ppStmt, 0)
                for (_ in 0..size){
                    imageData.append(UInt8(cur.read()))
                    cur = cur +1
                }
            }
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)
        return imageData.toArray()
    }

    public static func fromJsonToArray(r: JsonReader): ArrayList<Books> {
        var res = ArrayList<Books>()
        while (let Some(v) <- r.peek()) {
            match (v) {
                case BeginArray =>
                    r.startArray()
                    while (r.peek() != EndArray) {
                        res.append(Books.fromJson(r))
                    }
                    r.endArray()
                    break
                case _ => throw Exception()
            }
        }
        return res
    }

    public static func formID(id: String): Books {
        var sql = "SELECT json_object('ID', ID,'SERIES_ID',SERIES_ID,'LIBRARY_ID',LIBRARY_ID, 'NAME', NAME,'NUMBER',NUMBER,'URL',URL,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE,'FILE_LAST_MODIFIED',FILE_LAST_MODIFIED) FROM BOOK WHERE ID = '${id}'"
        var jsonStrList = sqlRun(baseConfig.database, sql)

        var bas = ByteBuffer()
        unsafe { bas.write(jsonStrList.rawData()) }
        var reader = JsonReader(bas)
        return Books.fromJson(reader)
    }

    public static func formDatabase(location: String, page!: Int64 = 0,count!: Int64 = 5,libId!: String = "",seriesId!:String = ""): ArrayList<Books> {
        var sql = "SELECT json_group_array(json_object('ID', ID,'SERIES_ID',SERIES_ID,'LIBRARY_ID',LIBRARY_ID, 'NAME', NAME,'NUMBER',NUMBER,'URL',URL,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE,'FILE_LAST_MODIFIED',FILE_LAST_MODIFIED)) FROM ( SELECT * FROM BOOK ORDER BY LAST_MODIFIED_DATE DESC LIMIT ${count} OFFSET ${page * count} )"
        if (libId != "") {
            sql = "SELECT json_group_array(json_object('ID', ID,'SERIES_ID',SERIES_ID,'LIBRARY_ID',LIBRARY_ID, 'NAME', NAME,'NUMBER',NUMBER,'URL',URL,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE,'FILE_LAST_MODIFIED',FILE_LAST_MODIFIED)) FROM ( SELECT * FROM BOOK WHERE LIBRARY_ID = '${libId}' ORDER BY LAST_MODIFIED_DATE DESC LIMIT ${count} OFFSET ${page * count} )"
        }
        if (seriesId != "") {
            sql = "SELECT json_group_array(json_object('ID', ID,'SERIES_ID',SERIES_ID,'LIBRARY_ID',LIBRARY_ID, 'NAME', NAME,'NUMBER',NUMBER,'URL',URL,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE,'FILE_LAST_MODIFIED',FILE_LAST_MODIFIED)) FROM ( SELECT * FROM BOOK WHERE SERIES_ID = '${seriesId}' ORDER BY LAST_MODIFIED_DATE DESC LIMIT ${count} OFFSET ${page * count} )"
        }
        var jsonStrList = sqlRun(location, sql)

        var bas = ByteBuffer()
        unsafe { bas.write(jsonStrList.rawData()) }
        var reader = JsonReader(bas)
        return Books.fromJsonToArray(reader)
    }
}

public class Librarys <: JsonDeserializable<Librarys> {
    public var id: String = "0F00000000000"
    public var name: String = "name"
    public var root: String = ""
    public var createdDate: String = ""
    public var lastModifiedDate: String = ""

    public static func fromJson(r: JsonReader): Librarys {
        var res = Librarys()
        while (let Some(v) <- r.peek()) {
            match (v) {
                case BeginObject =>
                    r.startObject()
                    while (r.peek() != EndObject) {
                        let n = r.readName()
                        match (n) {
                            case "ID" => res.id = r.readValue<String>()
                            case "NAME" => res.name = r.readValue<String>()
                            case "ROOT" => res.root = r.readValue<String>()
                            case "CREATED_DATE" => res.createdDate = r.readValue<String>()
                            case "LAST_MODIFIED_DATE" => res.lastModifiedDate = r.readValue<String>()
                            case _ => ()
                        }
                    }
                    r.endObject()
                    break
                case _ => throw Exception()
            }
        }
        return res
    }

    public static func fromJsonToArray(r: JsonReader): ArrayList<Librarys> {
        var res = ArrayList<Librarys>()
        while (let Some(v) <- r.peek()) {
            match (v) {
                case BeginArray =>
                    r.startArray()
                    while (r.peek() != EndArray) {
                        res.append(Librarys.fromJson(r))
                    }
                    r.endArray()
                    break
                case _ => throw Exception()
            }
        }
        return res
    }

    public static func formDatabase(location: String): ArrayList<Librarys> {
        var sql = "SELECT json_group_array(json_object('ID', ID, 'NAME', NAME,'ROOT',ROOT,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE)) FROM LIBRARY"

        var jsonStrList = sqlRun(location, sql)

        var bas = ByteBuffer()
        unsafe { bas.write(jsonStrList.rawData()) }
        var reader = JsonReader(bas)
        return Librarys.fromJsonToArray(reader)
    }

    public static func fromId(id: String): Librarys {
        var sql = "SELECT json_object('ID', ID, 'NAME', NAME,'ROOT',ROOT,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE) FROM LIBRARY WHERE ID = '${id}'"

        var jsonStrList = sqlRun(baseConfig.database, sql)

        var bas = ByteBuffer()
        unsafe { bas.write(jsonStrList.rawData()) }
        var reader = JsonReader(bas)
        return Librarys.fromJson(reader)
    }

    public static func getReadingCount(userID: String,libraryId!: String=""): Int64 {
        var sql = "SELECT COUNT(*) FROM READ_PROGRESS WHERE COMPLETED = False AND USER_ID='${userID}';"
        if (libraryId != "") {
            sql = "SELECT COUNT(*) FROM BOOK WHERE ID IN ( SELECT BOOK_ID FROM READ_PROGRESS WHERE COMPLETED = False AND USER_ID='${userID}' ) AND LIBRARY_ID = '${libraryId}'"
        }
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var number = 1
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            number = sqlColumnInt64(ppStmt, 0)
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)
        
        return number
    }

    public static func getReading(userID: String,libraryId!: String="",  page!: Int64 = 0,count!: Int64 = 5): ArrayList<Books> {
        var sql = "SELECT json_group_array(json_object('ID', ID,'SERIES_ID',SERIES_ID,'LIBRARY_ID',LIBRARY_ID, 'NAME', NAME,'NUMBER',NUMBER,'URL',URL,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE,'FILE_LAST_MODIFIED',FILE_LAST_MODIFIED)) FROM BOOK WHERE ID IN ( SELECT BOOK_ID FROM READ_PROGRESS WHERE COMPLETED = False AND USER_ID='${userID}' ) LIMIT ${count} OFFSET ${count*page};"
        if (libraryId != "") {
            sql = "SELECT json_group_array(json_object('ID', ID,'SERIES_ID',SERIES_ID,'LIBRARY_ID',LIBRARY_ID, 'NAME', NAME,'NUMBER',NUMBER,'URL',URL,'CREATED_DATE',CREATED_DATE,'LAST_MODIFIED_DATE',LAST_MODIFIED_DATE,'FILE_LAST_MODIFIED',FILE_LAST_MODIFIED)) FROM BOOK WHERE ID IN ( SELECT BOOK_ID FROM READ_PROGRESS WHERE COMPLETED = False AND USER_ID='${userID}' ) AND LIBRARY_ID = '${libraryId}' LIMIT ${count} OFFSET ${count*page};"
        }
        var jsonStrList = sqlRun(baseConfig.database, sql)

        var bas = ByteBuffer()
        unsafe { bas.write(jsonStrList.rawData()) }
        var reader = JsonReader(bas)
        return Books.fromJsonToArray(reader)
    }
}

public class Link <: JsonSerializable {
    public var title: String
    public var rel: String
    public var href: String
    public var type_u: String
    public var templated: Bool
    public init(
        title!: String = "",
        rel!: String = "",
        href!: String = "",
        type_u!: String = "",
        templated!: Bool = false
    ) {
        this.title = title
        this.rel = rel
        this.href = href
        this.type_u = type_u
        this.templated = templated
    }
    public func toJson(w: JsonWriter): Unit {
        w.startObject()
        if (href != "") {
            w.writeName("href").writeValue(href)
        }
        if (rel != "") {
            w.writeName("rel").writeValue(rel)
        }
        if (title != "") {
            w.writeName("title").writeValue(title)
        }
        if (type_u != "") {
            w.writeName("type").writeValue(type_u)
        }
        if (templated) {
            w.writeName("templated").writeValue(templated)
        }
        w.endObject()
    }
}


public class Group <: JsonSerializable{
    public var metadata:Metadata = Metadata()
    public var links:ArrayList<Link> = ArrayList<Link>()
    public var navigation:ArrayList<Link> = ArrayList<Link>()
    public var publications:ArrayList<Publication> = ArrayList<Publication>()

    public func toJson(w: JsonWriter): Unit {
        w.startObject()
        w.writeName("metadata").writeValue(metadata)
        if(links.size != 0){
            w.writeName("links").writeValue<ArrayList<Link>>(links)
        }
        if(navigation.size != 0){
            w.writeName("navigation").writeValue<ArrayList<Link>>(navigation)
        }
        if(publications.size != 0){
            w.writeName("publications").writeValue<ArrayList<Publication>>(publications)
        }
        w.endObject()
    }
}

public class Links <: JsonSerializable{
    var self:Link
    var home:Link
    var search:Link
    var searchPage:Bool
    var pageSwitch:ArrayList<Link> = ArrayList<Link>()
    public init(host: String, selfPath: String, page!:Int64 = -1,searchPage!:Bool = false){
        self = Link(rel: "self", 
                  href: "http://${host}/opds/v2/${selfPath}"
            )
        home = Link(
            title: "Home",
            rel: "start",
            href: "http://${host}/opds/v2/catalog",
            type_u: "application/opds+json"
        )
        this.searchPage = searchPage
        search = Link(
            title: "Search",
            rel: "search",
            href: "http://${host}/opds/v2/search{?query}",
            type_u: "application/opds+json",
            templated: true
        )
        if (page != -1){
            pageSwitch.append(
                Link(
                    rel: "next",
                    href: "http://${host}/opds/v2/${selfPath}?page=${page+1}"
                )
            )
            if (page != 0){
                pageSwitch.append(
                    Link(
                        rel: "previous",
                        href: "http://${host}/opds/v2/${selfPath}?page=${page-1}"
                    )
                )
            }
        }
    }
    public func toJson(w: JsonWriter): Unit {
        w.startArray()
        w.writeValue(self)
        w.writeValue(home)
        if (!searchPage){
            w.writeValue(search)
        }
        for (i in 0..pageSwitch.size){
            w.writeValue(pageSwitch[i])
        }
        w.endArray()
    }
}


public class Navigation <: JsonSerializable{
    var recommended:Link
    var browse:Link
    public init(host: String, selfPath!: String = "libraries"){
        recommended = Link(
            title: "Recommended",
            rel: "subsection",
            href: "http://${host}/opds/v2/${selfPath}",
            type_u: "application/opds+json"
        )
        browse = Link(
            title: "Browse",
            rel: "subsection",
            href: "http://${host}/opds/v2/${selfPath}/browse",
            type_u: "application/opds+json",
        )
    }
    public func toJson(w: JsonWriter): Unit {
        w.startArray()
        w.writeValue(recommended)
        w.writeValue(browse)
        w.endArray()
    }
}

public class Metadata <: JsonSerializable {
    public var title: String = ""
    public var conformsTo: String = ""
    public var modified: String = ""
    public var description: String = ""
    public var itemsPerPage: Int64 = -1
    public var currentPage: Int64 = -1
    public var numberOfItems: Int64 = -1
    public var numberOfPages: Int64 = -1
    public var contributor: ArrayList<String> = ArrayList<String>()
    public var seriesBelongTo: ArrayList<SeriesBelongTo> = ArrayList<SeriesBelongTo>()
    public init() {
    }
    public init(title: String,conformsTo!: String = "", modified!: String = "", itemsPerPage!: Int64 = -1, currentPage!: Int64 = -1,
        numberOfItems!: Int64 = -1, numberOfPages!: Int64 = -1, contributor!: ArrayList<String> = ArrayList<String>() ){
        this.title = title
        this.conformsTo = conformsTo
        this.modified = modified
        this.itemsPerPage = itemsPerPage
        this.currentPage = currentPage
        this.numberOfItems = numberOfItems
        this.numberOfPages = numberOfPages
        this.contributor = contributor
        if (this.modified.contains(" ")){
            this.timeFormat()
        }
    }

    public func timeFormat(){
        this.modified = this.modified.replace(" ","T")+"Z"
    }

    public func addBookDesc(id: String) {
        this.description = BookSeries.getDesc(id)
    }

    public func addSeriesBelongTo(obj: Books) {
        this.seriesBelongTo.append(SeriesBelongTo(obj))
    }

    public func toJson(w: JsonWriter): Unit {
        w.startObject()
        w.writeName("title").writeValue(title)
        if (conformsTo != "") {
            w.writeName("conformsTo").writeValue(conformsTo)
        }
        if (modified != "") {
            w.writeName("modified").writeValue(modified)
        }
        if (description != "") {
            w.writeName("description").writeValue(description)
        }
        if (itemsPerPage != -1) {
            w.writeName("itemsPerPage").writeValue(itemsPerPage)
        }
        if (currentPage != -1) {
            w.writeName("currentPage").writeValue(currentPage)
        }
        if (numberOfItems != -1) {
            w.writeName("numberOfItems").writeValue(numberOfItems)
        }
        if (numberOfPages != -1) {
            w.writeName("numberOfPages").writeValue(numberOfPages)
        }
        if (contributor.size != 0) {
            w.writeName("contributor").writeValue<ArrayList<String>>(contributor)
        }
        if (seriesBelongTo.size != 0) {
            w.writeName("belongsTo").startObject()
            w.writeName("series").writeValue<ArrayList<SeriesBelongTo>>(seriesBelongTo)
            w.endObject()
        }
        w.endObject()
    }
}

public class SeriesBelongTo <: JsonSerializable {
    public var name: String = ""
    public var position: Int64 = -1
    public var links: ArrayList<Link> = ArrayList<Link>()
    public init() {
    }
    public init(obj: Books) {
        this.name = obj.name
        this.position = obj.number
        this.links.append(
            Link(
                href: "http://192.168.10.86:25600/opds/v2/series/${obj.id}",
                type_u: "application/vnd.comicbook+json"
            )
        )
    }
    public func toJson(w: JsonWriter): Unit {
        w.startObject()
        if (name != "") {
            w.writeName("name").writeValue(name)
        }
        if (position != -1) {
            w.writeName("position").writeValue(position)
        }
        if (links.size != 0) {
            w.writeName("links").writeValue<ArrayList<Link>>(links)
        }
        w.endObject()
    }
}

public class Publication <: JsonSerializable {
    var context: String = ""
    var metadata: Metadata = Metadata()
    var links: ArrayList<Link> = ArrayList<Link>()
    var images: ArrayList<Link> = ArrayList<Link>()
    var readingOrder: ArrayList<Link> = ArrayList<Link>()
    var resources: ArrayList<Link> = ArrayList<Link>()
    var toc: ArrayList<Link> = ArrayList<Link>()
    var landmarks: ArrayList<Link> = ArrayList<Link>()
    var pageList: ArrayList<Link> = ArrayList<Link>()

    static func getContibuor(id: String): ArrayList<String> {
        var sql = "SELECT NAME FROM BOOK_METADATA_AUTHOR WHERE BOOK_ID = '${id}'"
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var listStr = ArrayList<String>()
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            for (i in 0..sqlColumnCount(ppStmt)){
                listStr.append(sqlColumnText(ppStmt, i))
            }
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)

        return listStr
    }

    public init(obj: Books, host: String) {
        this.context = "https://readium.org/webpub-manifest/context.jsonld"
        this.metadata = Metadata(
            obj.name,
            modified: obj.lastModifiedDate,
            numberOfPages: obj.pageCount,
            contributor: getContibuor(obj.id)
        )
        this.metadata.addSeriesBelongTo(obj)
        this.links.append(
            Link(
                rel: "self",
                href: "http://${host}/api/v1/books/${obj.id}/manifest",
                type_u: "application/divina+json"
            )
        )
        this.links.append(
            Link(
                rel: "http://opds-spec.org/acquisition",
                href: "http://${host}/api/v1/books/${obj.id}/file",
                type_u: "application/vnd.comicbook+zip"
            )
        )
        this.images.append(
            Link(
                href: "http://${host}/api/v1/books/${obj.id}/thumbnail",
                type_u: "image/jpeg"
            )
        )
    }
    public func toJson(w: JsonWriter): Unit {
        w.startObject()
        w.writeName("context").writeValue(context)
        w.writeName("metadata").writeValue(metadata)
        w.writeName("links").writeValue<ArrayList<Link>>(links)
        w.writeName("images").writeValue<ArrayList<Link>>(images)
        w.writeName("readingOrder").writeValue<ArrayList<Link>>(readingOrder)
        w.writeName("resources").writeValue<ArrayList<Link>>(resources)
        w.writeName("toc").writeValue<ArrayList<Link>>(toc)
        w.writeName("landmarks").writeValue<ArrayList<Link>>(landmarks)
        w.writeName("pageList").writeValue<ArrayList<Link>>(pageList)
        w.endObject()
    }
}