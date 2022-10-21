//
//  NSObject+.swift
//  PowerHomeKit
//
//  Created by adel radwan on 21/10/2022.
//

import UIKit

extension NSObject {
    
    class var name: String { return String(describing: self) }
    
    var className : String { return String(describing: self).components(separatedBy: ":")[0] }
    
}

public enum LogType: String{ case error, warning, success, action, canceled, deinitValue }

public func log(type: LogType = .warning, _ items: Any..., filename: String = #file, function : String = #function, line: Int = #line,
                separator: String = " ", terminator: String = "\n") {
    
    #if DEBUG
    let pretty = "\(URL(fileURLWithPath: filename).lastPathComponent) [#\(line)] \(function) -> "
    let output = items.map { "\($0)" }.joined(separator: separator)
    
    switch type {
    case LogType.error:
        Swift.print("🔞 Error: -> ",pretty+output, terminator: terminator)
    case LogType.warning:
        Swift.print("⚠️ Warning: -> ",pretty+output, terminator: terminator)
    case LogType.success:
        Swift.print("✅ Success: -> ",pretty+output, terminator: terminator)
    case LogType.action:
        Swift.print("🗄 Action: -> ",pretty+output, terminator: terminator)
    case LogType.canceled:
        Swift.print("❌ Cancelled: -> ",pretty+output, terminator: terminator)
    case LogType.deinitValue:
        Swift.print("🤡 Deinit: -> ",pretty+output, terminator: terminator)
    }
    
    #else
    Swift.print("RELEASE MODE")
    #endif
}
