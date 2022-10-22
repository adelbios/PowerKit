//
//  PowerDownloadContentViewView.swift
//  CTS
//
//  Created by adel radwan on 20/10/2022.
//

import UIKit

open class PowerDownloadContentViewView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open func startAnimation() {
        self.alpha = 1
    }
    
    open func stopAnimation() {
        UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.alpha = 0
        }.startAnimation()
    }
    
}
