//
//  ItemSection.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit

public class PowerItemSection {
    
    //MARK: - Variables
    public var size: NSCollectionLayoutSize
    public var pinToVisibleBounds: Bool
    internal var cell: PowerCells!
    internal var sectionIndex: Int!
   
    //MARK: - .Init
    public init(size: NSCollectionLayoutSize, pinToVisibleBounds: Bool = false) {
        self.size = size
        self.pinToVisibleBounds = pinToVisibleBounds
    }
    
}

extension PowerItemSection: Hashable {

    public static func == (lhs: PowerItemSection, rhs: PowerItemSection) -> Bool {
        lhs.cell == rhs.cell
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.cell)
    }

}
