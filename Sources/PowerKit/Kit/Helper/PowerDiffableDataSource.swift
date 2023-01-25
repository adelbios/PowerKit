//
//  PowerDiffableDataSource.swift
//  CTS
//
//  Created by adel radwan on 18/10/2022.
//

import UIKit
#if canImport(SkeletonView)
import SkeletonView
#endif


class PowerDiffableDataSource<Section: Hashable, Item: Hashable>: UICollectionViewDiffableDataSource<Section, Item> {
    
    private var registeredCells = [RegisteredCellsModel]()
    private var skeletoneCells = [RegisteredCellsModel]()
    
    //MARK: - .init
    init(
        collectionView: UICollectionView, registeredCells: [RegisteredCellsModel],
        cellProvider: @escaping UICollectionViewDiffableDataSource<Section, Item>.CellProvider
    ) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
        self.registeredCells = registeredCells
        self.skeletoneCells = registeredCells.filter({ $0.skeletonCount > 0 })
        self.registerAllCellsUsing(collectionView)
    }
    
}
//MARK: - SkeletonCollectionViewDataSource
#if canImport(SkeletonView)
extension PowerDiffableDataSource: SkeletonCollectionViewDataSource {
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return skeletoneCells.count
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return skeletoneCells[indexPath.section].cell.name
    }
    
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return skeletoneCells[section].skeletonCount
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
        let section = skeletoneCells[indexPath.section]
        switch supplementaryViewIdentifierOfKind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = section.header, header.isSkeletonEnable == true else { return nil }
            return header.cell.name
        case UICollectionView.elementKindSectionFooter:
            guard let footer = section.footer, footer.isSkeletonEnable == true else { return nil }
            return footer.cell.name
        default:
            return nil
        }
        
    }

}
#endif

//MARK: - registered All Cells
private extension PowerDiffableDataSource {
    
    func registerAllCellsUsing(_ collectionView: UICollectionView) {
        collectionView.register(PowerEmptyCell.self)
        registeredCells.forEach { setupCellUsing($0, collectionView: collectionView) }
        addEmptyHeader(collectionView: collectionView)
    }
    
    func setupCellUsing(_ model: RegisteredCellsModel, collectionView: UICollectionView) {
        collectionView.register(model.cell, fromNib: model.fromNib)
        
        if let header = model.header?.cell {
            collectionView.register(header, kind: .header, fromNib: model.fromNib)
        }
        
        if let footer = model.footer?.cell {
            collectionView.register(footer, kind: .footer, fromNib: model.fromNib)
        }
        
    }
    
    func addEmptyHeader(collectionView: UICollectionView) {
        //This help me when loading content using skeleton View
        collectionView.register(UICollectionViewCell.self, kind: .header)
        collectionView.register(UICollectionViewCell.self, kind: .footer)
    }
    
}

