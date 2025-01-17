package eventbus4cj
public class NoSubscriberEvent {
    public let eventBus: ?EventBus
    public let originalEvent: ?Any
    public init(eventBus: ?EventBus, originalEvent: ?Any) {
        this.eventBus = eventBus
        this.originalEvent = originalEvent
    }
}