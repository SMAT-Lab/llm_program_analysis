package mysqlclient_ffi
public class SqlDateTime <: SqlDbType {
    private var dateTime: DateTime
    public init(dateTime: DateTime) {
        this.dateTime = dateTime
    }
    public mut prop value: DateTime {
        get() {
            dateTime
        }
        set(value) {
            dateTime = value
        }
    }
    public prop name: String {
        get() {
            "SqlTimestampWithoutTz"
        }
    }
}
public class SqlNullableDateTime <: SqlNullableDbType {
    private var dateTime: ?DateTime
    public init(dateTime: ?DateTime) {
        this.dateTime = dateTime
    }
    public mut prop value: ?DateTime {
        get() {
            dateTime
        }
        set(value) {
            dateTime = value
        }
    }
    public prop name: String {
        get() {
            "SqlNullableTimestampWithoutTz"
        }
    }
}