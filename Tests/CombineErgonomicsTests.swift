import Combine
import XCTest
import CombineErgonomicsTestExtensions
@testable import CombineErgonomics

class CombineErgonomicsTests: XCTestCase {

    typealias NonFailable<O> = Result<O, Never>
    typealias Failable<O> = Result<O, Error>
    struct TestError: Error { }

    func testRunWithNoCompletionBlock() {
        let expectation = XCTestExpectation(description: "Promise should complete")
        let future = Future<Void, Never> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                expectation.fulfill()
                promise(.success(()))
            }
        }
        future.run()
        wait(for: [expectation], timeout: 0.3)
    }

    func testDoneWithNeverErrorResultType() {
        let future = timeDelayedFuture(result: NonFailable.success(()), after: 0.2)
        let expectation = XCTestExpectation(description: "Should receive success value")
        future.done {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.3)
    }

    func testDoneWithErrorResultTypeStillRuns() {
        let future = timeDelayedFuture(result: Failable.success(()), after: 0.2)
        let expectation = XCTestExpectation(description: "Should receive success value without attaching error handler")
        future.done {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.3)
    }

    func testDoneWithErrorResultTypeAndReturnsError() {
        let future = timeDelayedFuture(result: Failable<Void>.failure(TestError()), after: 0.2)
        let successExpectation = XCTestExpectation(description: "Future should not complete successfully")
        successExpectation.isInverted = true
        let failExpectation = XCTestExpectation(description: "Future should complete with error")
        future.done {
            successExpectation.fulfill()
        }.catch { _ in
            failExpectation.fulfill()
        }
        wait(for: [successExpectation, failExpectation], timeout: 0.3)
    }

    func testThen() {
        let future1 = timeDelayedFuture(result: Failable.success(0), after: 0.1)
        let future2 = timeDelayedFuture(result: Failable.success(1), after: 0.1)
        let future3 = timeDelayedFuture(result: Failable.success(2), after: 0.1)
        var results: [Int] = []
        let expectation = XCTestExpectation(description: "Three results are returned")
        expectation.expectedFulfillmentCount = 3

        future1.then { value -> Future<Int, Error> in
            results.append(value)
            expectation.fulfill()
            return future2
        }.then { value -> Future<Int, Error> in
            results.append(value)
            expectation.fulfill()
            return future3
        }.done { value in
            results.append(value)
            expectation.fulfill()
        }.cauterize()
        wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(results, [0, 1, 2])
    }

    func testThenWithErrorShortCircuitsOtherThenBlocks() {
        let future1 = timeDelayedFuture(result: Failable.success(0), after: 0.1)
        let future2 = timeDelayedFuture(result: Failable<Int>.failure(TestError()), after: 0.1)
        let future3 = timeDelayedFuture(result: Failable.success(2), after: 0.1)
        var results: [Int] = []
        let expectation = XCTestExpectation(description: "Failure is returned")

        future1.then { value -> Future<Int, Error> in
            results.append(value)
            return future2
        }.then { value -> Future<Int, Error> in
            results.append(value)
            return future3
        }.done { value in
            results.append(value)
        }.catch { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(results, [0])
    }
}
