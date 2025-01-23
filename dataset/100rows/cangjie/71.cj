package opds_cj.path.opds

import net.http.*
import opds_cj.router.PathMap
import opds_cj.path.opds.v2

public func pathLoad(): PathMap {
    var pathMap = PathMap()

    pathMap.merge(v2.pathLoad())
    return pathMap
}
