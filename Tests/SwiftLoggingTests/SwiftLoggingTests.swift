import XCTest
@testable import SwiftLogging


final class SwiftLoggingTests: XCTestCase {
    
    var callback: (((level: Log.Level, message: Log.Message, metadata: Log.Metadata, file: String, function: String, line: UInt)) -> Void)!
    
    
    func testExample() {
        
        let log = Log(label: "Test label", level: .alert) { settings in
            TestLogHandler(tests: self)
        }
        XCTAssertEqual(log.label, "Test label")
        XCTAssertEqual(log.level, .alert)
        callback = {
            XCTAssertEqual($0.level, .trace)
//            XCTAssertEqual($0.message, "Test message")
            XCTAssertEqual($0.metadata[.error] as? Int, 404)
            XCTAssertEqual($0.metadata["key"] as? String, "Test key")
        }
        log(.trace, "Test message", [.error: 404, "key": "Test key"])
    }

    
    static var allTests = [
        ("testExample", testExample),
    ]
}



struct TestLogHandler: LogHandler {
    
    unowned let tests: SwiftLoggingTests

    func log(_ level: Log.Level, _ message: @autoclosure () -> Log.Message, _ metadata: @autoclosure () -> Log.Metadata, file: String, function: String, line: UInt) {
        tests.callback((level, message(), metadata(), file, function, line))
    }
}
