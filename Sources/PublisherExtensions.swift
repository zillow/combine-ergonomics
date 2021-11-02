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

    /// Starts the given Future without attaching a completion handler.
    /// This is a convenience method when `Failure == Never`
    /// - Parameter scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    func run<S: Scheduler>(on scheduler: S)
    where Failure == Never {
        PromiseFinalizer(self, scheduler: scheduler, handler: nil).cauterize()
    }

    /// Starts the given Future without attaching a completion handler.
    /// This is a convenience method when `Failure == Never`
    func run()
    where Failure == Never {
        PromiseFinalizer(self, scheduler: DispatchQueue.global(), handler: nil).cauterize()
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

    /// Add a closure to be executed after the publisher runs on a `Scheduler` and emits one single value
    /// This is a convenience method to simplify the use site when `Output == Void`
    /// - Parameters:
    ///   - scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    /// - Returns: `PromiseFinalizer` that can be used to handle any errors
    func done<S: Scheduler>(on scheduler: S, handler: @escaping () -> Void) -> PromiseFinalizer<Self, S>
    where Output == Void {
        PromiseFinalizer(self, scheduler: scheduler, handler: handler)
    }

    /// Add a closure to be executed after the publisher runs on `DispatchQueue.global()` and emits one single value
    /// This is a convenience method to simplify the use site when `Output == Void`
    /// - Parameters:
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    /// - Returns: `PromiseFinalizer` that can be used to handle any errors.
    func done(_ handler: @escaping () -> Void) -> PromiseFinalizer<Self, DispatchQueue>
    where Output == Void {
        PromiseFinalizer(self, scheduler: DispatchQueue.global(), handler: handler)
    }

    /// Add a closure to be executed after the publisher runs on a `Scheduler` and emits one single value
    /// This is a convenience method when `Failure == Never`
    /// - Parameters:
    ///   - scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    func done<S: Scheduler>(on scheduler: S, handler: @escaping (Output) -> Void)
    where Failure == Never {
        PromiseFinalizer(self, scheduler: scheduler, handler: handler).cauterize()
    }

    /// Add a closure to be executed after the publisher runs on `DispatchQueue.global()` and emits one single value
    /// This is a convenience method when `Failure == Never`
    /// - Parameters:
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    func done(_ handler: @escaping (Output) -> Void)
    where Failure == Never {
        PromiseFinalizer(self, scheduler: DispatchQueue.global(), handler: handler).cauterize()
    }

    /// Add a closure to be executed after the publisher runs on a `Scheduler` and emits one single value
    /// This is a convenience method when `Output == Void` and `Failure == Never`
    /// - Parameters:
    ///   - scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    func done<S: Scheduler>(on scheduler: S, handler: @escaping () -> Void)
    where Output == Void, Failure == Never {
        PromiseFinalizer(self, scheduler: scheduler, handler: handler).cauterize()
    }

    /// Add a closure to be executed after the publisher runs on `DispatchQueue.global()` and emits one single value
    /// This is a convenience method when `Output == Void` and `Failure == Never`
    /// - Parameters:
    ///   - handler: The closure to run once the publisher has executed. This runs on `DispatchQueue.main`
    func done(_ handler: @escaping () -> Void)
    where Output == Void, Failure == Never {
        PromiseFinalizer(self, scheduler: DispatchQueue.global(), handler: handler).cauterize()
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

    /// Add a closure to be executed after the publisher runs on a `Scheduler`, and then return another publisher to run afterwards.
    /// This is a convenience method to simplify the use site when `Output == Void`
    /// - Parameters:
    ///   - scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    ///   - handler: The closure to run once the publisher has executed. Returns a new `Publisher`.
    /// - Returns: `Publisher` that can be subscribed to
    func then<P: Publisher, S: Scheduler>(on scheduler: S, handler: @escaping () -> P) -> Publishers.SubscribeOn<Publishers.FlatMap<P, Self>, S>
    where Output == Void {
        flatMap(handler).subscribe(on: scheduler)
    }

    /// Add a closure to be executed after the publisher runs on a `Scheduler`, and then return another publisher to run afterwards.
    /// This is a convenience method to simplify the use site when `Output == Void`
    /// - Parameters:
    ///   - handler: The closure to run once the publisher has executed. Returns a new `Publisher`.
    /// - Returns: `Publisher` that can be subscribed to
    func then<P: Publisher>(_ handler: @escaping () -> P) -> Publishers.FlatMap<P, Self>
    where Output == Void {
        flatMap(handler)
    }
}
