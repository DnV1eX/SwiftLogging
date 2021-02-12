import XCTest
@testable import SwiftLogging

final class SwiftLoggingTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftLogging().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
