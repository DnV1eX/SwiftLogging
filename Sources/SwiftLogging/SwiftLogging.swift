//
//  SwiftLogging.swift
//  SwiftLogging
//
//  Created by Alexey Demin on 2021-02-12.
//  Copyright © 2021 DnV1eX. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation


public struct Log {
    
    public struct Level: ExpressibleByFloatLiteral, Comparable {
        
        public let severity: Double
        
        public init(floatLiteral value: FloatLiteralType) {
            severity = value
        }

        public static func < (lhs: Log.Level, rhs: Log.Level) -> Bool {
            lhs.severity < rhs.severity
        }
    }

    
    public struct Message: ExpressibleByStringInterpolation {
        
        public struct StringInterpolation: StringInterpolationProtocol {
            
            public init(literalCapacity: Int, interpolationCount: Int) {
                
            }

            public func appendLiteral(_ literal: StringLiteralType) {
                
            }
            
            public func appendInterpolation(_ literal: StringLiteralType) {
                
            }
        }
        
        public init(stringLiteral value: StringLiteralType) {
            
        }
        
        public init(stringInterpolation: StringInterpolation) {
            
        }
    }
    
    
    public struct Key: Hashable, ExpressibleByStringInterpolation {
        
        public let string: String
        
        public init(stringLiteral value: StringLiteralType) {
            string = value
        }
    }
    
    
    public typealias Metadata = [Key : Any]
    
    public typealias Settings = (label: String, level: Level, privacy: Bool, metadata: Metadata)
    
    public typealias Handlers = (Settings) -> [LogHandler]
    

    @_functionBuilder
    public enum HandlerBuilder {
        
        public static func buildExpression(_ handler: LogHandler) -> [LogHandler] {
            [handler]
        }

        public static func buildBlock(_ handlers: [LogHandler]...) -> [LogHandler] {
            Array(handlers.joined())
        }

        public static func buildOptional(_ optional: [LogHandler]?) -> [LogHandler] {
            optional ?? []
        }

        public static func buildEither(first handlers: [LogHandler]) -> [LogHandler] {
            handlers
        }

        public static func buildEither(second handlers: [LogHandler]) -> [LogHandler] {
            handlers
        }

        public static func buildArray(_ handlers: [[LogHandler]]) -> [LogHandler] {
            Array(handlers.joined())
        }
    }
    
    /// defaultLevel
    @Atomic public static var level: Level = .info
    
    /// defaultPrivacy
    @Atomic public static var privacy: Bool = true
    
    /// defaultMetadata
    @Atomic public static var metadata: Metadata = [:]
    
    /// defaultHandlers
    @Atomic public static var handlers: Handlers = defaultHandlers
    
    
    @HandlerBuilder public static func defaultHandlers(settings: Settings) -> [LogHandler] {
        if PrintLogHandler.isStandardOutputAvailable {
            PrintLogHandler(settings: settings)
        } else {
            OSLogHandler()
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

    public let handlers: [LogHandler]
    

    public init(label: String, level: Level = level, privacy: Bool = privacy, metadata: Metadata = metadata, @HandlerBuilder handlers: Handlers = handlers) {
        
        self.label = label
        self.level = level
        self.handlers = handlers((label, level, privacy, metadata))
    }
    
    
    public func callAsFunction(_ level: Level, _ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = #file, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler.log(level, message(), metadata(), file: file, function: function, line: line)
        }
    }
    
    
    public func callAsFunction(_ message: @autoclosure () -> Message, _ metadata: @autoclosure () -> Metadata = [:], file: String = #file, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler.log(level, message(), metadata(), file: file, function: function, line: line)
        }
    }
    
    
    public func callAsFunction(_ level: Level, message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = #file, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler.log(level, Message(stringLiteral: message()), metadata(), file: file, function: function, line: line)
        }
    }
    
    
    public func callAsFunction(message: @autoclosure () -> String, _ metadata: @autoclosure () -> Metadata = [:], file: String = #file, function: String = #function, line: UInt = #line) {
        
        for handler in handlers {
            handler.log(level, Message(stringLiteral: message()), metadata(), file: file, function: function, line: line)
        }
    }
}



public protocol LogHandler {
    
    func log(_ level: Log.Level, _ message: @autoclosure () -> Log.Message, _ metadata: @autoclosure () -> Log.Metadata, file: String, function: String, line: UInt)
}



public extension Log.Level {
    
    static let trace: Self = 0.1
    static let debug: Self = 0.2
    static let info: Self = 0.3
    static let notice: Self = 0.4
    static let warning: Self = 0.5
    static let error: Self = 0.6
    static let critical: Self = 0.7
    static let alert: Self = 0.8
    static let emergency: Self = 0.9
}



public extension Log.Key {
    
    static let clientId: Self = "clientId"
    static let buildConfiguration: Self = "buildConfiguration"
    static let error: Self = "error"
    static let description: Self = "description"
}



@propertyWrapper
public final class Atomic<T> {
    
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
