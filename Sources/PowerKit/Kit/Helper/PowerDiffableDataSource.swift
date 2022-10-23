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
}
#endif

//MARK: - registered All Cells
private extension PowerDiffableDataSource {
    
    func registerAllCellsUsing(_ collectionView: UICollectionView) {
        collectionView.register(PowerEmptyCell.self)
        collectionView.register(PowerLoadMoreCell.self, kind: .footer)
        registeredCells.forEach { model in
            collectionView.register(model.cell, fromNib: model.fromNib)
            guard let header = model.header else { return }
            collectionView.register(header.header, kind: .header, fromNib: header.fromNib)
        }
    }
    
}
