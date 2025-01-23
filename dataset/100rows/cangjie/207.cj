 from std import collection.*
func f_gold (s:String):String{
  let l = s.size
  var s1 = ""
  let isEven = if(l % 2 == 0){true}else{false}
  for (i in 0..l:2) {
    if ( isEven ) {
      s1 = Char(s[i]).toString() + s1
      s1 += Char(s[i+1]).toString()
    }
    else {
      if ( l - i > 1 ) {
        s1 += Char(s[i]).toString()
        s1 = Char(s[i+1]).toString() + s1
      }
      else {
        s1 += Char(s[i]).toString()
      }
    }
  }
  return s1
}
//TOFILL
main(){
    var n_success = 0
    let param0 = ArrayList<String>()
    param0.append(" EgvQCeqYpZtv")
    param0.append("488540")
    param0.append("0000101010111")
    param0.append("syw")
    param0.append("402355")
    param0.append("0")
    param0.append("wmHMlAtq")
    param0.append("7962")
    param0.append("111111")
    param0.append("UbgRGDquop")
    let param1 = ArrayList<String>()
    param1.append(" EgvQCeqYpZtv")
    param1.append("488540")
    param1.append("0000101010111")
    param1.append("syw")
    param1.append("402355")
    param1.append("0")
    param1.append("wmHMlAtq")
    param1.append("7962")
    param1.append("111111")
    param1.append("UbgRGDquop")
    for (i in 0..param0.size){
        if (f_gold(param0[i]) == f_filled(param1[i])){
            n_success += 1
        }
    }
    println("#Results: ${n_success}, ${param0.size}\n")
}