package services.model
public class ListPartsRequest <: BaseObjectRequest {
    private var uploadId = ""
    private var maxParts = 0
    private var partNumberMarker = 0
    private var encodingType = ""
    public init() {
    }
    public ListPartsRequest(bucketName: String, objectKey: String) {
        this.bucketName = bucketName
        this.objectKey = objectKey
    }
    public init(bucketName: String, objectKey: String, uploadId: String) {
        this.bucketName = bucketName
        this.objectKey = objectKey
        this.uploadId = uploadId
    }
    public init(bucketName: String, objectKey: String, uploadId: String, maxParts: Int64) {
        this.bucketName = bucketName
        this.objectKey = objectKey
        this.uploadId = uploadId
        this.maxParts = maxParts
    }
    public func getUploadId() {
        return uploadId
    }
    public func setUploadId(uploadId: String) {
        this.uploadId = uploadId
    }
    public func getMaxParts() {
        return maxParts
    }
    public func setMaxParts(maxParts: Int64) {
        this.maxParts = maxParts
    }
    public func getPartNumberMarker() {
        return partNumberMarker
    }
    public func setPartNumberMarker(partNumberMarker: Int64) {
        this.partNumberMarker = partNumberMarker
    }
    public func setEncodingType(encodingType: String) {
        this.encodingType = encodingType
    }
    public func getEncodingType() {
        return encodingType
    }
}