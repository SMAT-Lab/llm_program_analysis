package redis_sdk.client.api
public enum SentinelKeyWord <: ProtocolKeyword {
    | MYID
    | MASTERS
    | MASTER
    | SENTINELS
    | SLAVES
    | REPLICAS
    | RESET
    | FAILOVER
    | REMOVE
    | SET
    | MONITOR
    | GET_MASTER_ADDR_BY_NAME
    public func getBytes(): Array<Byte> {
        return name().toArray()
    }
    public func name(): String {
        match (this) {
            case MYID => "MYID"
            case MASTERS => "MASTERS"
            case MASTER => "MASTER"
            case SENTINELS => "SENTINELS"
            case SLAVES => "SLAVES"
            case REPLICAS => "REPLICAS"
            case RESET => "RESET"
            case FAILOVER => "FAILOVER"
            case REMOVE => "REMOVE"
            case SET => "SET"
            case MONITOR => "MONITOR"
            // 中划线
            case GET_MASTER_ADDR_BY_NAME => "GET-MASTER-ADDR-BY-NAME"
        }
    }
}