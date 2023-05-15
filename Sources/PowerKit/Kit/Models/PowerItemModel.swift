//
//  PowerItemModel.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit


public class PowerItemViewModel {
    
    //MARK: - Open Variables
    public enum LayoutKind: Hashable, Equatable {
        case vertical
        case horizontal
        case grid(numberOfItemPerRows: Int)
        case custom(layout: NSCollectionLayoutSection)
    }
    
    open private(set) var layout: NSCollectionLayoutSection!
    open private(set) var section: PowerItemSection
    open private(set) var cells = [PowerCells]()
    open private(set) var emptyCell: PowerCells?
    
    //MARK: - Private Variables
    private var layoutKind: LayoutKind
    
    //MARK: - LifeCycle
    public init(section: PowerItemSection, empty: PowerCells? = nil, layout: LayoutKind) {
        self.section = section
        self.layoutKind = layout
        self.emptyCell = empty
        self.layout = self.createLayout()
        createSection(section.header)
        createPagination(section.pagination)
    }
    

}

//MARK: - DATA
internal extension PowerItemViewModel {
    
    func append(model: PowerAddNewModel, isPaginationRequested: Bool) {
        let header = model.header?.cell
        let pagination = model.pagination
        section.addHeader(cell: header, isAutoHeaderUpdate: model.isAutoHeaderUpdating, pagination: pagination)
        switch isPaginationRequested {
        case true:
            model.items.forEach { self.cells.append($0) }
        case false:
            self.cells.removeAll()
            self.cells.insert(contentsOf: model.items, at: 0)
        }
    }
    
    func updateHeader(newHeader: Section) {
        self.section.addHeader(cell: newHeader.cell, isAutoHeaderUpdate: true, pagination: nil)
    }
    
    func removeSection() {
        self.cells.removeAll()
    }
    
    func removeAt(index: Int) -> PowerCells {
        return self.cells.remove(at: index)
    }
    
    func remove(cell: PowerCells) {
        self.cells.removeAll { $0 == cell }
    }
    
}

//MARK: - Section
private extension PowerItemViewModel {
    
    func createSection(_ model: Section?) {
        guard let model else { return }
        let kind = UICollectionView.elementKindSectionHeader
        let sec = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: model.size, elementKind: kind, alignment: .top)
        sec.pinToVisibleBounds = model.pinToTop
        layout.boundarySupplementaryItems.append(sec)
    }
    
    func createPagination(_ model: PaginationModel?) {
        guard let model else { return }
        let kind = UICollectionView.elementKindSectionFooter
        let sec = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: model.size, elementKind:kind, alignment: .bottom)
        layout.boundarySupplementaryItems.append(sec)
    }
    
}

//MARK: - Hashable
extension PowerItemViewModel: Hashable {
   
    public static func == (lhs: PowerItemViewModel, rhs: PowerItemViewModel) -> Bool {
        lhs.section.id == rhs.section.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(section.id)
    }
    
}

//MARK: - CollectionLayout
private extension PowerItemViewModel {
    
     func createLayout() -> NSCollectionLayoutSection {
        switch layoutKind {
        case .vertical:
            return PowerItemViewModel.createVerticalLayout()
        case .horizontal:
            return PowerItemViewModel.createHorizontalLayout()
        case .grid(let row):
            return PowerItemViewModel.createGridLayout(row: row)
        case .custom(let layout):
            return layout
        }
    }
    
    static func createVerticalLayout() -> NSCollectionLayoutSection {
        let collectionViewLayout = CollectionViewLayout()
        collectionViewLayout.itemSpacing = .init(top: 8, left: 0, bottom: 0, right: 0)
        collectionViewLayout.groupSpacing = .init(top: 0, left: 20, bottom: 0, right: 20)
        return collectionViewLayout.verticalDynamicLayout()
    }
    
    static func createHorizontalLayout() -> NSCollectionLayoutSection {
        let collectionViewLayout = CollectionViewLayout()
        collectionViewLayout.itemSpacing = .init(top: 8, left: 0, bottom: 0, right: 0)
        collectionViewLayout.groupSpacing = .init(top: 0, left: 0, bottom: 0, right: 5)
        return collectionViewLayout.horizontalDynamicLayout()
    }
    
    static func createGridLayout(row: Int) -> NSCollectionLayoutSection {
        let collectionViewLayout = CollectionViewLayout()
        return collectionViewLayout.gridLayout(numberOfItemPerRows: row)
    }
    
}
