//
//  File.swift
//
//
//  Created by adel radwan on 27/11/2022.
//

import UIKit

struct PowerHeaderFooterDiffableView {
    
    func build(
        settings: [PowerItemViewModel], status: PowerNetwork.RequestStatus, kind: String, collectionView: UICollectionView,
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
    
    
    func configure(settings: [PowerItemViewModel], collectionView: UICollectionView, indexPath: IndexPath, kind: String,
                   action: PowerActionListProxy) -> UICollectionReusableView? {
        
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return buildHeader(settings: settings, collectionView: collectionView, indexPath: indexPath, action: action)
        case UICollectionView.elementKindSectionFooter:
            return buildPagination(settings: settings, collectionView: collectionView, indexPath: indexPath)
        default:
            return emptyCell(collectionView: collectionView, indexPath: indexPath, kind: kind)
        }
        
    }
    
    
    func buildHeader(settings: [PowerItemViewModel], collectionView: UICollectionView, indexPath: IndexPath, action: PowerActionListProxy) -> UICollectionReusableView? {
        let header = UICollectionView.elementKindSectionHeader + UUID().uuidString
        let empty = emptyCell(collectionView: collectionView, indexPath: indexPath, kind: header)
        let model = settings[indexPath.section]
        guard let section = model.section.header, let reusableView = section.cell else { return empty }
        let id = type(of: reusableView).cellId
        
        let kind = String("\(section.cell)\(UUID().uuidString)")
        
        print(header, "Header Kind")
        print(kind, "Kind Kind")
        
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: header, withReuseIdentifier: id, for: indexPath)
        cell.semanticContentAttribute = .forceRightToLeft
        reusableView.configure(cell: cell)
        action.invoke(action: .headerVisible, cell: cell, configurator: reusableView, indexPath: indexPath)
        return cell
    
    }
    
    func buildPagination(settings: [PowerItemViewModel], collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView? {
        let footer = UICollectionView.elementKindSectionFooter
        let empty = emptyCell(collectionView: collectionView, indexPath: indexPath, kind: footer)
        let model = settings[indexPath.section]
        
        guard let section = model.section.pagination, let reusableView = section.cell else { return empty }
        let id = type(of: reusableView).cellId
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: footer, withReuseIdentifier: id, for: indexPath)
        cell.semanticContentAttribute = .forceRightToLeft
        reusableView.configure(cell: cell)
        return cell
    }
    
    
}


//MARK: - Section
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


