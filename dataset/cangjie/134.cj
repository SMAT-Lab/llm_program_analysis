package silo.spirit.dao
from std import collection.*
from std import database.sql.Connection
from cangjie_spirit import spirit.session.Dao
from cangjie_spirit import spirit.runner.SqlRunner
from cangjie_spirit import spirit.exception.{ExceptionContext, wrapException, ResultHandleException}
from cangjie_spirit import spirit.cursor.{Cursor, ProxyCursor, DefaultCursor}
from cangjie_spirit import spirit.configuration.GlobalConfiguration
from crystal import reflection.{Reflectable, Class}
public class SiloSpiritDao <: Dao {
    let sqlRunner: SqlRunner
    let connection: Connection
    public var closeFun: () -> Unit = { => }
    public init(configuration: GlobalConfiguration, sqlRunner: SqlRunner, connection: Connection,
        closeFun!: () -> Unit = {=>}) {
        super(configuration)
        this.sqlRunner = sqlRunner
        this.connection = connection
        this.closeFun = closeFun
    }
    public func select(sqlID: String, inputParam: Option<Reflectable>, clazz: Class): ArrayList<Reflectable> {
        try {
            let sqlStatement = getSqlStatement(sqlID)
            sqlRunner.query(sqlStatement, inputParam, clazz)
        } catch (e: Exception) {
            throw wrapException(e)
        } finally {
            ExceptionContext.close()
            closeFun()
        }
    }
    public func selectCursor(sqlID: String, inputParam: Option<Reflectable>, clazz: Class): Cursor<Reflectable> {
        try {
            let sqlStatement = getSqlStatement(sqlID)
            sqlRunner.queryCursor(sqlStatement, inputParam, clazz)
        } catch (e: Exception) {
            throw wrapException(e)
        } finally {
            ExceptionContext.close()
            closeFun()
        }
    }
    public func select(sqlID: String, inputParam: Option<Reflectable>, clazz: Class,
        resultItemCallback: (Reflectable) -> Bool): Unit {
        try {
            let sqlStatement = getSqlStatement(sqlID)
            sqlRunner.query(sqlStatement, inputParam, clazz, resultItemCallback)
        } catch (e: Exception) {
            throw wrapException(e)
        } finally {
            ExceptionContext.close()
            closeFun()
        }
    }
    public func execute(sqlID: String, inputParam: Option<Reflectable>, clazz: Class): Any {
        try {
            let sqlStatement = getSqlStatement(sqlID)
            let updateResult = sqlRunner.update(sqlStatement, inputParam)
            return adaptUpdateResult(updateResult, clazz)
        } catch (e: Exception) {
            throw wrapException(e)
        } finally {
            ExceptionContext.close()
            closeFun()
        }
    }
    public func batchExecute(sqlID: String, inputParam: Option<Reflectable>, _: Class): Any {
        try {
            let sqlStatement = getSqlStatement(sqlID)
            sqlRunner.batchUpdate(sqlStatement, inputParam)
        } catch (e: Exception) {
            throw wrapException(e)
        } finally {
            ExceptionContext.close()
            closeFun()
        }
    }
    public func commit(): Unit {
        sqlRunner.commit()
    }
    public func rollback(): Unit {
        sqlRunner.rollback()
    }
    public func beginTransaction(): Unit {
        sqlRunner.beginTransaction()
    }
    public func close(): Unit {
        sqlRunner.close()
        connection.close()
        closeFlag = true
    }
    private func adaptUpdateResult(updateResult: Int64, clazz: Class): Any {
        let instance = clazz.newInstance()
        if (instance is Bool) {
            if (updateResult > 0) {
                return true
            }
            return false
        }
        return convertNumberToType(updateResult, clazz)
    }
    private func convertNumberToType(number: Int64, clazz: Class): Any {
        match (clazz.getName()) {
            case "Int64" => Int64(number)
            case "Int32" => Int32(number)
            case "Int16" => Int16(number)
            case "Int8" => Int8(number)
            case "IntNative" => IntNative(number)
            case "UInt64" => UInt64(number)
            case "UInt32" => UInt32(number)
            case "UInt16" => UInt16(number)
            case "UInt8" => UInt8(number)
            case "UIntNative" => UIntNative(number)
            case "Float64" => Float64(number)
            case "Float32" => Float32(number)
            case "Float16" => Float16(number)
            case "Char" => Char(number)
            case "Bool" => number != 0
            case "String" => "${number}"
            case _ => throw ResultHandleException(
                "update sql result only support Bool and numberic type, not support ${clazz.getName()}, please change it"
            )
        }
    }
    public func flushStatements(): Int64 {
        var result = sqlRunner.flushStatements()
        return result
    }
}