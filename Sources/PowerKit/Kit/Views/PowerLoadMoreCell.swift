//
//  PowerLoadMoreCell.swift
//  CTS
//
//  Created by adel radwan on 16/10/2022.
//

import UIKit

class PowerLoadMoreCell: PowerCollectionCell {
    
    //MARK: - UI Variables
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        return view
    }()
   
    //MARK: - LifeCycle
    override func setupViews() {
        settings()
        setupUI()
    }
    
}
//MARK: - PowerCellDelegate
extension PowerLoadMoreCell: PowerCellDelegate {
    
    func configure(data: PowerLoadMoreModel.Item) {
        switch data.currentPage == data.lastPage {
        case true:
            activityIndicator.stopAnimating()
        case false:
            activityIndicator.startAnimating()
        }
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
