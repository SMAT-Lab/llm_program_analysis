package api.metric
import api.resource.Attributes
public interface ILongHistogram {
    //grouping 只允许正值
    func record(value: Int64): Unit
    //grouping 只允许正值
    func record(value: Int64, tags: Attributes): Unit
}