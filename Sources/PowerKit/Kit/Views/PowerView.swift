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

public class PowerView: UIView {

    
    //MARK: - LifeCycle
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public func enableSkeletoneFor(_ views: [UIView]){
        views.forEach {
            #if canImport(SkeletonView)
            $0.isSkeletonable = true
            #endif
        }
    }
    
    @objc public dynamic func setupViews() {
        self.backgroundColor = .white
    }
    
}
