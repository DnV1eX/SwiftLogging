//
//  SwiftLogging.swift
//  SwiftLogging
//
//  Created by Alexey Demin on 2021-02-12.
//  Copyright © 2021 DnV1eX. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//

import Foundation


public struct Log {
    
    public typealias Settings = (label: String, level: Level, privacy: Bool, metadata: Metadata)
    
    public typealias Handlers = (Settings) -> [Handler]
    
    /// defaultLevel
    @Atomic public static var level: Level = .info
    
    /// defaultPrivacy
    @Atomic public static var privacy: Bool = true
    
    /// defaultMetadata
    @Atomic public static var metadata: Metadata = [:]
    
    /// defaultHandlers
    @Atomic public static var handlers: Handlers = defaultHandlers
    
    
    @HandlerBuilder public static func defaultHandlers(settings: Settings) -> [Handler] {
        if PrintLogging.isStandardOutputAvailable {
            PrintLogging(source: settings.label).log
        } else {
            OSLogging(subsystem: settings.label, metadata: settings.metadata).log
        }
    }
    
    
    public static func buildHandlers(@HandlerBuilder _ handlers: @escaping Handlers) -> Handlers {
        handlers
    }
    
    /// defaultSettings
    public static func configure(level: Level = level, privacy: Bool = privacy, metadata: Metadata = metadata, @HandlerBuilder handlers: @escaping Handlers = handlers) {
        
        Self.level = level
        Self.privacy = privacy
        Self.metadata = metadata
        Self.handlers = handlers
    }
    
    
    public let label: String
    public let level: Level
    public let privacy: Bool
    public let metadata: Metadata

    public let handlers: [Handler]
    
    
    @inlinable
    public init(label: String, level: Level = level, privacy: Bool = privacy, metadata: Metadata = metadata, @HandlerBuilder handlers: Handlers = handlers) {
        
        self.label = label
        self.level = level
        self.privacy = privacy
        self.metadata = metadata
        
        self.handlers = handlers((label, level, privacy, metadata))
    }
    
    
    @inlinable
    public func callAsFunction(_ level: Level, _ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(level, message, metadata, file, function, line)
        }
    }
    
    @inlinable
    public func callAsFunction(_ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(level, message, metadata, file, function, line)
        }
    }
    
    @inlinable
    public func callAsFunction(_ level: Level, message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(level, { Message(stringLiteral: message()) }, metadata, file, function, line)
        }
    }
    
    @inlinable
    public func callAsFunction(message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(level, { Message(stringLiteral: message()) }, metadata, file, function, line)
        }
    }
    
    @inlinable
    public func callAsFunction(_ level: Level, _ message: @autoclosure () -> Message, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(level, message, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    public func callAsFunction(_ message: @autoclosure () -> Message, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(level, message, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    public func callAsFunction(_ level: Level, message: @autoclosure () -> String, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(level, { Message(stringLiteral: message()) }, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    public func callAsFunction(message: @autoclosure () -> String, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(level, { Message(stringLiteral: message()) }, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
}


public extension Log {
    
    @inlinable
    func trace(_ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.trace, message, metadata, file, function, line)
        }
    }
    
    @inlinable
    func trace(message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.trace, { Message(stringLiteral: message()) }, metadata, file, function, line)
        }
    }
    
    @inlinable
    func trace(_ message: @autoclosure () -> Message, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.trace, message, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    func trace(message: @autoclosure () -> String, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.trace, { Message(stringLiteral: message()) }, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    
    @inlinable
    func debug(_ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.debug, message, metadata, file, function, line)
        }
    }
    
    @inlinable
    func debug(message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.debug, { Message(stringLiteral: message()) }, metadata, file, function, line)
        }
    }
    
    @inlinable
    func debug(_ message: @autoclosure () -> Message, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.debug, message, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    func debug(message: @autoclosure () -> String, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.debug, { Message(stringLiteral: message()) }, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    
    @inlinable
    func info(_ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.info, message, metadata, file, function, line)
        }
    }
    
    @inlinable
    func info(message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.info, { Message(stringLiteral: message()) }, metadata, file, function, line)
        }
    }
    
    @inlinable
    func info(_ message: @autoclosure () -> Message, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.info, message, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    func info(message: @autoclosure () -> String, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.info, { Message(stringLiteral: message()) }, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    
    @inlinable
    func notice(_ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.notice, message, metadata, file, function, line)
        }
    }
    
    @inlinable
    func notice(message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.notice, { Message(stringLiteral: message()) }, metadata, file, function, line)
        }
    }
    
    @inlinable
    func notice(_ message: @autoclosure () -> Message, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.notice, message, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    func notice(message: @autoclosure () -> String, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.notice, { Message(stringLiteral: message()) }, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    
    @inlinable
    func warning(_ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.warning, message, metadata, file, function, line)
        }
    }
    
    @inlinable
    func warning(message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.warning, { Message(stringLiteral: message()) }, metadata, file, function, line)
        }
    }
    
    @inlinable
    func warning(_ message: @autoclosure () -> Message, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.warning, message, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    func warning(message: @autoclosure () -> String, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.warning, { Message(stringLiteral: message()) }, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    
    @inlinable
    func error(_ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.error, message, metadata, file, function, line)
        }
    }
    
    @inlinable
    func error(message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.error, { Message(stringLiteral: message()) }, metadata, file, function, line)
        }
    }
    
    @inlinable
    func error(_ message: @autoclosure () -> Message, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.error, message, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    func error(message: @autoclosure () -> String, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.error, { Message(stringLiteral: message()) }, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    
    @inlinable
    func critical(_ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.critical, message, metadata, file, function, line)
        }
    }
    
    @inlinable
    func critical(message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.critical, { Message(stringLiteral: message()) }, metadata, file, function, line)
        }
    }
    
    @inlinable
    func critical(_ message: @autoclosure () -> Message, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.critical, message, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    func critical(message: @autoclosure () -> String, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.critical, { Message(stringLiteral: message()) }, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    
    @inlinable
    func alert(_ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.alert, message, metadata, file, function, line)
        }
    }
    
    @inlinable
    func alert(message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.alert, { Message(stringLiteral: message()) }, metadata, file, function, line)
        }
    }
    
    @inlinable
    func alert(_ message: @autoclosure () -> Message, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.alert, message, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    func alert(message: @autoclosure () -> String, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.alert, { Message(stringLiteral: message()) }, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    
    @inlinable
    func emergency(_ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.emergency, message, metadata, file, function, line)
        }
    }
    
    @inlinable
    func emergency(message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.emergency, { Message(stringLiteral: message()) }, metadata, file, function, line)
        }
    }
    
    @inlinable
    func emergency(_ message: @autoclosure () -> Message, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.emergency, message, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
    
    @inlinable
    func emergency(message: @autoclosure () -> String, metadata: @autoclosure () -> [AnyHashable : Any], file: String = (#file as NSString).lastPathComponent, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler(.emergency, { Message(stringLiteral: message()) }, { metadata().reduce(into: [:]) { $0[Key(stringLiteral: String(describing: $1.key))] = $1.value } }, file, function, line)
        }
    }
}


public extension Log {
    
    @propertyWrapper
    final class Atomic<T> {
        
        private let queue = DispatchQueue(label: "SwiftLogging.AtomicProperty", attributes: .concurrent)
        private var value: T
        public var wrappedValue: T {
            get { queue.sync { value } }
            set { queue.async(flags: .barrier) { self.value = newValue } }
        }
        public init(wrappedValue: T) {
            value = wrappedValue
        }
    }
}



public protocol Logging {
    
    func log(_ level: Log.Level, _ message: @autoclosure () -> Log.Message, _ metadata: @autoclosure () -> Log.Metadata, file: String, function: String, line: UInt)
}
