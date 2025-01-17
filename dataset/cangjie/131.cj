 from std import collection.*
func f_gold (seq:String):String{
  let n = seq.size
  if ( n >= 9 ) {return "-1"}
  let result = Array<Char>(n+1,item:' ')
  var count:Int32 = 1
  for(i in 0..n+1){
    if ( i == n || seq[i] == b'I' ) {
      for (j in i-1..-2:-1) {
        result [ j + 1 ] = Char( Int32(b'0') + count)
        count++
        if ( j >= 0 && seq[j] == b'I' ) {break}
      }
    }
  }
  return String(result)
}
//TOFILL
main(){
    var n_success = 0
    let param0 = ArrayList<String>()
    param0.append("D")
    param0.append("I")
    param0.append("DD")
    param0.append("II")
    param0.append("DIDI")
    param0.append("IIDDD")
    param0.append("DDIDDIID")
    param0.append("176297")
    param0.append("1")
    param0.append("XHkhZq")
    let param1 = ArrayList<String>()
    param1.append("D")
    param1.append("I")
    param1.append("DD")
    param1.append("II")
    param1.append("DIDI")
    param1.append("IIDDD")
    param1.append("DDIDDIID")
    param1.append("176297")
    param1.append("1")
    param1.append("XHkhZq")
    for (i in 0..param0.size){
        if (f_gold(param0[i]) == f_filled(param1[i])){
            n_success += 1
        }
    }
    println("#Results: ${n_success}, ${param0.size}\n")
}