//
//  LogMessage.swift
//  SwiftLogging
//
//  Created by Alexey Demin on 2021-04-29.
//  Copyright © 2021 DnV1eX. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//

import Foundation


public extension Log {
    
    struct Message {
        
        public enum Segment {
            case literal(String)
            case `default`(Any)
            case numeric(Any)
            case `private`(Any)
            case `public`(Any)
            case custom(Any, stringConversion: (Any) -> String, debugStringConversion: (Any) -> String)
        }

        public let segments: [Segment]
        
        public static func hashing(_ value: Any) -> String {
            "<\(withUnsafeBytes(of: String(reflecting: value).hashValue) { Data($0) }.base64EncodedString())>"
        }
    }
}


extension Log.Message: ExpressibleByStringInterpolation {
    
    public struct StringInterpolation: StringInterpolationProtocol {
        
        public var segments: [Segment] = []
        
        @inlinable public init(literalCapacity: Int, interpolationCount: Int) {
            segments.reserveCapacity(interpolationCount * 2 + 1)
        }

        @inlinable public mutating func appendLiteral(_ literal: StringLiteralType) {
            segments.append(.literal(literal))
        }
        
        @inlinable public mutating func appendInterpolation<T>(_ interpolation: T) {
            segments.append(.default(interpolation))
        }
        
        @inlinable public mutating func appendInterpolation<T: Numeric>(_ interpolation: T) {
            segments.append(.numeric(interpolation))
        }
        
        @inlinable public mutating func appendInterpolation<T>(private interpolation: T) {
            segments.append(.private(interpolation))
        }
        
        @inlinable public mutating func appendInterpolation<T>(public interpolation: T) {
            segments.append(.public(interpolation))
        }
    }
    
    public init(stringLiteral value: StringLiteralType) {
        segments = [.literal(value)]
    }
    
    public init(stringInterpolation: StringInterpolation) {
        segments = stringInterpolation.segments
    }
}


extension Log.Message: CustomStringConvertible {
    
    public var description: String {
        segments.reduce(into: "") { result, segment in
            switch segment {
            case let .literal(literal):
                result.append(literal)
            case let .public(interpolation),
                 let .numeric(interpolation):
                result.append(String(describing: interpolation))
            case let .private(interpolation),
                 let .default(interpolation):
                result.append(Self.hashing(interpolation))
            case let .custom(interpolation, stringConversion, _):
                result.append(stringConversion(interpolation))
            }
        }
    }
}


extension Log.Message: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        segments.reduce(into: "") { result, segment in
            switch segment {
            case let .literal(literal):
                result.append(literal)
            case let .public(interpolation),
                 let .numeric(interpolation),
                 let .private(interpolation),
                 let .default(interpolation):
                result.append(String(describing: interpolation))
            case let .custom(interpolation, _, debugStringConversion):
                result.append(debugStringConversion(interpolation))
            }
        }
    }
}
