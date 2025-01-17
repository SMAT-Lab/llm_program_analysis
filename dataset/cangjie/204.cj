// EXEC: cjc -O2 %import-path %L %l %f
// EXEC: ./main
from mp3tag4cj import mp3tag4cj.*
from std import collection.*
from std import io.*
from std import fs.*
from std import math.*
main() {
    var expimgDataSrc: Array<Int8> = BufferTools.transUInt8ArrayToInt8(File.readFrom("../../../test/LLT/bugfix/testfiles/test_jp.jpeg"))                  //有中文设置不进去
    var mp3File: Mp3File = Mp3File("../../../test/LLT/bugfix/testfiles/v1andv23tagswithalbumimage.mp3")
    var id3V22Tag: ID3v2 = mp3File.getId3v2Tag().getOrThrow()
    id3V22Tag.setAlbumImage(expimgDataSrc, "aaaaaa，仓颉")
    mp3File.save("../../../test/LLT/bugfix/testfiles/save_pic_v1andv23tagswithalbumimage.mp3")
    var mp3FileSave: Mp3File = Mp3File("../../../test/LLT/bugfix/testfiles/save_pic_v1andv23tagswithalbumimage.mp3")
    var id3V2Tag1 = mp3FileSave.getId3v2Tag().getOrThrow()
    if (id3V2Tag1.getAlbumImageMimeType() != "aaaaaa，仓颉") {
        return 1
    }
    if (id3V2Tag1.getAlbumImage() != expimgDataSrc) {
        return 1
    }
    0
}