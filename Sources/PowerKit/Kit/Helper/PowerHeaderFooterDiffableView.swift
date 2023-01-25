//
//  File.swift
//
//
//  Created by adel radwan on 27/11/2022.
//

import UIKit

struct PowerHeaderFooterDiffableView {
    
    func build(
        settings: [PowerItemModel], status: PowerNetwork.RequestStatus, kind: String, collectionView: UICollectionView,
        indexPath: IndexPath, action: PowerActionListProxy
    ) -> UICollectionReusableView? {
        switch status {
        case .loading:
            return emptyCell(collectionView: collectionView, indexPath: indexPath, kind: kind)
        case .finished:
            return configure(settings: settings, collectionView: collectionView, indexPath: indexPath, kind: kind, action: action)
        }
    }
    
    
}

//MARK: - Header & Footer
private extension PowerHeaderFooterDiffableView {
    
    
    func configure(settings: [PowerItemModel], collectionView: UICollectionView, indexPath: IndexPath, kind: String,
                   action: PowerActionListProxy) -> UICollectionReusableView? {
        
        let type = kind == UICollectionView.elementKindSectionHeader ? true : false
        return reusableViews(
            settings: settings, collectionView: collectionView, isHeader: type,
            indexPath: indexPath, kind: kind, action: action
        )
        
    }
    
    
}


//MARK: - Section
private extension PowerHeaderFooterDiffableView {
    
    func reusableViews(
        settings: [PowerItemModel], collectionView: UICollectionView, isHeader: Bool, indexPath: IndexPath, kind: String,
        action: PowerActionListProxy) -> UICollectionReusableView? {
            
            let empty = emptyCell(collectionView: collectionView, indexPath: indexPath, kind: kind)
            let model = settings[indexPath.section]
            let sectionType = isHeader ? model.section.header : model.section.footer
            let isVisible = sectionType?.isVisible ?? true
            switch isVisible {
            case true:
                guard let section = sectionType, let reusableView = section.cell else { return empty }
                let id = type(of: reusableView).cellId
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath)
                cell.semanticContentAttribute = .forceRightToLeft
                reusableView.configure(cell: cell)
                action.invoke(action: isHeader ? .headerVisible : .footerVisible, cell: cell, configurator: reusableView, indexPath: indexPath)
                return cell
            case false:
                return empty
            }
            
        }
    
    func emptyCell(collectionView: UICollectionView, indexPath: IndexPath, kind: String) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "\(UICollectionViewCell.self)",
            for: indexPath
        )
        cell.frame.size.height = 0
        return cell
    }
    
}


