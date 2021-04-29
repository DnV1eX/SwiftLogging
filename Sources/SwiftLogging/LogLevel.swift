//
//  LogLevel.swift
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
    
    struct Level {
        public let severity: Double
    }
}


extension Log.Level: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: FloatLiteralType) {
        severity = value
    }
}


extension Log.Level: Comparable {

    public static func < (lhs: Log.Level, rhs: Log.Level) -> Bool {
        lhs.severity < rhs.severity
    }
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
