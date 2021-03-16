import XCTest
@testable import SwiftLogging


final class SwiftLoggingTests: XCTestCase {
    
    func testLogging() {
        
        let log = Log(label: "Test label", level: .trace) { settings in
            TestLogging().log
        }
        XCTAssertEqual(log.label, "Test label")
        XCTAssertEqual(log.level, .trace)
        TestLogging.callback = {
            XCTAssertEqual($0.level, .trace)
            XCTAssertEqual($0.message.description, "Test message")
            XCTAssertEqual($0.metadata[.error] as? Int, 404)
            XCTAssertEqual($0.metadata["key"] as? String, "Test key")
        }
        let text = "Test message"
        let userInfo = ["error": 404, "key": "Test key"] as [AnyHashable : Any]
        
        log(.trace, "Test message", [.error: 404, "key": "Test key"])
        log("Test message", [.error: 404, "key": "Test key"])
        log(.trace, message: text, [.error: 404, "key": "Test key"])
        log(message: text, [.error: 404, "key": "Test key"])
        log(.trace, "Test message", metadata: userInfo)
        log("Test message", metadata: userInfo)
        log(.trace, message: text, metadata: userInfo)
        log(message: text, metadata: userInfo)
    }

    
    func testClosure() {
        
        var output = ""
        let log = Log(label: "") { _ in
            { print($0.message(), terminator: "", to: &output) }
        }
        log("Test print")
        XCTAssertEqual(output, "Test print")
    }
    
    
    func testDefaults() {
        
        XCTAssertEqual(Log.level, .info)
        XCTAssertEqual(Log.privacy, true)
        XCTAssert(Log.metadata.isEmpty)

        let log = Log(label: "")
        XCTAssertEqual(log.level, .info)
        XCTAssertEqual(log.privacy, true)
        XCTAssert(log.metadata.isEmpty)
        XCTAssertEqual(log.handlers.count, 1)
    }
    
    
    func testLevel() {
        
        XCTAssertEqual(Log.Level.trace.severity, 0.1)
        XCTAssertEqual(Log.Level.debug.severity, 0.2)
        XCTAssertEqual(Log.Level.info.severity, 0.3)
        XCTAssertEqual(Log.Level.notice.severity, 0.4)
        XCTAssertEqual(Log.Level.warning.severity, 0.5)
        XCTAssertEqual(Log.Level.error.severity, 0.6)
        XCTAssertEqual(Log.Level.critical.severity, 0.7)
        XCTAssertEqual(Log.Level.alert.severity, 0.8)
        XCTAssertEqual(Log.Level.emergency.severity, 0.9)

        let log = Log(label: "") { _ in
            {
                XCTAssertEqual($0.level.severity, Double($0.message().description))
                XCTAssertEqual($0.level.severity, $0.metadata()["level"] as? Double)
            }
        }
        
        log(0.321, "0.321", ["level": 0.321])
        log(0.321, message: "0.321", ["level": 0.321])
        log(0.321, "0.321", metadata: ["level": 0.321])
        log(0.321, message: "0.321", metadata: ["level": 0.321])

        log.trace("0.1", ["level": 0.1])
        log.trace(message: "0.1", ["level": 0.1])
        log.trace("0.1", metadata: ["level": 0.1])
        log.trace(message: "0.1", metadata: ["level": 0.1])

        log.debug("0.2", ["level": 0.2])
        log.debug(message: "0.2", ["level": 0.2])
        log.debug("0.2", metadata: ["level": 0.2])
        log.debug(message: "0.2", metadata: ["level": 0.2])

        log.info("0.3", ["level": 0.3])
        log.info(message: "0.3", ["level": 0.3])
        log.info("0.3", metadata: ["level": 0.3])
        log.info(message: "0.3", metadata: ["level": 0.3])

        log.notice("0.4", ["level": 0.4])
        log.notice(message: "0.4", ["level": 0.4])
        log.notice("0.4", metadata: ["level": 0.4])
        log.notice(message: "0.4", metadata: ["level": 0.4])

        log.warning("0.5", ["level": 0.5])
        log.warning(message: "0.5", ["level": 0.5])
        log.warning("0.5", metadata: ["level": 0.5])
        log.warning(message: "0.5", metadata: ["level": 0.5])

        log.error("0.6", ["level": 0.6])
        log.error(message: "0.6", ["level": 0.6])
        log.error("0.6", metadata: ["level": 0.6])
        log.error(message: "0.6", metadata: ["level": 0.6])

        log.critical("0.7", ["level": 0.7])
        log.critical(message: "0.7", ["level": 0.7])
        log.critical("0.7", metadata: ["level": 0.7])
        log.critical(message: "0.7", metadata: ["level": 0.7])

        log.alert("0.8", ["level": 0.8])
        log.alert(message: "0.8", ["level": 0.8])
        log.alert("0.8", metadata: ["level": 0.8])
        log.alert(message: "0.8", metadata: ["level": 0.8])

        log.emergency("0.9", ["level": 0.9])
        log.emergency(message: "0.9", ["level": 0.9])
        log.emergency("0.9", metadata: ["level": 0.9])
        log.emergency(message: "0.9", metadata: ["level": 0.9])
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
            PrintLogging(source: $0.label, items: .brief).log
            PrintLogging(source: $0.label).log
            PrintLogging(source: $0.label, items: .all).log
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
    
    
    func testOSLogging() {
        
        let log = Log(label: String(reflecting: Self.self), level: .notice, metadata: ["global": true]) {
            OSLogging(subsystem: $0.label, metadata: $0.metadata).log
            OSLogging(subsystem: $0.label, category: "Public", privacy: false, metadata: $0.metadata).log
        }
        log("Test message", [.error: 404, "key": "Test key"])
        log("Test \("message")", [.error: 404, "key": "Test key"])
    }
    
    
    func testLoggableClass() {
        
        TestLoggableClass.log("Test loggable class")
        TestLoggableClass().log("Test loggable class instance")
        
        measure {
            var log: Log?
            for _ in 0...100000 {
                log = TestLoggableClass.log
            }
            _ = log
        }
    }
    
    
    func testLoggableStruct() {
        
        TestLoggableStruct.log("Test loggable struct")
        TestLoggableStruct().log("Test loggable struct instance")
        
        measure {
            var log: Log?
            for _ in 0...100000 {
                log = TestLoggableStruct.log
            }
            _ = log
        }
    }
}



struct TestLogging: Logging {
    
    static var callback: (((level: Log.Level, message: Log.Message, metadata: Log.Metadata, file: String, function: String, line: UInt)) -> Void)!

    func log(_ level: Log.Level, _ message: @autoclosure () -> Log.Message, _ metadata: @autoclosure () -> Log.Metadata, file: String, function: String, line: UInt) {
        Self.callback((level, message(), metadata(), file, function, line))
    }
}



class TestLoggableClass: Loggable {
    static var log = defaultLog
}


struct TestLoggableStruct: Loggable {
    static var log = defaultLog
}
