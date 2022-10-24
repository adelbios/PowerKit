//
//  ItemSection.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit

open class ItemSection {
    
    public let size: NSCollectionLayoutSize
    open var cell: PowerCells
    open var pinToVisibleBounds: Bool
   
    public init(size: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70)),
         cell: PowerCells,
         pinToVisibleBounds: Bool = false
    ) {
        self.size = size
        self.cell = cell
        self.pinToVisibleBounds = pinToVisibleBounds
    }
    
}

//MARK: - Hashable
extension ItemSection: Hashable {
   
    public static func == (lhs: ItemSection, rhs: ItemSection) -> Bool {
        return lhs.cell == rhs.cell
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cell)
    }
    
    
}
