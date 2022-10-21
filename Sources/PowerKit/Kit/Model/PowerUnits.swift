//
//  PowerUnits.swift
//  PowerHomeKit
//
//  Created by adel radwan on 21/10/2022.
//

import Foundation

public struct PowerUnits {
    
    public let bytes: Int64
    
    public var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
    public var megabytes: Double {
        return kilobytes / 1_024
    }
    
    public var gigabytes: Double {
        return megabytes / 1_024
    }
    
    public init(bytes: Int64) {
        self.bytes = bytes
    }
    
    public var readable: String {
        switch bytes {
        case 0..<1_024:
            return "Bytes \(bytes)"
        case 1_024..<(1_024 * 1_024):
            return "KB \(String(format: "%.2f", kilobytes))"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "MB \(String(format: "%.2f", megabytes))"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "GB \(String(format: "%.2f", gigabytes))"
        default:
            return "Bytes \(bytes)"
        }
    }
    
    public var readablePrefexUnit: String {
        switch bytes {
        case 0..<1_024:
            return "\(bytes) Bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) KB"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) MB"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) GB"
        default:
            return "\(bytes) Bytes"
        }
    }
    
    
}
