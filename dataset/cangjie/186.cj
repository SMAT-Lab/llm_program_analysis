 from std import collection.*
func f_gold (str:Array<UInt8>):Bool{
  let len = str.size
  if ( str [ 0 ] < b'A' || str [ 0 ] > b'Z' ) {return false}
  if ( str [ len - 1 ] != b'.' ) {return false}
  var prev_state = 0
  var curr_state = 0
  var index = 1
  while ( index <= str . size ) {
    if ( str [ index ] >= b'A' && str [ index ] <= b'Z' ) {curr_state = 0}
    else if ( str [ index ] == b' ' ) {curr_state = 1}
    else if ( str [ index ] >= b'a' && str [ index ] <= b'z' ) {curr_state = 2}
    else if ( str [ index ] == b'.' ) {curr_state = 3}
    if ( prev_state == curr_state && curr_state != 2 ) {return false}
    if ( prev_state == 2 && curr_state == 0 ) {return false}
    if ( curr_state == 3 && prev_state != 1 ) {return ( index + 1 == str . size )}
    index ++
    prev_state = curr_state
  }
  return false
}
//TOFILL
main(){
    var n_success = 0
    let param0 = ArrayList<String>(["I love cinema.", "The vertex is S.",
                         "I am single.", "My name is KG.",
                         "I lovE cinema.", "GeeksQuiz. is a quiz site.",
    let param1 = ArrayList<String>(["I love cinema.", "The vertex is S.",
                         "I am single.", "My name is KG.",
                         "I lovE cinema.", "GeeksQuiz. is a quiz site.",
                         " You are my friend.", "I love cinema", "Hello world !"])
    let param1 = ArrayList<String>(["I love cinema.", "The vertex is S.",
                         "I am single.", "My name is KG.",
                         "I lovE cinema.", "GeeksQuiz. is a quiz site.",
                         " You are my friend.", "I love cinema", "Hello world !"])
    for (i in 0..param0.size){
        if (f_gold(param0[i].toArray()) == f_filled(param1[i].toArray())){
            n_success += 1
        }
    }
    println("#Results: ${n_success}, ${param0.size}\n")
}