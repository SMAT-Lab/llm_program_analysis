//3rd_party_lib:phonenumber4cj/build/phonenumber4cj
from std import collection.*
import secodeFuzz.*
from phonenumber4cj import libphonenumber.inter.*
from phonenumber4cj import libphonenumber.data.*
from phonenumber4cj import libphonenumber.*
func call_fuzz(string:String){
    let ph: PhonemetadataNumberFormat = PhonemetadataNumberFormat()
    ph.setNationalPrefixFormattingRule(string)
    return
}
func unboundTest():Unit{
    var case_name=CString("Fuzz_ph.setNationalPrefixFormattingRule")
    unsafe{
        DT_FUZZ_String(0,30000000,case_name,0,call_fuzz)
        case_name.free()
    }
}
main(){
    unboundTest()
    return
}