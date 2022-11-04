//
//  PowerEmptyView.swift
//  CTS
//
//  Created by adel radwan on 14/10/2022.
//

import UIKit
import SnapKit

public class PowerEmptyView: PowerView  {
    
    
    //MARK: - Variables
    @Published open private(set) var isActionButtonClicked: Bool?
    
    public enum LayoutPosition {
        case top, middle, bottom
    }
    
    public enum ViewType: String {
        case empty = "EmptyData"
        case network = "noConnection"
    }
    
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 24) {
        didSet {
            self.titleLabel.font = self.titleFont
        }
    }
    
    public var messageFont: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            self.messageLabel.font = self.messageFont
        }
    }
    
    public var titleColor: UIColor = UIColor.systemGray {
        didSet {
            self.titleLabel.textColor = self.titleColor
        }
    }

    public var messageColor: UIColor = UIColor.systemGray2 {
        didSet {
            self.titleLabel.textColor = self.messageColor
        }
    }
    
    public var actionButtonBackgroundColor: UIColor = UIColor.systemRed {
        didSet {
            self.actionButton.backgroundColor = self.actionButtonBackgroundColor
        }
    }
    
    public var actionButtonTextColor: UIColor = UIColor.white {
        didSet {
            self.actionButton.setTitleColor(self.actionButtonTextColor, for: .normal)
        }
    }
    
    public var actionButtonFont: UIFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            self.actionButton.titleLabel?.font = self.actionButtonFont
        }
    }
    
    //MARK: - UI Variables
    private var holderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var animationView: LottieAnimationView = {
        let v = LottieAnimationView()
        v.backgroundBehavior = .pauseAndRestore
        v.loopMode = .autoReverse
        v.contentMode = .scaleAspectFit
        v.backgroundColor = .clear
        return v
    }()
    
    private lazy var imageView: UIImageView  = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
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
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(actionButtonTextColor, for: .normal)
        button.backgroundColor = actionButtonBackgroundColor
        button.addTarget(self, action: #selector(didActionButtonClicked), for: .touchUpInside)
        button.titleLabel?.font = actionButtonFont
        return button
    }()
    
    private lazy var titleMessageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        stackView.spacing = 12
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var imageStackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [imageView, animationView, titleMessageStackView, UIView()])
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageStackView, actionButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.setCustomSpacing(45, after: imageStackView)
        return stackView
    }()
    
    
    //MARK: - LifeCycle
    public override func setupViews() {
        settings()
        setupUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        componentsLayout()
    }
    
    //MARK: - Configure
   open func configure(
        viewType: ViewType, layoutPosition: LayoutPosition = .middle,
        imageView: UIImage? = nil,
        title: String = "لاتوجد بيانات",
        message: String = "يبدو أنه لا توجد بيانات ليتم عرضها",
        actionButtonTitle: String? = nil
    ) {
        change(position: layoutPosition)
        setAnimationImageView(viewType.rawValue)
        setImageView(imageView)
        setActionButton(actionButtonTitle)
        titleLabel.text = title
        messageLabel.text = message
    }
    
}

//MARK: - Settings
private extension PowerEmptyView {
    
    func settings() {
        backgroundColor = .clear
    }
    
    func componentsLayout() {
        actionButton.layer.cornerRadius = 6
        actionButton.layer.masksToBounds = true
    }
    
    func setupUI() {
        addSubview(holderView)
        remakeHolderViewConstraintUsing { $0.centerY.equalToSuperview().offset(-40) }
        
        holderView.addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        setHeightConstantFor([animationView, imageView], value: 170)
        
        actionButton.snp.updateConstraints {
            $0.width.equalTo(holderView)
            $0.height.equalTo(54)
        }
        
    }
    
    func remakeHolderViewConstraintUsing(marker: (_ view: ConstraintMaker) -> ()) {
        holderView.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(PowerDevices.isIphone ? 0.85 : 0.6)
            marker($0)
        }
    }
    
    func setHeightConstantFor(_ views: [UIView], value: CGFloat) {
        views.forEach {
            $0.snp.updateConstraints { make in
                make.height.equalTo(value)
            }
        }
    }
    
}

//MARK: - Events

extension PowerEmptyView {
    
    @objc private func didActionButtonClicked() {
        self.isActionButtonClicked = true
    }
    
    func change(position: LayoutPosition) {
        switch position {
        case .middle:
            remakeHolderViewConstraintUsing { $0.centerY.equalToSuperview().offset(-40) }
        case .top:
            remakeHolderViewConstraintUsing { $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(8) }
        case .bottom:
            remakeHolderViewConstraintUsing { $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(8) }
        }
        self.layoutIfNeeded()
    }
    
    func setAnimationImageView(_ fileName: String) {
        let animation = LottieAnimation.named(fileName)
        self.animationView.animation = animation
        self.animationView.reloadImages()
        self.playAnimation()
    }
    
    
    func playAnimation(){
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.animationView.play()
        }
    }
    
    func setImageView(_ image: UIImage? = nil) {
        if let image {
            self.imageView.image = image
            self.imageView.isHidden = false
            self.animationView.isHidden = true
        } else {
            self.imageView.isHidden = true
            self.animationView.isHidden = false
        }
    }
    
    func setActionButton(_ title: String? = nil) {
        if let title {
            self.actionButton.setTitle(title, for: .normal)
            self.actionButton.isHidden = false
        } else {
            self.actionButton.isHidden = true
        }
    }
    
    
}
