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
        guard let header = skeletoneCells[indexPath.section].header else { return nil }
        guard header.isSkeletonEnable == true else { return nil }
        return header.cell.name
    }

}
#endif

//MARK: - registered All Cells
private extension PowerDiffableDataSource {
    
    func registerAllCellsUsing(_ collectionView: UICollectionView) {
        collectionView.register(PowerEmptyCell.self)
        collectionView.register(PowerLoadMoreCell.self, kind: .footer)
        addEmptyHeader(collectionView: collectionView)
        registeredCells.forEach { setupCellUsing($0, collectionView: collectionView) }
    }
    
    func setupCellUsing(_ model: RegisteredCellsModel, collectionView: UICollectionView) {
        collectionView.register(model.cell, fromNib: model.fromNib)
        guard let header = model.header?.cell else { return }
        collectionView.register(header, kind: .header, fromNib: model.fromNib)
        collectionView.register(header, kind: .footer, fromNib: model.fromNib)
    }
    
    func addEmptyHeader(collectionView: UICollectionView) {
        //This help me when loading content using skeleton View
        collectionView.register(UICollectionViewCell.self, kind: .header)
        collectionView.register(UICollectionViewCell.self, kind: .footer)
        collectionView.register(PowerLoadMoreCell.self, kind: .footer, fromNib: false)
    }
    
}

