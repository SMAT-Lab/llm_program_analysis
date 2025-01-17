// DEPENDENCE: ./build.sh
 EXEC: bash build.sh %import-path %L %l ffi-typecast.o
from std import collection.*
from std import io.*
main() {
    var map: MapField<Int64, String> = MapField<Int64, String>()
    map.put(10, "10")
    map.put(20, "20")
    let num: Int64 = map.capacity()
    if(num <= 0) {
        println(-1)
        return -1
    }
    return 0
}