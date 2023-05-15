//
//  PowerLoadMoreCell.swift
//  CTS
//
//  Created by adel radwan on 16/10/2022.
//

import UIKit

open class PowerLoadMoreCell: UICollectionViewCell {
    
    //MARK: - UI Variables
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        return view
    }()
   
    //MARK: - LifeCycle
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        settings()
        setupUI()
    }
    
}
//MARK: - PowerCellDelegate
extension PowerLoadMoreCell: PowerCellDelegate {
    
   public func configure(data: PaginationModel) {
        let hasNextItem = data.isRequestMoreFire
        hasNextItem ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
}


//MARK: -  Settings
extension PowerLoadMoreCell {
    
    func settings() {
        backgroundColor = .clear
    }
    
    func setupUI() {
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(10)
        }
    }
  
}
