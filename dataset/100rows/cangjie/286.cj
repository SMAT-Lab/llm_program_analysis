package s3client.core
public class S3ConfigKeys {
    private static let NAMESPACE = "S3"
    public static let CREDENTIALS = S3ConfigKey<S3Credentials>(
        NAMESPACE,
        "Credentials",
        {v => v as S3Credentials}
    )
    public static let HTTP_CLIENT = S3ConfigKey<S3HttpClient>(
        NAMESPACE,
        "HttpClient",
        {v => v as S3HttpClient}
    )
    public static let SIGNER = S3ConfigKey<S3Signer>(
        NAMESPACE,
        "Signer",
        {v => v as S3Signer}
    )
    public static let REGION = S3ConfigKey<S3Region>(
        NAMESPACE,
        "Region",
        {v => v as S3Region}
    )
    public static let ENDPOINT = S3ConfigKey<String>.stringType(
        NAMESPACE,
        "Endpoint"
    )
    public static let FORCE_PATH_STYLE = S3ConfigKey<Bool>.boolType(
        NAMESPACE,
        "ForcePathStyle"
    )
    public static let METRIC_PUBLISHERS = S3ConfigKey<ArrayList<S3MetricPublisher>>(
        NAMESPACE,
        "MetricPublishers",
        {v => v as ArrayList<S3MetricPublisher>}
    )
    public static let RETRYER = S3ConfigKey<S3Retryer<S3HttpResponse>>(
        NAMESPACE,
        "Retryer",
        {v => v as S3Retryer<S3HttpResponse>}
    )
    public static let LOGGING_ERROR_RESPONSE = S3ConfigKey<Bool>.boolType(
        NAMESPACE,
        "LoggingErrorResponse"
    )
    public static let TRAILING_CHECKSUM = S3ConfigKey<Bool>.boolType(
        NAMESPACE,
        "TrailingChecksum"
    )
}