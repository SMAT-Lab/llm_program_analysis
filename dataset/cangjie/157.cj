// EXEC: cjc %import-path %L %l %f
// EXEC: ./main
from mp3tag4cj import mp3tag4cj.*
from std import io.*
from std import collection.*
from charset import charset.*
from charset import charset.singlebyte.*
from charset import charset.encoding.*
main() {
    var mp3file:Mp3File=Mp3File("../../../test/LLT/bugfix/testfiles/v1andv24tags.mp3")
    try {
        mp3file.save("../../../test/LLT/nodir/testfiles/save_v1andv24tags.mp3")
    } catch(e: Exception){
        if (e.toString() != "FSException: The path `../../../test/LLT/nodir/testfiles` does not exist."){
            return 1
        }
    }
    0
}