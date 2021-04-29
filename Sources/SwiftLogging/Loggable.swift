//
//  Loggable.swift
//  SwiftLogging
//
//  Created by Alexey Demin on 2021-02-24.
//  Copyright © 2021 DnV1eX. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//

import Foundation


public protocol Loggable {
    
    static var log: Log { get }
    var log: Log { get }
}


public extension Loggable {
    
    var log: Log { Self.log }
    
    static var defaultLog: Log { Log(label: String(reflecting: self)) }
}
