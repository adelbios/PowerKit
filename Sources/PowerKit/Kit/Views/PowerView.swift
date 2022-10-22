//
//  PowerView.swift
//  CTS
//
//  Created by adel radwan on 14/10/2022.
//

import UIKit
#if canImport(SkeletonView)
import SkeletonView
#endif

open class PowerView: UIView {

    
    //MARK: - LifeCycle
    required public init?(coder aDecoder: NSCoder) { fatalError() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    open func enableSkeletoneFor(_ views: [UIView]){
        views.forEach {
            #if canImport(SkeletonView)
            $0.isSkeletonable = true
            #endif
        }
    }
    
    @objc open dynamic func setupViews() {
        self.backgroundColor = .white
    }
    
}
