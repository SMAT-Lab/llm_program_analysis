package rx.observables
class ObservableConcatMap<T> <: Observable<T> {
    private let sources: ArrayList<Observable<T>>
    init(sources: Collection<Observable<T>>) {
        this.sources = ArrayList<Observable<T>>(sources)
    }
    public func subscribeActual(observer: Observer<T>) {
        let disposable = ConcatMapObserver(observer, sources)
        observer.onSubscribe(disposable)
        disposable.drain()
    }
}
class ConcatMapObserver<T> <: EquatableDisposable {
    private let downstream: Observer<T>
    protected let observer: InnerObserver<T>
    private let sources: ArrayList<Observable<T>>
    private var index: Int64 = 0
    private var cancelled: Bool = false
    protected var active: Bool = true
    init(downstream: Observer<T>, sources: ArrayList<Observable<T>>) {
        this.downstream = downstream
        this.sources = sources
        this.observer = InnerObserver<T>(downstream)
        this.observer.parent = this
    }
    func drain() {
        if (!active || isDisposed()) {
            return
        }
        if (index >= sources.size) {
            downstream.onComplete()
            return
        }
        let o: Observable<T> = sources[index]
        index++
        o.subscribe(observer)
    }
    public func dispose(): Unit {
        cancelled = true
        observer.dispose()
    }
    public func isDisposed(): Bool {
        return cancelled
    }
}
class InnerObserver<T> <: Observer<T> {
    private let downstream: Observer<T>
    protected var parent: ?ConcatMapObserver<T> = Option.None
    private var disposableReference: DisposableReference = DisposableReference()
    init(downstream: Observer<T>) {
        this.downstream = downstream
    }
    public func onSubscribe(disposable: Disposable): Unit {
        disposableReference.setOnce(disposable)
    }
    public func onNext(value: T) {
        downstream.onNext(value)
    }
    public func onError(exception: Exception) {
        parent?.active = false
        parent?.drain()
        downstream.onError(exception)
    }
    public func onComplete(): Unit {
        parent?.drain()
    }
    public func dispose(): Unit {
        DisposableHelper.dispose(disposableReference)
    }
}