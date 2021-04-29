//
//  LogMetadata.swift
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
    
    typealias Metadata = [Key : Any]

    struct Key: Hashable, Equatable {
        public let string: String
    }
}


extension Log.Key: ExpressibleByStringInterpolation {
    
    public init(stringLiteral value: StringLiteralType) {
        string = value
    }
}


extension Log.Key: CustomStringConvertible {
    
    public var description: String {
        string
    }
}


public extension Log.Key {
    
    static let clientId: Self = "clientId"
    static let buildConfiguration: Self = "buildConfiguration"
    static let error: Self = "error"
    static let description: Self = "description"
}
