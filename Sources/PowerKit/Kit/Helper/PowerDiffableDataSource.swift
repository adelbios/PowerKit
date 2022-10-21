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
    
    //MARK: - .init
    init(
        collectionView: UICollectionView, registeredCells: [RegisteredCellsModel],
        cellProvider: @escaping UICollectionViewDiffableDataSource<Section, Item>.CellProvider
    ) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
        self.registeredCells = registeredCells.filter({ $0.skeletonCount > 0 })
        self.registerAllCellsUsing(collectionView)
    }
    
}
//MARK: - SkeletonCollectionViewDataSource
#if canImport(SkeletonView)
extension PowerDiffableDataSource: SkeletonCollectionViewDataSource {
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return registeredCells.count
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return registeredCells[indexPath.section].cell.name
    }
    
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return registeredCells[section].skeletonCount
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
