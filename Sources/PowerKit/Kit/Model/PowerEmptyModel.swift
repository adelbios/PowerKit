//
//  PowerEmptyModel.swift
//  CTS
//
//  Created by adel radwan on 16/10/2022.
//

import Foundation

public struct PowerEmptyModel: Hashable {
    
    let title: String
    let message: String
    
   public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
    
}
