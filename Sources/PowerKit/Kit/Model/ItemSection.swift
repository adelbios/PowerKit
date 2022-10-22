//
//  ItemSection.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit

public struct ItemSection {
    
    public let size: NSCollectionLayoutSize
    public let cell: PowerCells
    public let pinToVisibleBounds: Bool
   
    public init(size: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70)),
         cell: PowerCells,
         pinToVisibleBounds: Bool = false
    ) {
        self.size = size
        self.cell = cell
        self.pinToVisibleBounds = pinToVisibleBounds
    }
    
}
