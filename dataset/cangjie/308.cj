package api.resource
import api.resource.enums.*
from std import collection.HashMap
public interface IResource <: Serializable<IResource> {
    func attribute(attribute: Attributes): IResource
    func attribute(key: ResourceAttributes, value: String): IResource
    func attribute(key: String, value: String): IResource
    func getAttributes(): Attributes
    func getSchemaUrl(): String
    open override func serialize(): DataModel {
        return DataModelStruct()
    }
    static func deserialize(dm: DataModel): IResource {
        return Option<IResource>.None.getOrThrow()
    }
    open func toJson(): JsonValue {
        return this.serialize().toJson()
    }
}