import cradle.*
from std import time.*
from std import collection.*
from std import io.*
@Cradle[console|logfile]
func addUser(userName: String) {
    println(userName)
}
@Cradle[console]
func removeUser(userId: Int64): Int64 {
    println(userId)
    return userId
}
@Cradle
func login(userName: String, password: String) {
    println(userName + " login")
}
main() {
    addUser("小华")
    removeUser(100)
    login("小华", "qD@0532")
}