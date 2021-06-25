import Combine
import Foundation

/// This helper class subscribes to a single value emitted from the publisher (promise) then completes
class CombinePromiseSubscriber<P: Publisher>: Subscriber {

    // MARK: - Internal

    typealias ValueHandler = (P.Output) -> Void
    typealias ErrorHandler = (P.Failure) -> Void
    typealias CompletionHandler = () -> Void

    init(valueHandler: ValueHandler?, errorHandler: ErrorHandler?) {
        self.valueHandler = valueHandler
        self.errorHandler = errorHandler
    }

    func setErrorHandler(_ errorHandler: ErrorHandler?) {
        self.errorHandler = errorHandler
    }

    func setCompletionHandler(_ completionHandler: CompletionHandler?) {
        self.completionHandler = completionHandler
    }

    func receive(subscription: Subscription) {
        subscription.request(.max(1))
    }

    func receive(_ value: P.Output) -> Subscribers.Demand {
        valueHandler?(value)
        return .none
    }

    func receive(completion: Subscribers.Completion<P.Failure>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            errorHandler?(error)
        }
        completionHandler?()
    }

    // MARK: - Private

    private let valueHandler: ValueHandler?
    private var errorHandler: ErrorHandler?
    private var completionHandler: CompletionHandler?
}
