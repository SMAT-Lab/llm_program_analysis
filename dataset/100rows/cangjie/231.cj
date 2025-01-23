package entity
public class InterfaceEntity <: TypeEntity {
    public var interfaces = HashMap<String, Int64>()
    public var staticMap = HashMap<String, Int64>()
    public init(id:Int64, name:String) {
        this.id = id
        this.name = name
    }
    public init(id:Int64, name:String, qualifiedName:String, parentId:Int64) {
        this.id = id
        this.name = name
        this.qualifiedName = qualifiedName
        this.parentId = parentId
    }
}