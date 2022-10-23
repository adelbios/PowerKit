//
//  RegisteredCellsModel.swift
//  CTS
//
//  Created by adel radwan on 18/10/2022.
//

import UIKit


public struct RegisteredCellsModel {
    
    public let cell: UICollectionViewCell.Type
    public let fromNib: Bool
    public let skeletonCount: Int
    public let header: Header?
    
    public init(cell: UICollectionViewCell.Type, fromNib: Bool = false, skeletonCount: Int = 0, header: Header? = nil) {
        self.cell = cell
        self.fromNib = fromNib
        self.skeletonCount = skeletonCount
        self.header = header
    }
    
    public struct Header {
        let header: UICollectionViewCell.Type
        let fromNib: Bool
        let kind = UICollectionView.elementKindSectionHeader
        
        init(_ header: UICollectionViewCell.Type, fromNib: Bool = false) {
            self.header = header
            self.fromNib = fromNib
        }
        
    }
    
}
