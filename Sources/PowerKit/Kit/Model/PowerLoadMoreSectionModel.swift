//
//  PowerLoadMoreSectionModel.swift
//  CTS
//
//  Created by adel radwan on 16/10/2022.
//

import UIKit

public class PowerLoadMoreModel {
   
    let alignment: NSRectAlignment
    var cell: PowerCells?
    var item: Item
    
    init(alignment: NSRectAlignment, cell: PowerCells? = nil, item: Item) {
        self.alignment = alignment
        self.cell = cell
        self.item = item
        if let cell {
            self.cell = cell
        }else {
            let model = PowerModel<PowerLoadMoreCell, PowerLoadMoreModel.Item>(item: item)
            self.cell = model
        }
    }
    
    public class Item: Hashable {
        var currentPage: Int
        var lastPage: Int
        
        init(currentPage: Int, lastPage: Int) {
            self.currentPage = currentPage
            self.lastPage = lastPage
        }
        
        public static func == (lhs: PowerLoadMoreModel.Item, rhs: PowerLoadMoreModel.Item) -> Bool {
            return lhs.currentPage == rhs.currentPage
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(currentPage)
        }
        
    }
    
}
