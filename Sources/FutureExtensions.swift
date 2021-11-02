import Combine

public extension Future {

    /// This method immediately resolves with `.success(value)`
    static func value(_ value: Output) -> Future<Output, Failure> {
        Future { $0(.success(value)) }
    }

    /// This method immediately resolves with `.failure(error)`
    static func error(_ error: Failure) -> Future<Output, Failure> {
        Future { $0(.failure(error)) }
    }

    /// Apply a transform to a completed `Future`, returning another `Future`
    /// - Parameters:
    ///   - transform: A closure accepting `Output` and returning `T`. This runs on `DispatchQueue.global()`
    /// - Returns: `Future<T, Failure>`
    func mapToFuture<T>(transform: @escaping (Output) -> T) -> Future<T, Failure> {
        Future<T, Failure> { promise in
            self.done { value in
                promise(.success(transform(value)))
            }.catch { error in
                promise(.failure(error))
            }
        }
    }

    /// Apply a transform to a completed `Future`, returning another `Future`
    /// - Parameters:
    ///   - scheduler: `DispatchQueue` or other `Scheduler` on which the publisher executes
    ///   - transform: A closure accepting `Output` and returning `T`. This runs on `scheduler`
    /// - Returns: `Future<T, Failure>`
    func mapToFuture<T, S: Scheduler>(on scheduler: S, transform: @escaping (Output) -> T) -> Future<T, Failure> {
        Future<T, Failure> { promise in
            self.done(on: scheduler) { value in
                promise(.success(transform(value)))
            }.catch { error in
                promise(.failure(error))
            }
        }
    }
}
