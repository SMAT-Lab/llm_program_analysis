// EXEC: cjc %import-path %L %l %f
// EXEC: export CJSTACKSIZE=10mb && ./main
from std import collection.*
from phonenumber4cj import libphonenumber.inter.*
from phonenumber4cj import libphonenumber.data.*
from phonenumber4cj import libphonenumber.*
main() {
    var phoneUtil: PhoneNumberUtil = PhoneNumberUtil.getInstance().getOrThrow()
    var zipPreceding: String = "cangjie1hhhhhhh,18717619089"
    var iterator: Iterator<PhoneNumberMatch> = phoneUtil.findNumbers(zipPreceding, "US").iterator()
    while (true) {
        match (iterator.next()) {
            case Some(v) =>
                var number1 = v.getNumber()
                println(number1.getNationalNumbers())
                break
            case None => println("None...")
                break
        }
    }
    return 0
}