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
        indexPath: IndexPath, useEmptyHeader: Bool, action: PowerActionListProxy
    ) -> UICollectionReusableView? {
        
        switch status {
        case .loading:
            return emptyCell(collectionView: collectionView, indexPath: indexPath, kind: kind)
        case .finished:
            return configure(
                settings: settings, collectionView: collectionView, indexPath: indexPath,
                kind: kind, useEmptyHeader: useEmptyHeader, action: action
            )
        }
        
    }
    
    
}

//MARK: - Header & Footer
private extension PowerHeaderFooterDiffableView {
    
    
    func configure(
        settings: [PowerItemModel], collectionView: UICollectionView,
        indexPath: IndexPath, kind: String, useEmptyHeader: Bool,
        action: PowerActionListProxy) -> UICollectionReusableView?
    {
        if kind == UICollectionView.elementKindSectionHeader {
            
            switch useEmptyHeader {
            case true:
                return emptyCell(collectionView: collectionView, indexPath: indexPath, kind: kind)
            case false:
                return headerView(
                    settings: settings,
                    collectionView: collectionView,
                    indexPath: indexPath,
                    kind: kind,
                    action: action
                )
            }
        } // End Header
        
        if kind == UICollectionView.elementKindSectionFooter {
            return footerView(settings: settings, collectionView: collectionView, indexPath: indexPath, kind: kind)
        }
        
        return emptyCell(collectionView: collectionView, indexPath: indexPath, kind: kind)
    }
    
    
}


//MARK: - Header
private extension PowerHeaderFooterDiffableView {
    
    func headerView(
        settings: [PowerItemModel], collectionView: UICollectionView,
        indexPath: IndexPath, kind: String, action: PowerActionListProxy) -> UICollectionReusableView?
    {
        let emptyCell = emptyCell(collectionView: collectionView, indexPath: indexPath, kind: kind)
        let model = settings[indexPath.section]
        guard let itemSection = model.itemSection else { return emptyCell }
        guard let headerView = itemSection.cell else { return emptyCell }
        
        let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: type(of: headerView).cellId,
            for: indexPath
        )
        
        cell.semanticContentAttribute = .forceRightToLeft
        headerView.configure(cell: cell)
        action.invoke(action: .headerVisible, cell: cell, configurator: headerView, indexPath: indexPath)
        
        return cell
        
    }
    
}

//MARK: - Footer
private extension PowerHeaderFooterDiffableView {
    
    func footerView(
        settings: [PowerItemModel], collectionView: UICollectionView,
        indexPath: IndexPath, kind: String) -> UICollectionReusableView?
    {
        
        let emptyCell = emptyCell(collectionView: collectionView, indexPath: indexPath, kind: kind)
        let model = settings[indexPath.section]
        
        guard let loadMoreSection = model.loadMoreSection else { return emptyCell }
        guard let footerView = loadMoreSection.cell else { return emptyCell }
        let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: type(of: footerView).cellId,
            for: indexPath
        )
        cell.semanticContentAttribute = .forceRightToLeft
        footerView.configure(cell: cell)
        
        return cell
    }
    
}

//MARK: - EmptyCell
private extension PowerHeaderFooterDiffableView {
    
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
