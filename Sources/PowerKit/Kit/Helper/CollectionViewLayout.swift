//
//  CollectionViewLayout.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit

open class CollectionViewLayout {
    
    open var estematedValue: CGFloat = 100
    open var itemSpacing: UIEdgeInsets = .init(top: 8, left: 0, bottom: 0, right: 0)
    open var groupSpacing: UIEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 20)
    open var sectionInset: NSDirectionalEdgeInsets = .zero
    
    open func verticalDynamicLayout() -> NSCollectionLayoutSection {
        let size = set(width: .fractionalWidth(1))
        let item = createItem(size: size)
        let group = createVerticalGroup(size: size, item: item)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInset
        return section
    }
    
    open func horizontalDynamicLayout() -> NSCollectionLayoutSection {
        let itemSize = set(width: .fractionalWidth(1))
        let item = createItem(size: itemSize)
        let group = createHorizontalGroup(size: set(width: .fractionalWidth(0.9)), item: item)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = sectionInset
        return section
    }
    
    open func gridLayout(numberOfItemPerRows: Int) -> NSCollectionLayoutSection {
        let itemSize: NSCollectionLayoutSize  = .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = .init(leading: .none, top: .fixed(16), trailing: .none, bottom: .none)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitem: item, count: numberOfItemPerRows)
        group.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        group.interItemSpacing = .fixed(8)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInset
        return section
    }
    
    public init() {
    }
   
    
}

//MARK: - Helper
private extension CollectionViewLayout {
    
    func fullWidthLayoutSize(height: NSCollectionLayoutDimension) -> NSCollectionLayoutSize {
        return .init(widthDimension: .fractionalWidth(1), heightDimension: height)
    }
    
    func set(width: NSCollectionLayoutDimension) -> NSCollectionLayoutSize {
        return .init(widthDimension: width, heightDimension: .estimated(estematedValue))
    }
    
    
    func createItem(size: NSCollectionLayoutSize) -> NSCollectionLayoutItem {
        let item = NSCollectionLayoutItem(layoutSize: size)
        item.edgeSpacing = .init(
            leading: .fixed(itemSpacing.left),
            top: .fixed(itemSpacing.top),
            trailing: .fixed(itemSpacing.right),
            bottom: .fixed(itemSpacing.bottom)
        )
        return item
    }
    
    func createVerticalGroup(size: NSCollectionLayoutSize, item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        group.contentInsets = .init(
            top: groupSpacing.top,
            leading: groupSpacing.left,
            bottom: groupSpacing.bottom,
            trailing: groupSpacing.right
        )
        return group
    }
    

    
    func createHorizontalGroup(size: NSCollectionLayoutSize, item: NSCollectionLayoutItem) -> NSCollectionLayoutGroup {
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
        group.contentInsets = .init(
            top: groupSpacing.top,
            leading: groupSpacing.left,
            bottom: groupSpacing.bottom,
            trailing: groupSpacing.right
        )
        return group
    }
    
}
