//
//  ItemSection.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit

public struct PowerItemSection: Hashable {
    
    //MARK: - Variables
    public var id: Int
    public var header: Section?
    public var footer: Section?
   
    //MARK: - .Init
    public init(id: Int, header: Section? = nil, footer: Section? = nil) {
        self.id = id
        self.header = header
        self.footer = footer
    }
    
    //MARK: - Section
    public class Section: Hashable {
        
        public var size: NSCollectionLayoutSize
        public var pinToVisibleBounds: Bool
        public var isVisible: Bool
        internal var cell: PowerCells!
        
        
        public init(size: NSCollectionLayoutSize, pinToVisibleBounds: Bool = false, isVisible: Bool = true) {
            self.size = size
            self.pinToVisibleBounds = pinToVisibleBounds
            self.isVisible = isVisible
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(cell.item)
        }
        
        public static func == (lhs: Section, rhs: Section) -> Bool {
            return lhs.cell.item == rhs.cell.item
        }
        
    }
    
}

//MARK: - Used For update ItemSection (header & Footer)
public struct PowerUpdateItemSection {
    
    public let cell: PowerCells?
    public let isVisible: Bool
    public let size: NSCollectionLayoutSize?
    
    public init(cell: PowerCells? = nil, isVisible: Bool = true, size: NSCollectionLayoutSize? = nil) {
        self.cell = cell
        self.isVisible = isVisible
        self.size = size
    }
    
}

