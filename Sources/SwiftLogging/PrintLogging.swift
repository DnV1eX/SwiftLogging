//
//  PrintLogging.swift
//  SwiftLogging
//
//  Created by Alexey Demin on 2021-02-26.
//  Copyright © 2021 DnV1eX. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//

import Foundation


public struct PrintLogging {
    
    /// Whether the standard output is associated with a terminal.
    public static var isStandardOutputAvailable: Bool {
        isatty(STDOUT_FILENO) != 0
    }

    
    public let settings: Log.Settings
    public let items: ItemOptions
    
    public let dateFormatter: ISO8601DateFormatter?

    
    public init(source: String, level: Log.Level = .trace, privacy: Bool = false, metadata: Log.Metadata = [:], items: ItemOptions = .default) {
        
        settings = (source, level, privacy, metadata)
        self.items = items
        
        if !items.isDisjoint(with: .fullDateTime) {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.timeZone = .autoupdatingCurrent
            dateFormatter.formatOptions = .withSpaceBetweenDateAndTime
            if items.contains(.date) {
                dateFormatter.formatOptions.formUnion(.withFullDate)
            }
            if items.contains(.time) {
                dateFormatter.formatOptions.formUnion([.withTime, .withColonSeparatorInTime])
            }
            if items.contains(.fractionalSeconds) {
                dateFormatter.formatOptions.formUnion(.withFractionalSeconds)
            }
            if items.contains(.timeZone) {
                dateFormatter.formatOptions.formUnion([.withTimeZone, .withColonSeparatorInTimeZone])
            }
            self.dateFormatter = dateFormatter
        } else {
            self.dateFormatter = nil
        }
    }
    
    
    public func log(_ level: Log.Level, _ message: @autoclosure () -> Log.Message, _ metadata: @autoclosure () -> Log.Metadata, file: String, function: String, line: UInt) {
        
        guard level >= settings.level else { return }
        
        var text = ""
        
        if let dateFormatter = dateFormatter {
            if level < .info {
                text.append("\(Double(DispatchTime.now().uptimeNanoseconds) / 1e9) ")
            } else {
                let date = dateFormatter.string(from: Date())
                if !date.isEmpty {
                    text.append("\(date) ")
                }
            }
        }
        
        if items.contains(.source) {
            text.append("'\(settings.label)' ")
        }

        if items.contains(.severity) {
            text.append("\(level.mark) ")
        }

        text.append(settings.privacy ? message().description : message().debugDescription)
        
        if !items.isDisjoint(with: .metadata) {
            let metadata = settings.metadata.merging(metadata()) { $1 }
            if !metadata.isEmpty {
                if items.contains(.metadata) {
                    text.append(" \(settings.privacy ? metadata.mapValues(Log.Message.hashing) : metadata)")
                }
                else if items.contains(.metadataKeys) || (settings.privacy && items.contains(.metadataValues)) {
                    text.append(" \(metadata.keys)")
                }
                else {
                    text.append(" \(metadata.values)")
                }
            }
        }

        if !settings.privacy, !items.isDisjoint(with: .sourceLocation) {
            text.append(" - ")
            if items.contains(.file) {
                text.append(file)
            }
            if items.contains(.line) {
                text.append(":\(line)")
            }
            if items.contains(.function) {
                text.append(".\(function)")
            }
        }
        
        print(text)
    }
}


public extension PrintLogging {
    
    struct ItemOptions: OptionSet {
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let date = Self(rawValue: 1 << 0)
        public static let time = Self(rawValue: 1 << 1)
        public static let fractionalSeconds = Self(rawValue: 1 << 2)
        public static let timeZone = Self(rawValue: 1 << 3)
        
        public static let severity = Self(rawValue: 1 << 4)
        
        public static let source = Self(rawValue: 1 << 5)
        
        public static let metadataKeys = Self(rawValue: 1 << 6)
        public static let metadataValues = Self(rawValue: 1 << 7)
        
        public static let file = Self(rawValue: 1 << 8)
        public static let function = Self(rawValue: 1 << 9)
        public static let line = Self(rawValue: 1 << 10)
        
        public static let timestamp: Self = [time, fractionalSeconds]
        public static let fullDateTime: Self = [date, time, fractionalSeconds, timeZone]
        public static let metadata: Self = [metadataKeys, metadataValues]
        public static let sourceLocation: Self = [file, function, line]
        
        public static let message: Self = []
        public static let brief: Self = [fractionalSeconds, severity, source, metadataValues]
        public static let `default`: Self = [timestamp, severity, source, metadata]
        public static let all: Self = [fullDateTime, severity, source, metadata, sourceLocation]
    }
}



public extension Log.Level {
    
    var mark: Character {
        switch self {
        case ..<(.debug): return "⚪️"
        case ..<(.info): return "🔵"
        case ..<(.notice): return "🟢"
        case ..<(.warning): return "🟡"
        case ..<(.error): return "🟠"
        case ..<(.critical): return "🔴"
        case ..<(.alert): return "🟣"
        case ..<(.emergency): return "🟤"
        default: return "⚫️"
        }
    }
}
