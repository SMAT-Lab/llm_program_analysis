// DEPENDENCE: ./build.sh
 EXEC: bash build.sh %import-path %L %l ffi-typecast.o
from std import collection.*
from std import io.*
main() {
    var e: RequiredFieldNotSetException = RequiredFieldNotSetException("ceshi")
    let str: String = e.message
    if(str.isEmpty()) {
        println(-1)
        return -1
    }
    return 0
}