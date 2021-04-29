//
//  LogHandler.swift
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
    
    typealias Handler = (_ level: Level, _ message: () -> Message, _ metadata: () -> Metadata, _ file: String, _ function: String, _ line: UInt) -> Void
    

    @resultBuilder
    enum HandlerBuilder {
        
        public typealias Parameters = (level: Level, message: () -> Message, metadata: () -> Metadata, file: String, function: String, line: UInt)
        
        
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
}
