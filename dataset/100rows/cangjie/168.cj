package services.model
public class GetInventoryConfigurationRequest <: BaseBucketRequest {
    public var configurationId = ""
    public func getConfigurationId() {
        if (configurationId.isEmpty()) {
            configurationId = ""
        }
        return configurationId
    }
    public func setConfigurationId(configurationId: String) {
        this.configurationId = configurationId
    }
      public init( bucketName:String,  configurationId:String) {
        super(bucketName)
        this.configurationId = configurationId
    }
}