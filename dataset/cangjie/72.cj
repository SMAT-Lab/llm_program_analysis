package opds_cj.path.opds.v2

import net.http.*
import opds_cj.router.PathMap
import opds_cj.path.opds.v2.{catalog,libraries,series,search}

public func pathLoad(): PathMap {
    var pathMap = PathMap()

    pathMap.merge(catalog.pathLoad())
    pathMap.merge(libraries.pathLoad())
    pathMap.merge(series.pathLoad())
    pathMap.merge(search.pathLoad())
    return pathMap
}
