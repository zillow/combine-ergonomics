import Combine
import Foundation

public extension Publisher {

    /// Starts the given Future without attaching a completion handler.
    /// - Parameter scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    /// - Returns: `PromiseFinalizer` that can be used to handle any errors
    func run<S: Scheduler>(on scheduler: S) -> PromiseFinalizer<Self, S> {
        PromiseFinalizer(self, scheduler: scheduler, handler: nil)
    }

    /// Starts the given Future without attaching a completion handler.
    /// - Returns: `PromiseFinalizer` that can be used to handle any errors
    func run() -> PromiseFinalizer<Self, DispatchQueue> {
        PromiseFinalizer(self, scheduler: DispatchQueue.global(), handler: nil)
    }

    /// Add a closure to be executed after the publisher runs on a `Scheduler` and emits one single value
    /// - Parameters:
    ///   - scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    /// - Returns: `PromiseFinalizer` that can be used to handle any errors
    func done<S: Scheduler>(on scheduler: S, handler: @escaping (Output) -> Void) -> PromiseFinalizer<Self, S> {
        PromiseFinalizer(self, scheduler: scheduler, handler: handler)
    }

    /// Add a closure to be executed after the publisher runs on `DispatchQueue.global()` and emits one single value
    /// - Parameters:
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    /// - Returns: `PromiseFinalizer` that can be used to handle any errors.
    func done(_ handler: @escaping (Output) -> Void) -> PromiseFinalizer<Self, DispatchQueue> {
        PromiseFinalizer(self, scheduler: DispatchQueue.global(), handler: handler)
    }

    /// Add a closure to be executed after the publisher runs on a `Scheduler`, and then return another publisher to run afterwards.
    /// - Parameters:
    ///   - scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    ///   - handler: The closure to run once the publisher has executed. Returns a new `Publisher`.
    /// - Returns: `Publisher` that can be subscribed to
    func then<P: Publisher, S: Scheduler>(on scheduler: S, handler: @escaping (Output) -> P) -> Publishers.SubscribeOn<Publishers.FlatMap<P, Self>, S> {
        flatMap(handler).subscribe(on: scheduler)
    }

    /// Add a closure to be executed after the publisher runs on a `Scheduler`, and then return another publisher to run afterwards.
    /// - Parameters:
    ///   - handler: The closure to run once the publisher has executed. Returns a new `Publisher`.
    /// - Returns: `Publisher` that can be subscribed to
    func then<P: Publisher>(_ handler: @escaping (Output) -> P) -> Publishers.FlatMap<P, Self> {
        flatMap(handler)
    }
}

public extension Publisher where Output == Void {

    /// Add a closure to be executed after the publisher runs on a `Scheduler` and emits one single value
    /// - Parameters:
    ///   - scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    /// - Returns: `PromiseFinalizer` that can be used to handle any errors
    func done<S: Scheduler>(on scheduler: S, handler: @escaping () -> Void) -> PromiseFinalizer<Self, S> {
        PromiseFinalizer(self, scheduler: scheduler, handler: handler)
    }

    /// Add a closure to be executed after the publisher runs on `DispatchQueue.global()` and emits one single value
    /// - Parameters:
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    /// - Returns: `PromiseFinalizer` that can be used to handle any errors.
    func done(_ handler: @escaping () -> Void) -> PromiseFinalizer<Self, DispatchQueue> {
        PromiseFinalizer(self, scheduler: DispatchQueue.global(), handler: handler)
    }

    /// Add a closure to be executed after the publisher runs on a `Scheduler`, and then return another publisher to run afterwards.
    /// - Parameters:
    ///   - scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    ///   - handler: The closure to run once the publisher has executed. Returns a new `Publisher`.
    /// - Returns: `Publisher` that can be subscribed to
    func then<P: Publisher, S: Scheduler>(on scheduler: S, handler: @escaping () -> P) -> Publishers.FlatMap<P, Publishers.SubscribeOn<Self, S>> {
        subscribe(on: scheduler).flatMap(handler)
    }

    /// Add a closure to be executed after the publisher runs on a `Scheduler`, and then return another publisher to run afterwards.
    /// - Parameters:
    ///   - handler: The closure to run once the publisher has executed. Returns a new `Publisher`.
    /// - Returns: `Publisher` that can be subscribed to
    func then<P: Publisher>(_ handler: @escaping () -> P) -> Publishers.FlatMap<P, Self> {
        flatMap(handler)
    }
}

public extension Publisher where Failure == Never {

    /// Starts the given Future without attaching a completion handler.
    /// - Parameter scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    func run<S: Scheduler>(on scheduler: S) {
        PromiseFinalizer(self, scheduler: scheduler, handler: nil).cauterize()
    }

    /// Starts the given Future without attaching a completion handler.
    func run() {
        PromiseFinalizer(self, scheduler: DispatchQueue.global(), handler: nil).cauterize()
    }

    /// Add a closure to be executed after the publisher runs on a `Scheduler` and emits one single value
    /// - Parameters:
    ///   - scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    func done<S: Scheduler>(on scheduler: S, handler: @escaping (Output) -> Void)
    where Failure == Never {
        PromiseFinalizer(self, scheduler: scheduler, handler: handler).cauterize()
    }

    /// Add a closure to be executed after the publisher runs on `DispatchQueue.global()` and emits one single value
    /// - Parameters:
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    func done(_ handler: @escaping (Output) -> Void)
    where Failure == Never {
        PromiseFinalizer(self, scheduler: DispatchQueue.global(), handler: handler).cauterize()
    }
}

public extension Publisher where Output == Void, Failure == Never {

    /// Add a closure to be executed after the publisher runs on a `Scheduler` and emits one single value
    /// - Parameters:
    ///   - scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    func done<S: Scheduler>(on scheduler: S, handler: @escaping () -> Void) {
        PromiseFinalizer(self, scheduler: scheduler, handler: handler).cauterize()
    }

    /// Add a closure to be executed after the publisher runs on `DispatchQueue.global()` and emits one single value
    /// - Parameters:
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    func done(_ handler: @escaping () -> Void) {
        PromiseFinalizer(self, scheduler: DispatchQueue.global(), handler: handler).cauterize()
    }
}
