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
    
    
    func testPrintLogging() {
        
        let log = Log(label: String(describing: Self.self)) {
            PrintLogging(label: $0.label, items: .all).log
        }
        log(.trace, "Trace message", [.description: Log.Level.trace])
        log(.debug, "Debug message", [.description: Log.Level.debug])
        log(.info, "Info message", [.description: Log.Level.info])
        log(.notice, "Notice message", [.description: Log.Level.notice])
        log(.warning, "Warning message", [.description: Log.Level.warning])
        log(.error, "Error message", [.description: Log.Level.error])
        log(.critical, "Critical message", [.description: Log.Level.critical])
        log(.alert, "Alert message", [.description: Log.Level.alert])
        log(.emergency, "Emergency message", [.description: Log.Level.emergency])
    }
    
    
    func testLoggable() {
        TestLoggable.log("Test loggable")
        measure {
            for _ in 0...1000 {
                _ = TestLoggable.log
            }
        }
    }
    
    func testLoggableClass() {
        TestLoggableClass.log("Test loggable class")
        measure {
            for _ in 0...1000000 {
                _ = TestLoggableClass.log
            }
        }
    }
    
    func testLoggableStruct() {
        TestLoggableStruct.log("Test loggable struct")
        measure {
            for _ in 0...1000000 {
                _ = TestLoggableStruct.log
            }
        }
    }
}



struct TestLogging: Logging {
    
    unowned let tests: SwiftLoggingTests

    func log(_ level: Log.Level, _ message: @autoclosure () -> Log.Message, _ metadata: @autoclosure () -> Log.Metadata, file: String, function: String, line: UInt) {
        tests.callback((level, message(), metadata(), file, function, line))
    }
}



class TestLoggable: Loggable { }

class TestLoggableClass: Loggable {
    static var log = defaultLog
}

struct TestLoggableStruct: Loggable {
    static var log = defaultLog
}
