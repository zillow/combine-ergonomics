import Combine
import Foundation

/// This class helps provide a UX similar to using [PromiseKit](https://github.com/mxcl/PromiseKit) promises, but with Combine Publishers.
public class PromiseFinalizer<P: Publisher, S: Scheduler> {

    // MARK: - Public

    @discardableResult
    public func `catch`(_ handler: @escaping (P.Failure) -> Void) -> PromiseFinalizer<P, S> {
        subscriber.setErrorHandler(handler)
        return self
    }

    /// Use this method to deliberately end the promise chain, swallowing any errors along the way.
    public func cauterize() {
        return
    }

    /// Use this method to execute a closure after the chain has completed
    public func finally(_ handler: @escaping () -> Void) {
        subscriber.setCompletionHandler(handler)
    }

    // MARK: - Internal

    init(_ publisher: P, scheduler: S, handler: ((P.Output) -> Void)?) {
        subscriber = CombinePromiseSubscriber(valueHandler: handler, errorHandler: nil)
        DispatchQueue.main.async {
            publisher
                .subscribe(on: scheduler)
                .receive(on: DispatchQueue.main)
                .subscribe(self.subscriber)
        }
    }

    // MARK: - Private

    private let subscriber: CombinePromiseSubscriber<P>
}
