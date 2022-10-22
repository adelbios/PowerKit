//
//  PowerCollectionCell.swift
//  PowerHomeKit
//
//  Created by adel radwan on 21/10/2022.
//

import UIKit
#if canImport(SkeletonView)
import SkeletonView
#endif

open class PowerCollectionCell: UICollectionViewCell {
    
    //MARK: - LifeCycle
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    open func setupViews(){
    }
    
    open func enableSkeletoneFor(_ views: [UIView]){
        views.forEach {
        #if canImport(SkeletonView)
            $0.isSkeletonable = true
        #endif
        }
    }
    
}
