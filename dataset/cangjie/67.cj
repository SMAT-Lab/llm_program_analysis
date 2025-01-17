package opds_cj.path.api

import net.http.*
import opds_cj.router.PathMap
import opds_cj.path.api.v1

public func pathLoad(): PathMap {
    var pathMap = PathMap()
    pathMap.merge(v1.pathLoad())
    return pathMap
}
