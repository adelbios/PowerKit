//
//  PowerCollectionView.swift
//  CTS
//
//  Created by adel radwan on 17/10/2022.
//

import UIKit

open class PowerCollectionView: UICollectionView {
    
    //MARK: - Variables
    public let emptyView = PowerEmptyView()
    
    var mode: BackgroundViewMode = .without
    
    public enum BackgroundViewMode {
        case error
        case empty
        case without
    }
    
    //MARK: - LifeCycle
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        settings()
    }
}

//MARK: - Puplic Settings
public extension PowerCollectionView {

    
    func setBackground(mode: BackgroundViewMode) {
        self.backgroundView = (mode == .empty || mode == .error) ? emptyView : nil
        self.mode = mode
    }
    
    func setInsit(_ value: UIEdgeInsets) {
        self.contentInset = value
        self.verticalScrollIndicatorInsets = value
    }
    
}

//MARK: - Settings
private extension PowerCollectionView {
    
    func settings() {
        keyboardDismissMode = .interactive
        alwaysBounceVertical = true
    }

}

