package opds_cj.router

import net.http.*
import std.collection.HashMap

public class NaiveDistributor <: HttpRequestDistributor {
    let routerMap = HashMap<String, HttpRequestHandler>()
    public func register(path: String, handler: HttpRequestHandler): Unit {
        routerMap.put(path, handler)
    }

    public func distribute(path: String): HttpRequestHandler {
        if (routerMap.contains(path)) {
            return routerMap[path]
        }
        for ((routerPath, handler) in routerMap) {
            var fail = false
            var partPath = path.trimEnd("/").split("/")
            var partRouterPath = routerPath.trimEnd("/").split("/")
            if (partPath.size != partRouterPath.size) {
                continue
            }
            for (i in 0..partPath.size) {
                if (partRouterPath[i].startsWith(":")) {
                    continue
                }
                if (partPath[i] != partRouterPath[i]) {
                    fail = true
                    break
                }
            }
            if (!fail) {
                return handler
            }
        }
        return NotFoundHandler()
    }
}

class NotFoundHandler <: HttpRequestHandler {
    public func handle(httpContext: HttpContext): Unit {
        httpContext.responseBuilder.status(404).body("404 Not Found".toArray())
    }
}

public struct PathMap {
    public var paths = HashMap<String, (HttpContext) -> Unit>()

    public init() {
    }
    
    public init(path: String, handler: (HttpContext) -> Unit) {
        this.paths.put(path, handler)
    }

    public func add(path: String, handler: (HttpContext) -> Unit): Unit {
        this.paths.put(path, handler)
    }

    public func merge(addPathMap: PathMap): Unit {
        this.paths.putAll(addPathMap.paths)
    }
}