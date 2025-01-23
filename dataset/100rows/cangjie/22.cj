package cj_easy_data.pojo
import cj_easy_data.macros.*
@Data
public class User{
    public var name:?String
    @NoToString
    public var age:?Int32
    @NoToString
    public var any:?Any
}
