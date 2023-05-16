//
//  RegisteredCellsModel.swift
//  CTS
//
//  Created by adel radwan on 18/10/2022.
//

import UIKit

public struct RegisteredCellsModel {
    
    //MARK: - .Init
    public let cell: UICollectionViewCell.Type
    public let skeletonCount: Int
    public let isHeader: Bool
    
    //MARK: - .Init
    public init(_ cell: UICollectionViewCell.Type, skeletonCount: Int = 0, isHeader: Bool = false) {
        self.cell = cell
        self.isHeader = isHeader
        if isHeader == true {
            self.skeletonCount = 0
        } else {
            self.skeletonCount = skeletonCount
        }
    }
    
}


