package services.requestHandler
import logger.*
from crypto import crypto.*
from crypto import digest.*
from std import crypto.digest.*
from std import io.*
from encoding import hex.*
from encoding import base64.*
from std import time.*
public class RequestConvertor <: AbstractRequestConvertor {
     static let LOGGER = SdkLoggerFactory.getLogger("RequestConvertor")
    public func transSetObjectMetadataRequest(request: SetObjectMetadataRequest): Map<String, String> {
        var headers: Map<String, String> = HashMap<String, String>()
        for ((k, v) in request.getAllUserMetadata()) {
            var key = k
            if (key == "") {
                continue
            }
            key = key.trimAscii()
            headers.put(key, v)
        }
        if (request.getObjectStorageClass().isSome()) {
            putHeader(
                headers,
                Constants.V2_HEADER_PREFIX + "storage-class",
                StorageClassEnum.getName(request.getObjectStorageClass().getOrThrow())
            )
        }
        if (request.getWebSiteRedirectLocation() != "") {
            putHeader(
                headers,
                Constants.V2_HEADER_PREFIX + "website-redirect-location",
                request.getWebSiteRedirectLocation()
            )
        }
        if (request.getContentDisposition() != "") {
            putHeader(headers, CommonHeaders.CONTENT_DISPOSITION, request.getContentDisposition())
        }
        if (request.getContentEncoding() != "") {
            putHeader(headers, CommonHeaders.CONTENT_ENCODING, request.getContentEncoding())
        }
        if (request.getContentLanguage() != "") {
            putHeader(headers, CommonHeaders.CONTENT_LANGUAGE, request.getContentLanguage())
        }
        if (request.getContentType() != "") {
            putHeader(headers, CommonHeaders.CONTENT_TYPE, request.getContentType())
        }
        if (request.getCacheControl() != "") {
            putHeader(headers, CommonHeaders.CACHE_CONTROL, request.getCacheControl())
        }
        if (request.getExpires() != "") {
            putHeader(headers, CommonHeaders.EXPIRES, request.getExpires())
        }
        if (request.getIsRequesterPays()) {
            putHeader(headers, Constants.V2_HEADER_PREFIX + "request-payer", "requester")
        }
        if (request.isRemoveUnset()) {
            putHeader(
                headers,
                Constants.OBS_HEADER_PREFIX + "metadata-directive",
                Constants.DERECTIVE_REPLACE
            )
        } else {
            putHeader(
                headers,
                Constants.OBS_HEADER_PREFIX + "metadata-directive",
                Constants.DERECTIVE_REPLACE_NEW
            )
        }
        return headers
    }
    public func transListVersionsRequest(
        request: ListVersionsRequest,
        requestParams: Map<String, String>,
        requestHeaders: Map<String, String>
    ) {
        var params = HashMap<String, String>()
        params.put("versions", "")
        if (!request.getPrefix().isEmpty()) {
            params.put(ObsRequestParams.PREFIX, request.getPrefix())
        }
        if (!request.getDelimiter().isEmpty()) {
            params.put(ObsRequestParams.DELIMITER, request.getDelimiter())
        }
        if (request.getMaxKeys() > 0) {
            params.put(ObsRequestParams.MAX_KEYS, request.getMaxKeys().toString())
        }
        if (!request.getKeyMarker().isEmpty()) {
            params.put(ObsRequestParams.KEY_MARKER, request.getKeyMarker())
        }
        if (!request.getVersionIdMarker().isEmpty()) {
            params.put(ObsRequestParams.VERSION_ID_MARKER, request.getVersionIdMarker())
        }
        if (!request.getEncodingType().isEmpty()) {
            params.put(ObsRequestParams.ENCODING_TYPE, request.getEncodingType())
        }
        var headers = HashMap<String, String>()
        if (request.getListTimeout() > 0) {
            headers.put("x-obs-list-timeout", request.getListTimeout().toString())
        }
        requestParams.putAll(params)
        requestHeaders.putAll(headers)
    }
    public func transCopyObjectRequest(request: CopyObjectRequest): HashMap<String, String> {
        var headers = HashMap<String, String>()
        var objectMetadata = ObjectMetadata()
        if (request.getNewObjectMetadata().isSome()) {
            objectMetadata = request.getNewObjectMetadata().getOrThrow()
        }
        if (request.isReplaceMetadata()) {
            headers.put("x-obs-metadata-directive", Constants.DERECTIVE_REPLACE)
        } else {
            headers.put("x-obs-metadata-directive", Constants.DERECTIVE_COPY)
        }
        if (request.isReplaceMetadata()) {
            objectMetadata.getAllMetadata().remove(Constants.OBS_HEADER_PREFIX + "request-id")
            objectMetadata.getAllMetadata().remove(Constants.OBS_HEADER_PREFIX + "id-2")
            for ((k, v) in objectMetadata.getAllMetadata()) {
                var key: String = k
                if (key.isEmpty()) {
                    continue
                }
                key = key.trimAscii()
                if (Constants.ALLOWED_REQUEST_HTTP_HEADER_METADATA_NAMES.contains(key.toAsciiLower())) {
                    continue
                }
                var value = v as String
                if (value.isNone()) {
                    headers.put(key, "")
                } else {
                    headers.put(key, value.getOrThrow())
                }
            }
        }
        setBaseHeaderFromMetadata(request.getBucketName(), headers, objectMetadata)
        if (objectMetadata.getObjectStorageClass().isSome()) {
            putHeader(
                headers,
                "x-obs-storage-class",
                StorageClassEnum.getName(objectMetadata.getObjectStorageClass().getOrThrow())
            )
        }
        if (!objectMetadata.getWebSiteRedirectLocation().isEmpty()) {
            putHeader(headers, "x-obs-website-redirect-location", objectMetadata.getWebSiteRedirectLocation())
        }
        if (!request.getSuccessRedirectLocation().isEmpty()) {
            putHeader(headers, "success-action-redirect", request.getSuccessRedirectLocation())
        }
        this.transExtensionPermissions(request, headers)
        this.transSseHeaders(request, headers)
        transSseCSourceHeaders(request.getSseCHeaderSource(), headers)
        transConditionCopyHeaders(request, headers)
        var sourceKey: String = RestUtils.encodeUrlString(request.getSourceBucketName()) + "/" +
            RestUtils.encodeUrlString(request.getSourceObjectKey())
        if (!request.getVersionId().isEmpty()) {
            sourceKey += "?versionId=" + request.getVersionId().trimAscii()
        }
        headers.put("x-obs-copy-source", sourceKey)
        return headers
    }
    public func transConditionCopyHeaders(request: CopyObjectRequest, headers: Map<String, String>) {
        if (request.getIfModifiedSince().isSome()) {
            putHeader(
                headers,
                Constants.OBS_HEADER_PREFIX + "copy-source-if-modified-since",
                ServiceUtils.formatRfc822Date(request.getIfModifiedSince().getOrThrow())
            )
        }
        if (request.getIfUnmodifiedSince().isSome()) {
            putHeader(
                headers,
                Constants.OBS_HEADER_PREFIX + "copy-source-if-unmodified-since",
                ServiceUtils.formatRfc822Date(request.getIfUnmodifiedSince().getOrThrow())
            )
        }
        if (!request.getIfMatchTag().isEmpty()) {
            putHeader(headers, Constants.OBS_HEADER_PREFIX + "copy-source-if-match", request.getIfMatchTag().trimAscii()
            )
        }
        if (!request.getIfNoneMatchTag().isEmpty()) {
            putHeader(
                headers,
                Constants.OBS_HEADER_PREFIX + "copy-source-if-none-match",
                request.getIfNoneMatchTag().trimAscii()
            )
        }
    }
    public func transConditionGetObjectHeaders(request: GetObjectRequest, headers: Map<String, String>) {
        if (request.getIfModifiedSince().isSome()) {
            headers.put(CommonHeaders.IF_MODIFIED_SINCE,
                ServiceUtils.formatRfc822Date(request.getIfModifiedSince().getOrThrow()))
        }
        if (request.getIfUnmodifiedSince().isSome()) {
            headers.put(CommonHeaders.IF_UNMODIFIED_SINCE,
                ServiceUtils.formatRfc822Date(request.getIfUnmodifiedSince().getOrThrow()))
        }
        if (!request.getIfMatchTag().isEmpty()) {
            headers.put(CommonHeaders.IF_MATCH, request.getIfMatchTag().trimAscii())
        }
        if (!request.getIfNoneMatchTag().isEmpty()) {
            headers.put(CommonHeaders.IF_NONE_MATCH, request.getIfNoneMatchTag().trimAscii())
        }
        if (!request.isAutoUnzipResponse()) {
            headers.put(CommonHeaders.ACCETP_ENCODING, "identity")
        }
    }
    public func transSseCSourceHeaders(sseCHeader: Option<SseCHeader>, headers: Map<String, String>) {
        if (sseCHeader.isSome()) {
            var algorithm: String = SSEAlgorithmEnum.getName(sseCHeader.getOrThrow().getSSEAlgorithm())
            putHeader(
                headers,
                Constants.OBS_HEADER_PREFIX + "copy-source-server-side-encryption-customer-algorithm",
                algorithm
            )
            if (!sseCHeader.getOrThrow().getSseCKeyBase64().isEmpty()) {
                try {
                    putHeader(
                        headers,
                        Constants.OBS_HEADER_PREFIX + "copy-source-server-side-encryption-customer-key",
                        sseCHeader.getOrThrow().getSseCKeyBase64()
                    )
                    var md5Instance = MD5()
                    var md: Array<Byte> = digest(
                        md5Instance,
                        fromBase64String(sseCHeader.getOrThrow().getSseCKeyBase64()).getOrThrow()
                    )
                    putHeader(
                        headers,
                        Constants.OBS_HEADER_PREFIX + "copy-source-server-side-encryption-customer-key-MD5",
                        toBase64String(md)
                    )
                } catch (e: IOException) {
                    throw IllegalStateException("fail to read sseCkey")
                } catch (e: IllegalStateException) {
                    throw IllegalStateException("fail to read sseCkey")
                }
            } else if (sseCHeader.getOrThrow().getSseCKey().size > 0) {
                try {
                    var data: Array<Byte> = sseCHeader.getOrThrow().getSseCKey()
                    putHeader(
                        headers,
                        Constants.OBS_HEADER_PREFIX + "copy-source-server-side-encryption-customer-key",
                        toBase64String(data)
                    )
                    var md5Instance = MD5()
                    putHeader(
                        headers,
                        Constants.OBS_HEADER_PREFIX + "copy-source-server-side-encryption-customer-key-MD5",
                        toBase64String(digest(md5Instance, data))
                    )
                } catch (e: IOException) {
                    throw IllegalStateException("fail to read sseCkey")
                } catch (e: IllegalStateException) {
                    throw IllegalStateException("fail to read sseCkey")
                }
            }
        }
    }
    public func transExtensionPermissions(request: PutObjectBasicRequest, headers: Map<String, String>) {
        var extensionPermissionEnums: HashSet<String> = request.getAllGrantPermissions()
        if (!extensionPermissionEnums.isEmpty()) {
            for (extensionPermissionEnum in extensionPermissionEnums) {
                var domainIds: Set<String> = request.getDomainIdsByGrantPermission(
                    ExtensionObjectPermissionEnum.getCode(extensionPermissionEnum).getOrThrow())
                var domainIdList: ArrayList<String> = ArrayList<String>(domainIds.size)
                for (domainId in domainIds) {
                    domainIdList.append("id=" + domainId)
                }
                putHeader(
                    headers,
                    getHeaderByMethodName(extensionPermissionEnum),
                    ServiceUtils.strJoin(domainIdList, ",")
                )
            }
        }
    }
    public func getHeaderByMethodName(code: String): String {
        match (code) {
            case "grantReadHeader" => return Constants.OBS_HEADER_PREFIX + "grant-read"
            case "grantReadAcpHeader" => return Constants.OBS_HEADER_PREFIX + "grant-read-acp"
            case "grantWriteAcpHeader" => return Constants.OBS_HEADER_PREFIX + "grant-write-acp"
            case "grantFullControlHeader" => return Constants.OBS_HEADER_PREFIX + "grant-full-control"
            case _ => return ""
        }
    }
    public func transSseHeaders(request: PutObjectBasicRequest, headers: Map<String, String>) {
        if (request.getSseCHeader().isSome()) {
            this.transSseCHeaders(request.getSseCHeader(), headers)
        } else if (request.getSseKmsHeader().isSome()) {
            this.transSseKmsHeaders(request.getSseKmsHeader(), headers, request.getBucketName())
        }
    }
    public func transSseKmsHeaders(kmsHeader: Option<SseKmsHeader>, headers: Map<String, String>, bucketName: String) {
        LOGGER.info(bucketName)
        var seek = SseKmsHeader()
        seek.getKmsKeyId()
        seek.getProjectId()
        seek.getSSEAlgorithm()
        seek.setKmsKeyId("")
        seek.setProjectId("")
        if (kmsHeader.isNone()) {
            return
        }
        var sseKmsEncryption: String = SSEAlgorithmEnum.getName(kmsHeader.getOrThrow().getSSEAlgorithm())
        putHeader(headers, Constants.OBS_HEADER_PREFIX + "server-side-encryption", sseKmsEncryption)
        if (!kmsHeader.getOrThrow().getKmsKeyId().isEmpty()) {
            putHeader(
                headers,
                Constants.OBS_HEADER_PREFIX + "server-side-encryption-kms-key-id",
                kmsHeader.getOrThrow().getKmsKeyId()
            )
        }
        if (!kmsHeader.getOrThrow().getProjectId().isEmpty()) {
            putHeader(
                headers,
                Constants.OBS_HEADER_PREFIX + "sse-kms-key-project-id",
                kmsHeader.getOrThrow().getProjectId()
            )
        }
    }
    public func transSseCHeaders(ssecHeader: Option<SseCHeader>, headers: Map<String, String>): Unit {
        if (ssecHeader.isNone()) {
            return
        }
        var sseCAlgorithm: String = SSEAlgorithmEnum.getName(ssecHeader.getOrThrow().getSSEAlgorithm())
        putHeader(headers, Constants.OBS_HEADER_PREFIX + "server-side-encryption-customer-algorithm", sseCAlgorithm)
        if (!ssecHeader.getOrThrow().getSseCKeyBase64().isEmpty()) {
            try {
                putHeader(
                    headers,
                    Constants.OBS_HEADER_PREFIX + "server-side-encryption-customer-key",
                    ssecHeader.getOrThrow().getSseCKeyBase64()
                )
                var md5Instance = MD5()
                var md: Array<Byte> = digest(
                    md5Instance,
                    fromBase64String(ssecHeader.getOrThrow().getSseCKeyBase64()).getOrThrow()
                )
                putHeader(
                    headers,
                    Constants.OBS_HEADER_PREFIX + "server-side-encryption-customer-key-MD5",
                    toBase64String(md)
                )
            } catch (e: IOException) {
                throw IllegalStateException("fail to read sseCkey")
            }
        } else if (ssecHeader.getOrThrow().getSseCKey().size > 0) {
            try {
                var data: Array<UInt8> = ssecHeader.getOrThrow().getSseCKey()
                putHeader(
                    headers,
                    Constants.OBS_HEADER_PREFIX + "server-side-encryption-customer-key",
                    toBase64String(data)
                )
                var md5Instance = MD5()
                putHeader(
                    headers,
                    Constants.OBS_HEADER_PREFIX + "server-side-encryption-customer-key-MD5",
                    toBase64String(digest(md5Instance, data))
                )
            } catch (e: IOException) {
                throw IllegalStateException("fail to read sseCkey")
            }
        }
    }
    private func setBaseHeaderFromMetadata(
        bucketName: String,
        headers: HashMap<String, String>,
        objectMetadata: ObjectMetadata
    ) {
        LOGGER.info(bucketName)
        selectAllowedHeader(headers, objectMetadata)
        if (!objectMetadata.getContentMd5().isEmpty()) {
            headers.put(CommonHeaders.CONTENT_MD5, objectMetadata.getContentMd5().trimAscii())
        }
        if (!objectMetadata.getContentEncoding().isEmpty()) {
            headers.put(CommonHeaders.CONTENT_ENCODING, objectMetadata.getContentEncoding().trimAscii())
        }
        if (!objectMetadata.getContentDisposition().isEmpty()) {
            headers.put(CommonHeaders.CONTENT_DISPOSITION, objectMetadata.getContentDisposition().trimAscii())
        }
        if (!objectMetadata.getCacheControl().isEmpty()) {
            headers.put(CommonHeaders.CACHE_CONTROL, objectMetadata.getCacheControl().trimAscii())
        }
        if (!objectMetadata.getContentLanguage().isEmpty()) {
            headers.put(CommonHeaders.CONTENT_LANGUAGE, objectMetadata.getContentLanguage().trimAscii())
        }
        if (!objectMetadata.getExpires().isEmpty()) {
            headers.put(CommonHeaders.EXPIRES, objectMetadata.getExpires().trimAscii())
        }
        if (!objectMetadata.getCrc64().isEmpty()) {
            headers.put("x-obs-hash-crc64ecma", objectMetadata.getCrc64().trimAscii())
        }
        if (objectMetadata.getObjectStorageClass().isSome()) {
            putHeader(
                headers,
                "x-obs-storage-class",
                StorageClassEnum.getName(objectMetadata.getObjectStorageClass().getOrThrow())
            )
        }
        if (!objectMetadata.getWebSiteRedirectLocation().isEmpty()) {
            putHeader(headers, "x-obs-website-redirect-location", objectMetadata.getWebSiteRedirectLocation())
        }
    }
    private func selectAllowedHeader(headers: HashMap<String, String>, objectMetadata: ObjectMetadata) {
        for ((k, v) in objectMetadata.getAllMetadata()) {
            var key = k
            if (k.isEmpty()) {
                continue
            }
            key = key.trimAscii()
            if ((CAN_USE_STANDARD_HTTP_HEADERS.get().isNone() || (CAN_USE_STANDARD_HTTP_HEADERS.get().isSome() &&
                !CAN_USE_STANDARD_HTTP_HEADERS.get().getOrThrow())) &&
                Constants.ALLOWED_REQUEST_HTTP_HEADER_METADATA_NAMES.contains(key.toAsciiLower())) {
                continue
            }
            headers.put(key, (v as String).getOrThrow())
        }
    }
    public func transCreateBucketRequest(request: CreateBucketRequest): HashMap<String, String> {
        var headers: HashMap<String, String> = HashMap<String, String>()
        if (request.getBucketStorageClass().isSome()) {
            putHeader(
                headers,
                "x-obs-storage-class",
                AbstractAuthentication.transStorageClass(request.getBucketStorageClass().getOrThrow())
            )
        }
        if (!request.getEpid().isEmpty()) {
            putHeader(headers, Constants.OBS_HEADER_PREFIX + "epid", request.getEpid())
        }
        if (BucketTypeEnum.getName(BucketTypeEnum.PFS) == BucketTypeEnum.getName(request.getBucketType())) {
            putHeader(headers, Constants.OBS_HEADER_PREFIX + "fs-file-interface", Constants.ENABLED)
        }
        if (request.getAvailableZone().isSome()) {
            putHeader(
                headers,
                Constants.OBS_HEADER_PREFIX + "az-redundancy",
                AvailableZoneEnum.getName(request.getAvailableZone().getOrThrow())
            )
        }
        var extensionPermissionEnums: Set<String> = request.getAllGrantPermissions()
        if (!extensionPermissionEnums.isEmpty()) {
            for (extensionPermissionEnum in extensionPermissionEnums) {
                var domainIds: Set<String> = request.getDomainIdsByGrantPermission(
                    ExtensionBucketPermissionEnum.getCode(extensionPermissionEnum).getOrThrow()).getOrThrow()
                var domainIdList: ArrayList<String> = ArrayList<String>()
                for (domainId in domainIds) {
                    domainIdList.append("id=" + domainId)
                }
                putHeader(
                    headers,
                    getHeaderByMethodName(extensionPermissionEnum),
                    ServiceUtils.strJoin(domainIdList, ",")
                )
            }
        }
        if (request.getExtensionHeaderMap().isSome()) {
            for ((k, v) in request.getExtensionHeaderMap().getOrThrow()) {
                putHeader(headers, k, v)
            }
        }
        var headerPrefix: String = Constants.OBS_HEADER_PREFIX
        if (RedundancyTypeEnum.getName(request.getBucketRedundancy()) == RedundancyTypeEnum.getName(
            RedundancyTypeEnum.FUSION)) {
            putHeader(
                headers,
                headerPrefix + CommonHeaders.BUCKET_REDUNDANCY,
                RedundancyTypeEnum.getName(RedundancyTypeEnum.FUSION)
            )
        }
        if (ActionEnum.getName(request.getFusionAllowUpgrade()) != ActionEnum.getName(ActionEnum.DEFAULT)) {
            putHeader(
                headers,
                headerPrefix + CommonHeaders.FUSION_ALLOW_UPGRADE,
                ActionEnum.getName(ActionEnum.DEFAULT)
            )
        }
        if (ActionEnum.getName(request.getFusionAllowAlternative()) != ActionEnum.getName(ActionEnum.DEFAULT)) {
            putHeader(
                headers,
                headerPrefix + CommonHeaders.FUSION_ALLOW_ALTERNATIVE,
                ActionEnum.getName(ActionEnum.DEFAULT)
            )
        }
        var contentType: String = Mimetypes.MIMETYPE_XML
        headers.put(CommonHeaders.CONTENT_TYPE, contentType)
        return headers
    }
    public func transPutObjectRequest(request: PutObjectRequest, headers: HashMap<String, String>): ObjectMetadata {
        var objectMetadata = Option<ObjectMetadata>.None
        if (request.getMetadata().isNone()) {
            objectMetadata = ObjectMetadata()
        } else {
            objectMetadata = request.getMetadata()
        }
        setBaseHeaderFromMetadata(request.getBucketName(), headers, objectMetadata.getOrThrow())
        if (request.getExpires() >= 0) {
            putHeader(headers, "x-obs-expires", request.getExpires().toString())
        }
        if (!request.getSuccessRedirectLocation().isEmpty()) {
            putHeader(headers, "success-action-redirect", request.getSuccessRedirectLocation())
        }
        transExtensionPermissions(request, headers)
        transSseHeaders(request, headers)
        return objectMetadata.getOrThrow()
    }
    public func transModifyObjectRequest(
        request: ModifyObjectRequest,
        headers: HashMap<String, String>,
        akcj: Option<String>,
        skcj: Option<String>,
        endpointcj: Option<String>
    ): ModifyObjectResult {
        var objectMetadata = transPutObjectRequest(request, headers)
        //创建 Request 的Builder
        let requestbuilder: RequestBuilder = Request.builder()
        var hostName = ObsUtil.getHostName(
            request.getBucketName(),
            false,
            ObsUtil.changeFromObsConfiguration(endpointcj.getOrThrow())
        )
        var url = ObsUtil.addProtocol(hostName, true, "/" + request.getObjectKey())
        var body = RealRequestBody.create(Option<MediaType>.None, "")
        var contentType: String = ""
        if (objectMetadata.getContentType().isEmpty() &&
            (objectMetadata.getValue(CommonHeaders.CONTENT_TYPE) as String).isSome()) {
            contentType = (objectMetadata.getValue(CommonHeaders.CONTENT_TYPE) as String).getOrThrow()
        } else {
            contentType = objectMetadata.getContentType()
        }
        if (contentType.isEmpty()) {
            contentType = Mimetypes().getMimetype(request.getObjectKey()).getOrThrow()
        }
        //查看文件是否有值
        if (request.getFile().isSome()) {
            var fileinfo = request.getFile().getOrThrow().info
            var fileName = fileinfo.path.fileName
            contentType = Mimetypes().getMimetype(fileName.getOrThrow()).getOrThrow()
            body = RealRequestBody.create(MediaType.get(contentType), request.getFile().getOrThrow())
        } else if (request.getInput().isSome()) {
            var input = request.getInput().getOrThrow()
            var byte = Array<Byte>(4096, item: 0)
            let stream = ByteArrayStream()
            try {
                var rendNum = 0
                var isRead = true
                //首次读取
                var readFlag = false
                var progressManager = Option<ProgressManager>.None
                var progressInterval = 100 * 1024
                if (request.getProgressInterval() > 0) {
                    progressInterval = request.getProgressInterval()
                }
                while (isRead) {
                    rendNum = input.read(byte)
                    if (rendNum > 0) {
                        stream.write(byte.slice(0, rendNum))
                        //todo  如果有文件上传监听,进行配置
                        if (request.getProgressListener().isSome()) {
                            progressManager = SimpleProgressManager(
                                0,
                                0,
                                request.getProgressListener().getOrThrow(),
                                progressInterval
                            )
                            if (!readFlag) {
                                readFlag = true
                                progressManager.getOrThrow().progressStart()
                            }
                            progressManager.getOrThrow().progressChanged(rendNum)
                        }
                    } else {
                        isRead = false
                        if (request.getProgressListener().isSome()) {
                            // 文件上传监听   文件读取完成了
                            progressManager.getOrThrow().progressEnd()
                        }
                    }
                }
            } catch (e: EOFException) {}
            body = RealRequestBody.create(MediaType.get(contentType), stream.readToEnd())
        } else {
            //  异常报错    文件和字节流都是空的
            LOGGER.error("文件和字节流都是空的")
        }
        //请求设置url和body
        ObsUtil.createRequestBuilder(body, url, "put", requestbuilder)
        var contentLength = body.getContentLength()
        requestbuilder.header(CommonHeaders.CONTENT_TYPE, contentType)
        headers.put(CommonHeaders.CONTENT_TYPE, contentType)
        requestbuilder.header(CommonHeaders.CONTENT_LENGTH, contentLength.toString())
        headers.put(CommonHeaders.CONTENT_LENGTH, contentLength.toString())
        requestbuilder.header(CommonHeaders.HOST, hostName)
        requestbuilder.header("Date", ObsUtil.getNowTime())
        //todo  等待urlcode可以使用进行替换  String fullUrl = uri.getRawPath()
        var fullUrl = "/" + request.getObjectKey()
        var signUrl = ObsUtil.getfullUrl(fullUrl, hostName, request.getBucketName(), "")
        //签名
        var shaStr = AbstractAuthentication.makeServiceCanonicalString(requestbuilder, "PUT", signUrl)
        requestbuilder.header(
            CommonHeaders.AUTHORIZATION,
            "OBS " + akcj.getOrThrow() + ":" + ObsUtil.getCryptoString(shaStr, skcj.getOrThrow())
        )
        requestbuilder.header(CommonHeaders.USER_AGENT, Constants.USER_AGENT_VALUE)
        let newrequest = requestbuilder.build()
        let call = httpClient.newCall(newrequest)
        let response = call.execute()
        var ret = ModifyObjectResult()
        setHeadersAndStatus(ret, response, false)
        return ret
    }
    public func transAppendObjectRequest(
        request: AppendObjectRequest,
        headers: HashMap<String, String>,
        akcj: Option<String>,
        skcj: Option<String>,
        endpointcj: Option<String>
    ): AppendObjectResult {
        var objectMetadata = transPutObjectRequest(request, headers)
        //创建 Request 的Builder
        let requestbuilder: RequestBuilder = Request.builder()
        var hostName = ObsUtil.getHostName(
            request.getBucketName(),
            false,
            ObsUtil.changeFromObsConfiguration(endpointcj.getOrThrow())
        )
        var url = ObsUtil.addProtocol(hostName, true, "/" + request.getObjectKey())
        var requestParameters: Map<String, String> = HashMap<String, String>()
        requestParameters.put("append", "")
        requestParameters.put("position", request.getPosition().toString())
        url = ObsUtil.addRequestParametersToUrlPath(url, requestParameters, false)
        var body = RealRequestBody.create(Option<MediaType>.None, "")
        var contentType: String = ""
        if (objectMetadata.getContentType().isEmpty() &&
            (objectMetadata.getValue(CommonHeaders.CONTENT_TYPE) as String).isSome()) {
            contentType = (objectMetadata.getValue(CommonHeaders.CONTENT_TYPE) as String).getOrThrow()
        } else {
            contentType = objectMetadata.getContentType()
        }
        if (contentType.isEmpty()) {
            contentType = Mimetypes().getMimetype(request.getObjectKey()).getOrThrow()
        }
        //查看文件是否有值
        if (request.getFile().isSome()) {
            var fileinfo = request.getFile().getOrThrow().info
            var fileName = fileinfo.path.fileName
            contentType = Mimetypes().getMimetype(fileName.getOrThrow()).getOrThrow()
            body = RealRequestBody.create(MediaType.get(contentType), request.getFile().getOrThrow())
        } else if (request.getInput().isSome()) {
            var input = request.getInput().getOrThrow()
            var byte = Array<Byte>(4096, item: 0)
            let stream = ByteArrayStream()
            try {
                var rendNum = 0
                var isRead = true
                //首次读取
                var readFlag = false
                var progressManager = Option<ProgressManager>.None
                var progressInterval = 100 * 1024
                if (request.getProgressInterval() > 0) {
                    progressInterval = request.getProgressInterval()
                }
                while (isRead) {
                    rendNum = input.read(byte)
                    if (rendNum > 0) {
                        stream.write(byte.slice(0, rendNum))
                        //todo  如果有文件上传监听,进行配置
                        if (request.getProgressListener().isSome()) {
                            progressManager = SimpleProgressManager(
                                0,
                                0,
                                request.getProgressListener().getOrThrow(),
                                progressInterval
                            )
                            if (!readFlag) {
                                readFlag = true
                                progressManager.getOrThrow().progressStart()
                            }
                            progressManager.getOrThrow().progressChanged(rendNum)
                        }
                    } else {
                        isRead = false
                        if (request.getProgressListener().isSome()) {
                            // 文件上传监听   文件读取完成了
                            progressManager.getOrThrow().progressEnd()
                        }
                    }
                }
            } catch (e: EOFException) {}
            body = RealRequestBody.create(MediaType.get(contentType), stream.readToEnd())
        } else {
            //  异常报错    文件和字节流都是空的
            LOGGER.error("文件和字节流都是空的")
        }
        //请求设置url和body
        ObsUtil.createRequestBuilder(body, url, "post", requestbuilder)
        var contentLength = body.getContentLength()
        requestbuilder.header(CommonHeaders.CONTENT_TYPE, contentType)
        headers.put(CommonHeaders.CONTENT_TYPE, contentType)
        requestbuilder.header(CommonHeaders.CONTENT_LENGTH, contentLength.toString())
        headers.put(CommonHeaders.CONTENT_LENGTH, contentLength.toString())
        requestbuilder.header(CommonHeaders.HOST, hostName)
        requestbuilder.header("Date", ObsUtil.getNowTime())
        //todo  等待urlcode可以使用进行替换  String fullUrl = uri.getRawPath()
        var urlArray = url.split("?")
        var queryString = urlArray[1]
        var fullUrl = "/" + request.getObjectKey()
        var signUrl = ObsUtil.getfullUrl(fullUrl, hostName, request.getBucketName(), queryString)
        //签名
        var shaStr = AbstractAuthentication.makeServiceCanonicalString(requestbuilder, "POST", signUrl)
        requestbuilder.header(
            CommonHeaders.AUTHORIZATION,
            "OBS " + akcj.getOrThrow() + ":" + ObsUtil.getCryptoString(shaStr, skcj.getOrThrow())
        )
        requestbuilder.header(CommonHeaders.USER_AGENT, Constants.USER_AGENT_VALUE)
        let newrequest = requestbuilder.build()
        let call = httpClient.newCall(newrequest)
        let response = call.execute()
        var responseCode = response.getCode()
        RestUtils.checkResponse(responseCode, response)
        var nextPosition = response.getHeader("x-obs-next-append-position")
        var storageClass = response.getHeader("x-obs-storage-class") ?? ""
        var nextPositionInt = -1
        if (nextPosition.isSome()) {
            nextPositionInt = Int64.parse(nextPosition.getOrThrow())
        }
        var etag = response.getHeader("ETag") ?? ""
        var ret = AppendObjectResult(
            request.getBucketName(),
            request.getObjectKey(),
            etag,
            nextPositionInt,
            StorageClassEnum.getCode(storageClass),
            url
        )
        setHeadersAndStatus(ret, response, false)
        return ret
    }
    public func transInitiateMultipartUploadRequest(
        request: InitiateMultipartUploadRequest,
        params: HashMap<String, String>,
        headers: HashMap<String, String>
    ) {
        var objectMetadata = Option<ObjectMetadata>.None
        if (request.getMetadata().isNone()) {
            objectMetadata = ObjectMetadata()
        } else {
            objectMetadata = request.getMetadata()
        }
        selectAllowedHeader(headers, objectMetadata.getOrThrow())
        if (objectMetadata.getOrThrow().getObjectStorageClass().isSome()) {
            putHeader(
                headers,
                "x-obs-storage-class",
                AbstractAuthentication.transStorageClass(
                    objectMetadata.getOrThrow().getObjectStorageClass().getOrThrow())
            )
        }
        if (!objectMetadata.getOrThrow().getWebSiteRedirectLocation().isEmpty()) {
            putHeader(
                headers,
                "x-obs-website-redirect-location",
                objectMetadata.getOrThrow().getWebSiteRedirectLocation()
            )
        }
        if (!request.getSuccessRedirectLocation().isEmpty()) {
            putHeader(headers, "x-obs-success-action-redirect", request.getSuccessRedirectLocation())
        }
        if (request.getExpires() > 0) {
            putHeader(headers, "x-obs-expires", request.getExpires().toString())
        }
        setBaseHeaderFromMetadata(request.getBucketName(), headers, objectMetadata.getOrThrow())
        transExtensionPermissions(request, headers)
        transSseHeaders(request, headers)
        var contentType = Option<Any>.None
        if (objectMetadata.getOrThrow().getContentType().isEmpty()) {
            contentType = objectMetadata.getOrThrow().getValue(CommonHeaders.CONTENT_TYPE)
        } else {
            contentType = objectMetadata.getOrThrow().getContentType()
        }
        if (contentType.isNone() || (contentType.getOrThrow() as String).isNone()) {
            contentType = Mimetypes().getMimetype(request.getObjectKey()).getOrThrow()
        }
        var contentTypeStr: String = (contentType.getOrThrow() as String).getOrThrow()
        headers.put(CommonHeaders.CONTENT_TYPE, contentTypeStr)
        var ssec = SseCHeader()
        ssec.setSseCKeyBase64("")
        ssec.getSseCKeyBase64()
        var seek = SseKmsHeader()
        seek.setKmsKeyId("")
        seek.setProjectId("")
        seek.getKmsKeyId()
        seek.getProjectId()
        seek.getSSEAlgorithm()
        params.put(SpecialParamEnum.getName(SpecialParamEnum.UPLOADS), "")
        if (!request.getEncodingType().isEmpty()) {
            params.put(ObsRequestParams.ENCODING_TYPE, request.getEncodingType())
        }
    }
    public func transUploadPartRequest(request: UploadPartRequest, params: HashMap<String, String>,
        headers: HashMap<String, String>) {
        params.put(ObsRequestParams.PART_NUMBER, request.getPartNumber().toString())
        params.put(ObsRequestParams.UPLOAD_ID, request.getUploadId())
        if (!request.getContentMd5().isEmpty()) {
            headers.put(CommonHeaders.CONTENT_MD5, request.getContentMd5().trimAscii())
        }
        transSseCHeaders(request.getSseCHeader(), headers)
        var contentLength = -1
        if (request.getFile().isSome()) {
            var fileSize = request.getFile().getOrThrow().length
            var offset = 0
            if (request.getOffset() >= 0 && request.getOffset() < fileSize) {
                offset = request.getOffset()
            }
            var partSize = fileSize - offset
            if (request.getPartSize() != 0 && request.getPartSize() > 0 && request.getPartSize() <= (fileSize - offset)) {
                partSize = request.getPartSize()
            }
            contentLength = partSize
            try {
                //这个数组是给md5加密用的
                var fileByte = request.getFile().getOrThrow().readToEnd()
                //这段已经对文件进行了截取
              request.getFile().getOrThrow().seek(SeekPosition.Begin(offset))
                if (request.isAttachMd5() && request.getContentMd5().isEmpty()) {
                    headers.put(CommonHeaders.CONTENT_MD5,
                        toBase64String(ServiceUtils.computeMD5Hash(fileByte, partSize, offset)))
                }
                //将文件根据截取重新读出来
                let arr = ByteArrayStream()
                var bytearray = Array<Byte>(partSize, item: 0)
                request.getFile().getOrThrow().read(bytearray)
                arr.write(bytearray)
                request.setInput(arr)
            } catch (e: Exception) {
               LOGGER.error(e)
            }
        } else if (request.getInput().isSome()) {
            if (request.getPartSize() != 0 && request.getPartSize() > 0) {
                contentLength = request.getPartSize()
            }
        }
        var contentType: String = Mimetypes().getMimetype(request.getObjectKey()).getOrThrow()
        headers.put(CommonHeaders.CONTENT_TYPE, contentType)
        if (contentLength > -1) {
            putHeader(headers, CommonHeaders.CONTENT_LENGTH, contentLength.toString())
        }
    }
}