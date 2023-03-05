//
//  PowerUpdatedModel.swift
//  DemoPowerKit
//
//  Created by adel radwan on 20/11/2022.
//

import Foundation

open class PowerUpdatedModel {
        
    open var newItem: PowerCells
    open var oldItem: PowerCells
    
    public init(oldItem: PowerCells, newItem: PowerCells) {
        self.newItem = newItem
        self.oldItem = oldItem
    }
    
}
