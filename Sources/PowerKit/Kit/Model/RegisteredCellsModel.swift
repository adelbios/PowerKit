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
    
    //MARK: - Header
    public struct Header {
        public let cell: UICollectionViewCell.Type
        public let fromNib: Bool
        public let isSkeletonEnable: Bool
        
        public init(_ cell: UICollectionViewCell.Type, fromNib: Bool = false, isSkeletonEnable: Bool = true) {
            self.cell = cell
            self.fromNib = fromNib
            self.isSkeletonEnable = isSkeletonEnable
        }
        
    }
    
}


