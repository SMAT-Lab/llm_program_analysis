package opds_cj.path.opds.v2.catalog

import net.http.*
import opds_cj.router.PathMap
import opds_cj.path.opds.v2.libraries

public func pathLoad(): PathMap {
    var pathMap = PathMap(
        "/opds/v2/catalog",
        {
            httpContext =>
            let host = httpContext.request.headers.get("host").toArray()[0]
            var cataLog = libraries.CataLog(host:host)
            httpContext.responseBuilder.header("content-type", "application/json;charset:utf-8;")
            httpContext.responseBuilder.body(cataLog.toJson())
        }
    )
    
    return pathMap
}
