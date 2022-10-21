//
//  Data+.swift
//  PowerHomeKit
//
//  Created by adel radwan on 21/10/2022.
//

import Foundation

extension Data {
    
    func toJSON(){
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return }
        return debugPrint(prettyPrintedString)
    }
    
    var toJSONString: String {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return "" }
        return prettyPrintedString as String
    }
    
    func saveDocumentData(fileName: String) {
        
    }
    
}
