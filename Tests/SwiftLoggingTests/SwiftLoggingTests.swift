import XCTest
@testable import SwiftLogging


final class SwiftLoggingTests: XCTestCase {
    
    var callback: (((level: Log.Level, message: Log.Message, metadata: Log.Metadata, file: String, function: String, line: UInt)) -> Void)!
    
    
    func testLogging() {
        
        let log = Log(label: "Test label", level: .alert) { settings in
            TestLogging(tests: self).log
        }
        XCTAssertEqual(log.label, "Test label")
        XCTAssertEqual(log.level, .alert)
        callback = {
            XCTAssertEqual($0.level, .trace)
            XCTAssertEqual("\($0.message)", "Test message")
            XCTAssertEqual($0.metadata[.error] as? Int, 404)
            XCTAssertEqual($0.metadata["key"] as? String, "Test key")
        }
        log(.trace, "Test message", [.error: 404, "key": "Test key"])
    }

    
    func testClosure() {
        
        var output = ""
        let log = Log(label: "") { _ in
            { print($0.message(), terminator: "", to: &output) }
        }
        log("Test print")
        XCTAssertEqual(output, "Test print")
    }
    
    
    func testMessage() {
        
        var message: Log.Message = ""
        XCTAssertEqual(message.description, "")
        XCTAssertEqual(message.debugDescription, "")
        message = "42"
        XCTAssertEqual(message.description, "42")
        XCTAssertEqual(message.debugDescription, "42")
        message = "\(42)"
        XCTAssertEqual(message.description, "42")
        XCTAssertEqual(message.debugDescription, "42")
        message = "\("42")"
        XCTAssertNotEqual(message.description, "42")
        XCTAssertNotEqual(message.description, ("\("24")" as Log.Message).description)
        XCTAssertGreaterThan(message.description.count, 2)
        XCTAssertEqual(message.description, message.description)
        XCTAssertEqual(message.debugDescription, "42")
        message = "\(private: 42)"
        XCTAssertNotEqual(message.description, "42")
        XCTAssertEqual(message.debugDescription, "42")
        message = "\(public: "42")"
        XCTAssertEqual(message.description, "42")
        XCTAssertEqual(message.debugDescription, "42")
        message = "4\(0)4"
        XCTAssertEqual(message.description, "404")
        XCTAssertEqual(message.debugDescription, "404")
    }
}



struct TestLogging {
    
    unowned let tests: SwiftLoggingTests

    func log(_ level: Log.Level, _ message: @autoclosure () -> Log.Message, _ metadata: @autoclosure () -> Log.Metadata, file: String, function: String, line: UInt) {
        tests.callback((level, message(), metadata(), file, function, line))
    }
}
