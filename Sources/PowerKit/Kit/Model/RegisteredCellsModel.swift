//
//  RegisteredCellsModel.swift
//  CTS
//
//  Created by adel radwan on 18/10/2022.
//

import UIKit


struct RegisteredCellsModel {
    
    let cell: UICollectionViewCell.Type
    let fromNib: Bool
    let skeletonCount: Int
    let header: Header?
    
    init(cell: UICollectionViewCell.Type, fromNib: Bool = false, skeletonCount: Int = 2, header: Header? = nil) {
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
