package eventbus4cj
import std.reflect.*
public interface SubscriberInfo {
    func getSubscriberClass(): ?ClassTypeInfo
    func getSubscriberMethods(): ?Array<?SubscriberMethod>
    func getSuperSubscriberInfo(): ?SubscriberInfo
    func shouldCheckSuperclass(): Bool
}