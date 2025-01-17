package api.trace
public interface ITextMapPropagator<T> {
    func fields(): Array<String>
    func inject(context: Context, carrier: T, setter: (T, String, String) -> Unit): Unit
    func extract(carrier: T, getter: (T, String) -> ?String): Unit
}