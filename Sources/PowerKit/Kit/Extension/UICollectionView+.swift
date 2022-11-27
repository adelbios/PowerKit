//
//  UITableView+.swift
//  Shour
//
//  Created by Adel Radwan on 09/11/2021.
//

import UIKit

#if canImport(SkeletonView)
import SkeletonView
#endif

internal extension UICollectionView {
    
    enum ElementKind {
        case footer
        case header
        
        var value: String {
            switch self {
            case .footer:
                return  UICollectionView.elementKindSectionFooter
            case .header:
                return  UICollectionView.elementKindSectionHeader
            }
        }
    }
    
    
    func register<T: UICollectionViewCell>(_ cell: T.Type, fromNib: Bool = false){
        switch fromNib {
        case true:
            self.register(UINib(nibName: "\(cell)", bundle: Bundle.main), forCellWithReuseIdentifier: "\(cell)")
        case false:
            self.register(cell, forCellWithReuseIdentifier: "\(cell)")
        }
    }
    
    func register<T: UICollectionViewCell>(_ cell: T.Type, kind: ElementKind, fromNib: Bool = false){
        switch fromNib {
        case true:
            self.register(
                UINib(nibName: "\(cell)", bundle: Bundle.main),
                forSupplementaryViewOfKind: kind.value,
                withReuseIdentifier: "\(cell)"
            )
        case false:
            self.register(cell, forSupplementaryViewOfKind: kind.value, withReuseIdentifier: "\(cell)")
        }
    }
    
    func dequeue<T: UICollectionViewCell>(_ cell: T.Type, indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: "\(cell)", for: indexPath) as! T
    }
    
    func dequeue<T: UICollectionViewCell>(_ cell: T.Type, kind: ElementKind, indexPath: IndexPath) -> T {
        return self.dequeueReusableSupplementaryView(ofKind: kind.value, withReuseIdentifier: "\(cell)", for: indexPath) as! T
    }
    
    //Skeleton
    func startSkeleton(){
        #if canImport(SkeletonView)
        self.prepareSkeleton { [weak self] _ in
            guard let self = self else { return }
            self.showAnimatedGradientSkeleton(transition: .none)
        }
        #endif
    }
    
    func stopSkeleton(){
        #if canImport(SkeletonView)
        self.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.5))
        #endif
    }
    
    //MARK: - Pull to refresh
    func pullToRefreh(_ completion: @escaping ()-> Void){
        let headerView = NormalHeaderAnimator()
        headerView.transform = .init(scaleX: -1.0, y: 1.0)
        headerView.pullToRefreshDescription = "إسحب للأسفل للتحديث"
        headerView.releaseToRefreshDescription = "اترك لبدء التحديث"
        headerView.loadingDescription = "جاري التحديث..."
        self.cr.addHeadRefresh(animator: headerView) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            completion()
        }
        
    }
    
    func termnatePullToRefresh(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.cr.endHeaderRefresh()
        }
    }
    
    func scroll(using indexPath: IndexPath, scrollPosition: ScrollPosition = .centeredVertically, animated: Bool = true) {
        self.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    func select(item using: IndexPath, animated: Bool = true, scrollPosition: ScrollPosition = .centeredVertically) {
        self.selectItem(at: using, animated: animated, scrollPosition: scrollPosition)
    }
    
    func select(index: Int, animated: Bool = true, scrollPosition: ScrollPosition = .centeredVertically) {
        self.selectItem(at: IndexPath(item: index, section: 0), animated: animated, scrollPosition: scrollPosition)
    }
    
    func deSelect(index: Int, animated: Bool = true) {
        self.deselectItem(at: IndexPath(item: index, section: 0), animated: animated)
    }
    
}

public extension NSCollectionLayoutSize {
    
    static func dynamic(estimatedValue: CGFloat) -> NSCollectionLayoutSize {
        return .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(estimatedValue))
    }
    
    static func fixd(height: CGFloat) -> NSCollectionLayoutSize {
        return .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
    }
    
    static func setDimension(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension) -> NSCollectionLayoutSize {
        return .init(widthDimension: width, heightDimension: height)
    }
    
}
