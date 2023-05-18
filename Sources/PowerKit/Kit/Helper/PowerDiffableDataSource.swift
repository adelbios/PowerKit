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
    
    private var skeletoneCells = [RegisteredCellsModel]()
    private var cells = [RegisteredCellsModel]()
    
    //MARK: - .init
    init(
        collectionView: UICollectionView, registeredCells: [RegisteredCellsModel],
        cellProvider: @escaping UICollectionViewDiffableDataSource<Section, Item>.CellProvider
    ) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
        self.cells = registeredCells
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
        let header = cells[indexPath.section]
        guard supplementaryViewIdentifierOfKind == header.kind else { return nil }
        return header.isHeader ? header.cell.name : nil
    }
    
}
#endif

//MARK: - registered All Cells
private extension PowerDiffableDataSource {
    
    func registerAllCellsUsing(_ collectionView: UICollectionView) {
        cells.forEach { setupCellUsing($0, collectionView: collectionView) }
        addEmptySections(collectionView: collectionView)
    }
    
    func setupCellUsing(_ model: RegisteredCellsModel, collectionView: UICollectionView) {
        switch model.isHeader {
        case true:
            print(model.kind)
            collectionView.register(model.cell, kind: model.kind)
            collectionView.register(UICollectionViewCell.self, kind: model.kind)
        case false:
            print(model.cell)
            collectionView.register(model.cell)
        }
        
    }
    
    func addEmptySections(collectionView: UICollectionView) {
        collectionView.register(UICollectionViewCell.self, kind: .header)
        collectionView.register(UICollectionViewCell.self, kind: .footer)
        collectionView.register(PowerLoadMoreCell.self, kind: .footer)
    }
    
}

