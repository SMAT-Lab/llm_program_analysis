package charset4cj.charset.simplechinese
public class GBKCharset <: Charset{
    public static let instance = GBKCharset()
    private init(){
        super("gbk", "chinese", "csgb2312", "csiso58gb231280", "gb2312", "gb_2312", "gb_2312-80", "gbk", "iso-ir-58", "x-gbk")
        // Actual number of characters gbk > gb2312 , for ease of handling,  use gb2312 as gbk
        // this.labels = ["chinese", "csgb2312", "csiso58gb231280", "gb2312", "gb_2312", "gb_2312-80", "gbk", "iso-ir-58", "x-gbk"]
        // this.name = "gbk"
    }
    public func newEncoder():Encoder{
        GB18030Encoder(true)
    }
    public func newDecoder():Decoder{
        GB18030Decoder()
    }
}
public class GB18030Charset <: Charset{
    public static let instance = GB18030Charset()
    private init(){
        super("gb18030", "gb18030")
        // this.labels = ["gb18030"]
        // this.name = "gb18030"
    }
    public func newEncoder():Encoder{
        GB18030Encoder(false)
    }
    public func newDecoder():Decoder{
        GB18030Decoder()
    }
}