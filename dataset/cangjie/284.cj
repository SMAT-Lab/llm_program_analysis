// 3rd_party_lib:mp3tag4cj/build/mp3tag4cj
// 3rd_party_lib:mp3tag4cj/ci_lib/charset
// 3rd_party_lib:mp3tag4cj/ci_lib/crypto4cj
// data_file:./v23tagwithchapters.mp3
from std import collection.*
from std import unittest.*
from mp3tag4cj import mp3tag4cj.*
from std import io.*
from std import os.posix.*
import secodeFuzz.*
func call_fuzz(int32:Int32){
    var mp3File: Mp3File = Mp3File("v23tagwithchapters.mp3")
    var id3V22Tag: ID3v2 = mp3File.getId3v2Tag().getOrThrow()
    var chapters: ArrayList<ID3v2ChapterFrameData> = id3V22Tag.getChapters().getOrThrow()
    var id3v2ChapterFrameData: ID3v2ChapterFrameData = chapters[0]
    id3v2ChapterFrameData.setEndOffset(int32)
    return
}
func unboundTest():Unit{
    var case_name=CString("Fuzz_id3v2ChapterFrameData.setEndOffset")
    unsafe{
        DT_FUZZ_Int32(0,30000000,case_name,0,call_fuzz)
        case_name.free()
    }
}
main(){
    unboundTest()
    return
}