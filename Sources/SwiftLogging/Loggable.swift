//
//  Loggable.swift
//  SwiftLogging
//
//  Created by Alexey Demin on 2021-02-24.
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


public protocol Loggable {
    
    static var log: Log { get }
    var log: Log { get }
}


extension Loggable {
    
    var log: Log { Self.log }
    
    static var defaultLog: Log { Log(label: String(reflecting: self)) }
}


private var key: Void = ()

extension Loggable where Self: AnyObject {
    
    static var log: Log {
        if let log = objc_getAssociatedObject(self, &key) as? Log {
            return log
        } else {
            let log = defaultLog
            objc_setAssociatedObject(self, &key, log, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return log
        }
    }
}
