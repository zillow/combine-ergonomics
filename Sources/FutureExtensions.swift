import Combine

public extension Future {

    static func value(_ value: Output) -> Future<Output, Failure> {
        Future { $0(.success(value)) }
    }

    static func error(_ error: Failure) -> Future<Output, Failure> {
        Future { $0(.failure(error)) }
    }
}
