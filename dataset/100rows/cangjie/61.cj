package opds_cj.data_stru

import encoding.base64.*
import opds_cj.sqlite.*
import opds_cj.config.baseConfig

public class User{
    public var id:String = ""
    public var email:String = ""
    var password:String = ""
    public init(authStr:Option<String>){
        var auth:String=""
        match(authStr){
            case Some(x) => auth = x.trimStart("Basic ")
            case None => return
        }
        let decode = String.fromUtf8(fromBase64String(auth).getOrThrow()).split(":")
        this.email = decode[0]
        this.password = decode[1]
        this.id = getID(this.email)
    }

    func getID(email:String):String{
        var sql = "SELECT ID FROM USER WHERE EMAIL='${email}';"
        var ppDb: CPointer<CPointer<Unit>> = sqlOpen(baseConfig.database)
        var ppStmt = sqlPrepare(ppDb, sql)
        var id = ""
        while (sqlStep(ppStmt) != SQLITE_DONE) {
            id = sqlColumnText(ppStmt, 0)
        }
        sqlFinalize(ppStmt)
        sqlClose(ppDb)

        return id
    }
}