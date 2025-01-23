package s3client.util
public class ToStringUtils {
    public static func listToString<T>(values: Iterable<T>): String {
        let str = values |> map<T, String> {v => toString(v)} |> collectString<String>(delimiter: ", ")
        return "[" + str + "]"
    }
    public static func mapToString<K, V>(kvs: Iterable<(K, V)>): String {
        let str = kvs |> map<(K, V), String> {
            kv =>
            let k = toString(kv[0])
            let v = toString(kv[1])
            k + ":" + v
        } |> collectString<(String)>(delimiter: ", ")
        return "{" + str + "}"
    }
    public static func mapToString2<K, V>(kvs: ?Map<K, V>): ?String where K <: ToString & Equatable<K>, V <: ToString {
        return match (kvs) {
            case Some(_kvs) => mapToString(_kvs)
            case None => None
        }
    }
    private static func toString<T>(v: T): String {
        return match (v) {
            case v1: ToString => v1.toString()
            // 主要给 S3MultiValueMap 使用, 现在也都是 Collection<String>
            case v2: Iterable<String> => "[" + (v2 |> collectString<String>(delimiter: ", ")) + "]"
            case _ => "<!ToString(${TypeInfo.of(v)})>"
        }
    }
    public static func exceptionToString(ex: Exception): String {
        var sb = StringBuilder()
        sb.append(ex.toString())
        sb.append(IOUtils.LINE_SEPARATOR)
        let stacks = ex.getStackTrace()
        for (i in 0..stacks.size) {
            let stack = stacks[i]
            sb.append("\t at ${stack.declaringClass} ${stack.methodName} (${stack.fileName}:${stack.lineNumber})")
            sb.append(IOUtils.LINE_SEPARATOR)
        }
        return sb.toString()
    }
}