package default
from std import io.*
// import java.nio.charset.Charset;
from std import collection.*
// import javax.annotation.Nullable;
// import okhttp3.internal.Util;
// import okio.Buffer;
// import okio.BufferedSink;
// import static okhttp3.HttpUrl.FORM_ENCODE_SET;
// import static okhttp3.HttpUrl.percentDecode;
public class FormBody <: RequestBody {
    private static let CONTENT_TYPE: MediaType = MediaType()
    private let encodedNames: List<String> = List<String>()
    private let encodedValues: List<String> = List<String>()
    init (encodedNames: List<String>, encodedValues: List<String>){
    }
    public func size (): Int32 {
  //    return encodedNames.size();
        return 0
    }
    public func encodedName (index: Int32): String {
  //    return encodedNames.get(index);
        return ""
    }
    public func nameFunc (index: Int32): String {
  //    return percentDecode(encodedName(index), true);
        return ""
    }
    public func encodedValue (index: Int32): String {
  //    return encodedValues.get(index);
        return ""
    }
    public func valueFunc (index: Int32): String {
  //    return percentDecode(encodedValue(index), true);
        return ""
    }
    public func contentTypeFunc (): MediaType {
  //    return CONTENT_TYPE;
        return MediaType()
    }
    public override func contentLengthFunc (): Int64 {
  //    return writeOrCountBytes(null, true);
        return 0
    }
    public func writeTo (sink: BufferedSink): Unit {
  //    writeOrCountBytes(sink, false);
    }
    private func writeOrCountBytes (sink: BufferedSink, countBytes: Bool): Int64 {
  //    long byteCount = 0L;
  //    Buffer buffer;
  //    if (countBytes) {
  //        buffer = new Buffer();
  //    } else {
  //        buffer = sink.buffer();
  //    for (int i = 0, size = encodedNames.size(); i < size; i++) {
  //        if (i > 0) buffer.writeByte('&');
  //        buffer.writeUtf8(encodedNames.get(i));
  //        buffer.writeByte('=');
  //        buffer.writeUtf8(encodedValues.get(i));
  //    if (countBytes) {
  //        byteCount = buffer.size();
  //        buffer.clear();
  //    return byteCount;
        return 0
    }
    public init() {}
}
public class FormBodyBuilder {
    var class_out: FormBody
    public init(out: FormBody) {
        class_out = out
    }
    public init() {
        class_out = FormBody()
    }
    private let names: List<String> = List<String>()
    private let values: List<String> = List<String>()
    //@Nullable
    private let charset: Charset = Charset()
    public func add (name: String, value: String): FormBodyBuilder {
  //    if (name == null) throw new NullPointerException("name == null");
  //    if (value == null) throw new NullPointerException("value == null");
  //    names.add(HttpUrl.canonicalize(name, FORM_ENCODE_SET, false, false, true, true, charset));
  //    values.add(HttpUrl.canonicalize(value, FORM_ENCODE_SET, false, false, true, true, charset));
  //    return this;
        return FormBodyBuilder()
    }
    public func addEncoded (name: String, value: String): FormBodyBuilder {
  //    if (name == null) throw new NullPointerException("name == null");
  //    if (value == null) throw new NullPointerException("value == null");
  //    names.add(HttpUrl.canonicalize(name, FORM_ENCODE_SET, true, false, true, true, charset));
  //    values.add(HttpUrl.canonicalize(value, FORM_ENCODE_SET, true, false, true, true, charset));
  //    return this;
        return FormBodyBuilder()
    }
    public func build (): FormBody {
  //    return new FormBody(names, values);
        return FormBody()
    }
}