import Combine
import XCTest

public extension XCTestCase {

    /// Helper method for testing the values of `Publisher` in response to other code being executed.
    /// - parameter publisher: A non-failable publisher
    /// - parameter dropFirst: Value to pass to `publisher.dropFirst` before observing. This defaults to 1 as a convenience, in order to ignore the initial value that is sent when observing a `Publisher`.
    /// - parameter expectedNumber: The number of `.next` events that should be received from `publisher` after executing `closure`.
    /// - parameter closure: The method will execute this closure and then wait for `expectedNumber` of `.next` events to be received from the `publisher` before returning
    /// - returns: The collected values from the `publisher`.
    func values<T, P: Publisher>(for publisher: P,
                                 dropFirst: Int = 1,
                                 expectedNumber: Int = 1,
                                 whenExecutingClosure closure: () -> Void) -> [T]
    where P.Output == T, P.Failure == Never {
        let expectation = XCTestExpectation(description: "Publisher")
        expectation.expectedFulfillmentCount = expectedNumber
        var values: [T] = []
        let cancellable = publisher.dropFirst(dropFirst).sink { value in
            expectation.fulfill()
            values.append(value)
        }
        closure()
        wait(for: [expectation], timeout: 2)
        return values
    }

    /// Helper method for verifying that `Publisher` does not send any `.next` events when executing the given closure.
    /// - parameter publisher: A non-failable publisher.
    /// - parameter dropFirst: Value to pass to `publisher.dropFirst` before observing. This defaults to 1 as a convenience, in order to ignore the initial value that is sent when observing a `Publisher`.
    /// - parameter closure: The method will execute this closure and then wait to verify that `signal` does not send any `.next` events afterward.
    func reject<T, P: Publisher>(_ publisher: P, dropFirst: Int = 1, whenExecutingClosure closure: () -> Void)
    where P.Output == T, P.Failure == Never {
        let expectation = XCTestExpectation(description: "signal")
        expectation.isInverted = true
        let cancellable = publisher.dropFirst(dropFirst).sink { _ in
            expectation.fulfill()
        }
        closure()
        wait(for: [expectation], timeout: 2)
    }

    /// Waits for the given Bool publisher to send a value of false before proceeding.
    func waitUntilFalse<P: Publisher>(_ publisher: P)
    where P.Output == Bool, P.Failure == Never {
        let expectation = XCTestExpectation(description: "value is false")
        let cancellable = publisher.sink { value in
            if !value {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    /// Helper method to return a future that completes after a certain amount of time
    /// - Parameters:
    ///   - result: the `Result` for the future to complete with
    ///   - scheduler: scheduler on which to return the `result` on
    ///   - delay: time interval after which the future should complete
    /// - Returns: a `Future` that completes in a set amount of time on a given scheduler.
    func timeDelayedFuture<O, E, S>(result: Result<O, E>,
                                    on scheduler: S,
                                    after delay: S.SchedulerTimeType.Stride) -> Future<O, E>
    where E: Error, S: Scheduler {
        Future { promise in
            scheduler.schedule(after: scheduler.now.advanced(by: delay)) {
                promise(result)
            }
        }
    }

    /// Helper method to return a future that completes after a certain amount of time
    /// - Parameters:
    ///   - result: the `Result` for the future to complete with
    ///   - delay: time interval (in seconds) after which the future should complete
    /// - Returns: a `Future` that completes in a set amount of time on a `DispatchQueue.global()`.
    func timeDelayedFuture<O, E>(result: Result<O, E>, after delay: TimeInterval) -> Future<O, E>
    where E: Error {
        let queue = DispatchQueue.global()
        return Future { promise in
            queue.schedule(after: queue.now.advanced(by: .seconds(delay))) {
                promise(result)
            }
        }
    }
}
