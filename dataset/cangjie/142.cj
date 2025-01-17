package dataorm4cj
protected func CursorQueryDataInternalCreate<E>(dao: IAbstractDao, sql: sqlType, initialValues: Array<ValueType>): CursorQuery<E> where E <: EntityType {
    return CursorQueryDataCreate<E>(dao, sql, initialValues, -1, -1)
}
protected func CursorQueryDataCreate<E>(dao: IAbstractDao, sql: sqlType, initialValues: Array<ValueType>, limitPosition: Int64, offsetPosition: Int64): CursorQuery<E> where E <: EntityType  {
    let queryData = CursorQueryData<E>(dao, sql, initialValues, limitPosition,
            offsetPosition)
    return queryData.forCurrentThread()
}
public class CursorQueryData<T> <: AbstractQueryData<T, CursorQuery<T>> where T <: EntityType {
    private let limitPosition: Int64
    private let offsetPosition: Int64
    protected init(dao: IAbstractDao,sql: sqlType, initialValues: Array<ValueType>, limitPosition: Int64, offsetPosition: Int64) {
        super(dao, sql, initialValues)
        this.limitPosition = limitPosition
        this.offsetPosition = offsetPosition
    }
    protected func createQuery(): CursorQuery<T> {
        CursorQuery<T>(this, this.dao, this.sql, this.initialValues, limitPosition, offsetPosition)
    }
}
public class CursorQuery<T> <: AbstractQueryWithLimit<T> where T <: EntityType {
    private let queryData: CursorQueryData<T>
    init(queryData: CursorQueryData<T>, dao: IAbstractDao, sql: sqlType, initialValues: Array<ValueType>, limitPosition: Int64, offsetPosition: Int64) {
        super(dao, sql, initialValues, limitPosition, offsetPosition)
        this.queryData = queryData
    }
    public func forCurrentThread(): CursorQuery<T> {
        return queryData.forCurrentThread(this)
    }
    public func query(): ResultSet {
        checkThread()
        return match (sql) {
            case SQL(v) => dao.getDatabase().querySql(v, bindArgs: parameters)
            case PREDICATES(v) => dao.getDatabase().query(v.rdbPredicates, [])
        }
    }
    // copy setParameter methods to allow easy chaining
    public override func setParameter(index: Int64, parameter: ValueType ): AbstractQueryWithLimit<T> {
        return super.setParameter(index, parameter)
    }
    public override func setParameter(index: Int64, parameter: ?DateTime): AbstractQuery<T> {
        return super.setParameter(index, parameter)
    }
    public override func setParameter(index: Int64, parameter: ?Bool): AbstractQuery<T> {
        return super.setParameter(index, parameter)
    }
}