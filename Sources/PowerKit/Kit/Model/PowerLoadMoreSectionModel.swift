//
//  PowerLoadMoreSectionModel.swift
//  CTS
//
//  Created by adel radwan on 16/10/2022.
//

import UIKit

open class PowerLoadMoreModel {
   
    public let alignment: NSRectAlignment
    open  var cell: PowerCells?
    open var item: Item
    
    public init(alignment: NSRectAlignment, cell: PowerCells? = nil, item: Item) {
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
    
    open class Item: Hashable {
       public var currentPage: Int
       public var lastPage: Int
        
        public init(currentPage: Int, lastPage: Int) {
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
