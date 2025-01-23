package opds_cj.path

import net.http.*
import opds_cj.router.PathMap
import opds_cj.path.{api,opds}

public func pathLoad(): PathMap {
    var pathMap = PathMap()

    pathMap.merge(api.pathLoad())
    pathMap.merge(opds.pathLoad())

    return pathMap
}
