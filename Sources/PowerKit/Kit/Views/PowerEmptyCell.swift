//
//  PowerEmptyCell.swift
//  CTS
//
//  Created by adel radwan on 16/10/2022.
//

import UIKit

open class PowerEmptyCell: PowerCollectionCell {
    
    //MARK: - Variables
    open var titleFont: UIFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            self.titleLabel.font = self.titleFont
        }
    }
    
    open var messageFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            self.messageLabel.font = self.messageFont
        }
    }
    
    open var titleColor: UIColor = UIColor.systemGray {
        didSet {
            self.titleLabel.textColor = self.titleColor
        }
    }
    
    open var messageColor: UIColor = UIColor.systemGray2 {
        didSet {
            self.titleLabel.textColor = self.messageColor
        }
    }
    
    //MARK: - UI Variables
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = titleFont
        label.textColor = titleColor
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = messageFont
        label.textColor = messageColor
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        stackView.spacing = 12
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()
    
    //MARK: - LifeCycle
    open override func setupViews() {
        settings()
        setupUI()
    }
    
}
//MARK: -  ConfigCell
extension PowerEmptyCell: PowerCellDelegate {
    
    public func configure(data: PowerEmptyModel) {
        titleLabel.text = data.title
        messageLabel.text = data.message
    }
}

//MARK: -  Settings
private extension PowerEmptyCell {
    
    func settings() {
        backgroundColor = .clear
    }
    
    func setupUI() {
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
