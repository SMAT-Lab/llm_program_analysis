package s3client.action
public class PolicyStatus <: ToString {
    public PolicyStatus(public let isPublic!: Bool) {
    }
    public func toString(): String {
        return "PolicyStatus(isPublic=${isPublic})"
    }
}
// -----
//
// -----
extend PolicyStatus <: S3XmlObject<PolicyStatus> {
    public static prop ELE_NAME: String {
        get() {
            "PolicyStatus"
        }
    }
    public func toXml(_: String, _: Bool): String {
        throw UnsupportedException("")
    }
    public static func fromXml(ele: S3XmlElement): PolicyStatus {
        return PolicyStatus(isPublic: ele.childContentRequired("IsPublic").toBool())
    }
}