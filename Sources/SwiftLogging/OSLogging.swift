//
//  OSLogging.swift
//  SwiftLogging
//
//  Created by Alexey Demin on 2021-02-12.
//  Copyright © 2021 DnV1eX. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//

import OSLog


public struct OSLogging {
    
    public let settings: Log.Settings
    
    public let osLog: OSLog
    
    
    public init(subsystem: String, category: String = "", level: Log.Level = .notice, privacy: Bool = true, metadata: Log.Metadata = [:]) {
        
        settings = (subsystem, level, privacy, metadata)
        osLog = OSLog(subsystem: subsystem, category: category)
    }
    
    
    public func log(_ level: Log.Level, _ message: @autoclosure () -> Log.Message, _ metadata: @autoclosure () -> Log.Metadata, file: String, function: String, line: UInt) {
        
        guard level >= settings.level else { return }

        var message = settings.privacy ? message().description : message().debugDescription

        let metadata = settings.metadata.merging(metadata()) { $1 }
        if !metadata.isEmpty {
            message.append(" \(settings.privacy ? metadata.mapValues(Log.Message.hashing) : metadata)")
        }

        if !settings.privacy {
            message.append(" - \(file):\(line).\(function)")
        }
        
        os_log("%{public}s", log: osLog, type: OSLogType(level), message)
    }
}



public extension Log.Level {
    
    static let fault = critical
}



extension OSLogType {
    
    init(_ level: Log.Level) {
        switch level {
        case ..<(.info): self = .debug
        case ..<(.notice): self = .info
        case ..<(.warning): self = .default
        case ..<(.fault): self = .error
        default: self = .fault
        }
    }
}
