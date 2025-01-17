package opds_cj.sqlite

import std.database.sql.SqlException

/* sqlite3_step() 还未完成执行 */
public let SQLITE_ROW: Int32 = 100
/* sqlite3_step() 已执行完成 */
public let SQLITE_DONE: Int32 = 101
/* 指针类型占内存字节数 */
let POINTER_SIZE: UIntNative = 8

foreign func malloc(size: UIntNative): CPointer<Unit>
foreign func free(p: CPointer<Unit>): Unit

/* 
 * Description: 打开数据库db文件
 */
foreign func sqlite3_open(path: CString, ppDb: CPointer<CPointer<Unit>>): Int32

public func sqlOpen(path: String): CPointer<CPointer<Unit>> {
    let ppDb: CPointer<CPointer<Unit>>
    unsafe {
        let ptr = malloc(POINTER_SIZE)
        ppDb = CPointer<CPointer<Unit>>(ptr)
        let cPath = LibC.mallocCString(path)
        let ret = sqlite3_open(cPath, ppDb)
        LibC.free(cPath)
        if (ret != 0) {
            throw SqlException("Failed to open database.")
        }
    }
    return ppDb
}

/* 
 * Description: 预处理sql语句
 */
foreign func sqlite3_prepare_v2(pDb: CPointer<Unit>, zSql: CString, nBytes: Int32, 
                                ppStmt: CPointer<CPointer<Unit>>, pzTail: CPointer<Unit>): Int32

public func sqlPrepare(ppDb: CPointer<CPointer<Unit>>, sql: String): CPointer<CPointer<Unit>> {
    let ppStmt: CPointer<CPointer<Unit>>
    unsafe {
        let ptr = malloc(POINTER_SIZE)
        ppStmt = CPointer<CPointer<Unit>>(ptr)
        let zSql = LibC.mallocCString(sql)
        let nullptr = CPointer<Unit>()
        let ret = sqlite3_prepare_v2(ppDb.read(), zSql, Int32(sql.size), ppStmt, nullptr)
        LibC.free(zSql)
        if (ret != 0) {
            throw SqlException("Failed to prepare statement.")
        }
    }
    return ppStmt
}

/* 
 * Description: 执行sql语句
 */
foreign func sqlite3_step(pStmt: CPointer<Unit>): Int32

public func sqlStep(ppStmt: CPointer<CPointer<Unit>>): Int32 {
    return unsafe { sqlite3_step(ppStmt.read()) }
}

/* 
 * Description: 获取sql结果指定列的数据类型
 */
foreign func sqlite3_column_type(pStmt: CPointer<Unit>, i: Int32): Int32

public func sqlColumnType(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int32 {
    return unsafe { sqlite3_column_type(ppStmt.read(), i) }
}

/* 
 * Description: 获取sql结果指定文本类型列的值
 */
foreign func sqlite3_column_text(pStmt: CPointer<Unit>, i: Int32): CString 

public func sqlColumnText(ppStmt: CPointer<CPointer<Unit>>, i: Int32): String {
    let ret = unsafe { sqlite3_column_text(ppStmt.read(), i) }
    return ret.toString()
}

/* 
 * Description: 获取sql结果指定列值的字节数
 */
foreign func sqlite3_column_bytes(pStmt: CPointer<Unit>, i: Int32): Int32

public func sqlColumnBytes(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int32 {
    return unsafe { sqlite3_column_bytes(ppStmt.read(), i) }
}

/* 
 * Description: 获取sql结果指定Int64类型列的值
 */
foreign func sqlite3_column_int64(pStmt: CPointer<Unit>, i: Int32): Int64

public func sqlColumnInt64(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int64 {
    return unsafe { sqlite3_column_int64(ppStmt.read(), i) }
}

/* 
 * Description: 获取sql结果指定Float64类型列的值
 */
foreign func sqlite3_column_double(pStmt: CPointer<Unit>, i: Int32): Float64

public func sqlColumnDouble(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Float64 {
    return unsafe { sqlite3_column_double(ppStmt.read(), i) }
}

/* 
 * Description: 获取sql结果blob类型列的值
 */
foreign func sqlite3_column_blob(pStmt: CPointer<Unit>, i: Int32): CPointer<Byte>

public func sqlColumnBlob(ppStmt: CPointer<CPointer<Unit>>, i: Int32): CPointer<Byte> {
    return unsafe { sqlite3_column_blob(ppStmt.read(), i) }
}

/* 
 * Description: 获取sql结果列数
 */
foreign func sqlite3_column_count(pStmt: CPointer<Unit>): Int32 

public func sqlColumnCount(ppStmt: CPointer<CPointer<Unit>>): Int32 {
    return unsafe { sqlite3_column_count(ppStmt.read()) }
}

/* 
 * Description: 获取sql结果指定列名
 */
foreign func sqlite3_column_name(pStmt: CPointer<Unit>, n: Int32): CString

public func sqlColumnName(ppStmt: CPointer<CPointer<Unit>>, n: Int32): String {
    let ret = unsafe { sqlite3_column_name(ppStmt.read(), n) }
    return ret.toString()
}

/* 
 * Description: 获取sql结果指定列声明的数据类型
 */
foreign func sqlite3_column_decltype(pStmt: CPointer<Unit>, i: Int32): CString

public func sqlColumnDecltype(ppStmt: CPointer<CPointer<Unit>>, i: Int32): String {
    let ret = unsafe { sqlite3_column_decltype(ppStmt.read(), i) }
    return ret.toString()
}

/* 
 * Description: 重置sql语句
 */
foreign func sqlite3_reset(pStmt: CPointer<Unit>): Int32

public func sqlReset(ppStmt: CPointer<CPointer<Unit>>): Int32 {
    return unsafe { sqlite3_reset(ppStmt.read()) }
}

/* 
 * Description: 设置超时毫秒数
 */
foreign func sqlite3_busy_timeout(pDb: CPointer<Unit>, ms: Int32): Int32 

public func sqlBusyTimeout(ppDb: CPointer<CPointer<Unit>>, ms: Int32): Int32 {
    return unsafe { sqlite3_busy_timeout(ppDb.read(), ms) }
}

/* 
 * Description: 获取最近执行的sql语句的修改数量
 */
foreign func sqlite3_changes(pDb: CPointer<Unit>): Int32

public func sqlChanges(ppDb: CPointer<CPointer<Unit>>): Int32 {
    return unsafe { sqlite3_changes(ppDb.read()) }
}

/* 
 * Description: 获取最近插入行的ID
 */
foreign func sqlite3_last_insert_rowid(pDb: CPointer<Unit>): Int64

public func sqlLastInsertRowid(ppDb: CPointer<CPointer<Unit>>): Int64 {
    return unsafe { sqlite3_last_insert_rowid(ppDb.read()) }
}

/* 
 * Description: 设置堆内存上限
 */
foreign func sqlite3_soft_heap_limit(n: Int32): Unit

public func sqlSoftHeapLimit(n: Int32): Unit {
    unsafe { sqlite3_soft_heap_limit(n) }
}

/* 
 * Description: 获取sql语句绑定参数数量
 */
foreign func sqlite3_bind_parameter_count(pStmt: CPointer<Unit>): Int32

public func sqlBindParameterCount(ppStmt: CPointer<CPointer<Unit>>): Int32 {
    return unsafe { sqlite3_bind_parameter_count(ppStmt.read()) }
}

/* 
 * Description: 绑定空值到sql语句指定参数
 */
foreign func sqlite3_bind_null(pStmt: CPointer<Unit>, i: Int32): Int32

public func sqlBindNull(ppStmt: CPointer<CPointer<Unit>>, i: Int32): Int32 {
    return unsafe { sqlite3_bind_null(ppStmt.read(), i) }
}

/* 
 * Description: 绑定Int32值到sql语句指定参数
 */
foreign func sqlite3_bind_int(pStmt: CPointer<Unit>, i: Int32, iValue: Int32): Int32

public func sqlBindInt(ppStmt: CPointer<CPointer<Unit>>, i: Int32, iValue: Int32): Int32 {
    return unsafe { sqlite3_bind_int(ppStmt.read(), i, iValue) }
}

/* 
 * Description: 绑定Int64值到sql语句指定参数
 */
foreign func sqlite3_bind_int64(pStmt: CPointer<Unit>, i: Int32, iValue: Int64): Int32

public func sqlBindInt64(ppStmt: CPointer<CPointer<Unit>>, i: Int32, iValue: Int64): Int32 {
    return unsafe { sqlite3_bind_int64(ppStmt.read(), i, iValue) }
}

/* 
 * Description: 绑定Float64值到sql语句指定参数
 */
foreign func sqlite3_bind_double(pStmt: CPointer<Unit>, i: Int32, rValue: Float64): Int32

public func sqlBindDouble(ppStmt: CPointer<CPointer<Unit>>, i: Int32, rValue: Float64): Int32 {
    return unsafe { sqlite3_bind_double(ppStmt.read(), i, rValue) }
}

/* 
 * Description: 绑定文本值到sql语句指定参数
 */
foreign func sqlite3_bind_text(pStmt: CPointer<Unit>, i: Int32, zData: CString, 
    nData: Int32, xDel: CPointer<Unit>): Int32

public func sqlBindText(ppStmt: CPointer<CPointer<Unit>>, i: Int32, data: String) {
    let ret: Int32
    unsafe {
        let zData = LibC.mallocCString(data)
        let nullptr = CPointer<Unit>()
        ret = sqlite3_bind_text(ppStmt.read(), i, zData, Int32(data.size), nullptr)
        LibC.free(zData)
    }
    return ret
}

/* 
 * Description: 解除sql语句绑定参数
 */
foreign func sqlite3_clear_bindings(pStmt: CPointer<Unit>): Int32

public func sqlClearBindings(ppStmt: CPointer<CPointer<Unit>>): Int32 {
    return unsafe { sqlite3_clear_bindings(ppStmt.read()) }
}

/* 
 * Description: 指定数据库执行sql命令
 */
foreign func sqlite3_exec(pDb: CPointer<Unit>, zSql: CString, 
    xCallback: CPointer<Unit>, pArg: CPointer<Unit>, pzErrMsg: CPointer<CString>): Int32

public func sqlExec(ppDb: CPointer<CPointer<Unit>>, sql: String) {
    unsafe {
        let zSql = LibC.mallocCString(sql)
        let nullptr = CPointer<Unit>()
        let ptr = malloc(POINTER_SIZE)
        let pzErrMsg = CPointer<CString>(ptr)
        let ret = sqlite3_exec(ppDb.read(), zSql, nullptr, nullptr, pzErrMsg)
        let errMsg = pzErrMsg.read().toString()
        free(ptr)
        LibC.free(zSql)
        if (ret != 0) {
            throw SqlException(errMsg)
        }
    }
}

/* 
 * Description: 关闭数据库连接
 */
foreign func sqlite3_close(pDb: CPointer<Unit>): Int32

public func sqlClose(ppDb: CPointer<CPointer<Unit>>): Int32 {
    let ret: Int32
    unsafe {
        ret = sqlite3_close(ppDb.read())
        free(CPointer<Unit>(ppDb))
    }
    return ret
}

/* 
 * Description: 销毁sql语句对象，释放内存
 */
foreign func sqlite3_finalize(pStmt: CPointer<Unit>): Int32

public func sqlFinalize(ppStmt: CPointer<CPointer<Unit>>): Int32 {
    let ret: Int32
    unsafe {
        ret = sqlite3_finalize(ppStmt.read())
        free(CPointer<Unit>(ppStmt))
    }
    return ret
}

