package opds_cj

import net.http.ServerBuilder
// import std.log.*
import opds_cj.router.NaiveDistributor
import opds_cj.path.pathLoad
// import opds_cj.macros.*

// @include("./lib/sqlite/sqlite3.h")

main() {
    let router = NaiveDistributor()

    for ((k, v) in pathLoad().paths) {
        router.register(k, v)
        println("registered ${k}")
    }

    let server = ServerBuilder().addr("0.0.0.0").port(8080).distributor(router).build()

    println("run at http://127.0.0.1:8080")
    // server.logger.level = DEBUG
    server.serve()
}
