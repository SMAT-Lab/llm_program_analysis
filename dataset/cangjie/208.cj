// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from mysqlclient import mysqlclient.*
from std import unittest.*
from std import unittest.testmacro.*
from std import database.sql.*
from std import time.*
main(): Int64 {
    // 初始化数据库驱动
    let mysqlDriver: MysqlDriver = MysqlDriver("mysql")
    // 通过connectionString和选项打开数据源
    let mysqlDatasource: MysqlDatasource = mysqlDriver.open(
        "HOST=127.0.0.1;USER=root;PASSWD=123;DB=mysql;PORT=3306;UNIX_SOCKET=;CLIENT_FLAG=0",
        Array<(String, String)>()
    )
    // 返回一个可用的链接
    let mysqlConnection: MysqlConnection = mysqlDatasource.connect()
    let mysqlConnectionApi: MysqlConnectionApi = MysqlConnectionApi(mysqlConnection)
    let ret: Int32 = mysqlConnectionApi.mysqlSelectDb("")
    @Assert(true, ret != 0)
    mysqlConnection.close()
    return 0
}