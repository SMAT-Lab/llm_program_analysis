package opds_cj.path.api.v1

import net.http.*
import opds_cj.router.PathMap
import opds_cj.path.api.v1.books

public func pathLoad(): PathMap {
    var pathMap = PathMap()

    pathMap.merge(books.pathLoad())
    return pathMap
}
