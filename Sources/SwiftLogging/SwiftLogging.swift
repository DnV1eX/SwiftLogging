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

    
    public struct Message: ExpressibleByStringInterpolation, CustomStringConvertible, CustomDebugStringConvertible {
        
        public enum Segment {
            case literal(String)
            case interpolation(Any)
            case numeric(Any)
            case `private`(Any)
            case `public`(Any)
        }
        
        public struct StringInterpolation: StringInterpolationProtocol {
            
            public var segments: [Segment] = []
            
            @inlinable public init(literalCapacity: Int, interpolationCount: Int) {
                segments.reserveCapacity(interpolationCount * 2 + 1)
            }

            @inlinable public mutating func appendLiteral(_ literal: StringLiteralType) {
                segments.append(.literal(literal))
            }
            
            @inlinable public mutating func appendInterpolation<T>(_ interpolation: T) {
                segments.append(.interpolation(interpolation))
            }
            
            @inlinable public mutating func appendInterpolation<T: Numeric>(_ numeric: T) {
                segments.append(.numeric(numeric))
            }
            
            @inlinable public mutating func appendInterpolation<T>(private: T) {
                segments.append(.private(`private`))
            }
            
            @inlinable public mutating func appendInterpolation<T>(public: T) {
                segments.append(.public(`public`))
            }
        }
        
        public static func hashing(_ value: Any) -> String {
            "<\(withUnsafeBytes(of: String(reflecting: value).hashValue) { Data($0) }.base64EncodedString())>"
        }
        
        public let segments: [Segment]
        
        public init(stringLiteral value: StringLiteralType) {
            segments = [.literal(value)]
        }
        
        public init(stringInterpolation: StringInterpolation) {
            segments = stringInterpolation.segments
        }
        
        public var description: String {
            segments.reduce(into: "") { result, segment in
                switch segment {
                case let .literal(literal):
                    result.append(literal)
                case let .public(interpolation),
                     let .numeric(interpolation):
                    result.append(String(describing: interpolation))
                case let .private(interpolation),
                     let .interpolation(interpolation):
                    result.append(Self.hashing(interpolation))
                }
            }
        }
        
        public var debugDescription: String {
            segments.reduce(into: "") { result, segment in
                switch segment {
                case let .literal(literal):
                    result.append(literal)
                case let .public(interpolation),
                     let .numeric(interpolation),
                     let .private(interpolation),
                     let .interpolation(interpolation):
                    result.append(String(describing: interpolation))
                }
            }
        }
    }
    
    
    public struct Key: Hashable, Equatable, ExpressibleByStringInterpolation, CustomStringConvertible {
        
        public let string: String
        
        public init(stringLiteral value: StringLiteralType) {
            string = value
        }
        
        public var description: String {
            string
        }
    }
    
    
    public typealias Metadata = [Key : Any]
    
    public typealias Settings = (label: String, level: Level, privacy: Bool, metadata: Metadata)
    
    public typealias Handlers = (Settings) -> [Handler]
    
    public typealias Handler = (_ level: Level, _ message: () -> Message, _ metadata: () -> Metadata, _ file: String, _ function: String, _ line: UInt) -> Void
    
    public typealias Parameters = (level: Level, message: () -> Message, metadata: () -> Metadata, file: String, function: String, line: UInt)
    

    @_functionBuilder
    public enum HandlerBuilder {
        
        public static func buildExpression(_ handler: @escaping Handler) -> [Handler] {
            [handler]
        }

        public static func buildExpression(_ handler: @escaping (Parameters) -> Void) -> [Handler] {
            [{ level, message, metadata, file, function, line in
                withoutActuallyEscaping(message) { message in
                    withoutActuallyEscaping(metadata) { metadata in
                        handler((level, message, metadata, file, function, line))
                    }
                }
            }]
        }

        public static func buildBlock(_ handlers: [Handler]...) -> [Handler] {
            Array(handlers.joined())
        }

        public static func buildOptional(_ optional: [Handler]?) -> [Handler] {
            optional ?? []
        }

        public static func buildEither(first handlers: [Handler]) -> [Handler] {
            handlers
        }

        public static func buildEither(second handlers: [Handler]) -> [Handler] {
            handlers
        }

        public static func buildArray(_ handlers: [[Handler]]) -> [Handler] {
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
    
    
    @HandlerBuilder public static func defaultHandlers(settings: Settings) -> [Handler] {
        if PrintLogging.isStandardOutputAvailable {
            PrintLogging(label: settings.label).log
        } else {
            OSLogging().log
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

    public let handlers: [Handler]
    
    @inlinable
    public init(label: String, level: Level = level, privacy: Bool = privacy, metadata: Metadata = metadata, @HandlerBuilder handlers: Handlers = handlers) {
        
        self.label = label
        self.level = level
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
}



public protocol Logging {
    
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
