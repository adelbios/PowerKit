//
//  PowerUpdatedModel.swift
//  DemoPowerKit
//
//  Created by adel radwan on 20/11/2022.
//

import Foundation

public class PowerUpdatedModel {
        
    var newItem: PowerCells
    var oldItem: PowerCells
    
    init(oldItem: PowerCells, newItem: PowerCells) {
        self.newItem = newItem
        self.oldItem = oldItem
    }
    
}
