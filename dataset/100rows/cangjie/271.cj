package bean.exception
import base.exception.BaseException
public class BeanException <: BaseException {
    public init() {}
    public init(message: String) {
        super(message)
    }
    public init(caused: Exception) {
        super(caused)
    }
    public init(message: String, caused: Exception) {
        super(message, caused)
    }
}