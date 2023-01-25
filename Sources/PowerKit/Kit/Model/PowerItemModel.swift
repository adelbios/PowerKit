//
//  PowerItemModel.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit


open class PowerItemModel {
    
    open var section: PowerItemSection
    open var emptyCell: PowerCells?
    open var layout: NSCollectionLayoutSection!
    open var items = [PowerCells]()
    
    
    //MARK: - .init
    public init(section: PowerItemSection, emptyCell: PowerCells? = nil, layout: LayoutKind) {
        self.section = section
        self.layout = layout.rawValue
        self.emptyCell = emptyCell
        self.createItemSections(section)
    }
    
    
    //MARK: - Check For Layout Kind
    public enum LayoutKind: Hashable, Equatable {
        case vertical
        case horizontal
        case grid(numberOfItemPerRows: Int)
        case custom(layout: NSCollectionLayoutSection)
        
        var rawValue: NSCollectionLayoutSection {
            switch self {
            case .vertical:
                return PowerItemModel.createVerticalLayout()
            case .horizontal:
                return PowerItemModel.createHorizontalLayout()
            case .grid(let row):
                return PowerItemModel.createGridLayout(row: row)
            case .custom(let layout):
                return layout
            }
        }
        
    }
    
}

//MARK: - Item Section
internal extension PowerItemModel {
    
    private func createItemSections(_ model: PowerItemSection) {
        if model.header != nil && model.footer != nil {
            self.layout.boundarySupplementaryItems = [
                createSection(model.header!, isHeader: true),
                createSection(model.footer!, isHeader: false)
            ]
        }
        
        if model.header == nil && model.footer != nil {
            self.layout.boundarySupplementaryItems = [createSection(model.footer!, isHeader: false)]
        }
        
        if model.header != nil && model.footer == nil {
            self.layout.boundarySupplementaryItems = [createSection(model.header!, isHeader: true)]
        }
    }
    
    func createSection(_ model: PowerItemSection.Section, isHeader: Bool) -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerKind = UICollectionView.elementKindSectionHeader
        let footerKind = UICollectionView.elementKindSectionFooter
        let sec = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: model.size,
            elementKind: isHeader ? headerKind: footerKind,
            alignment: isHeader ? .top : .bottom
        )
        sec.pinToVisibleBounds = model.pinToVisibleBounds
        return sec
    }
    
    func removeItemSection(model: PowerItemModel?, isHeader: Bool) {
        let headerKind = UICollectionView.elementKindSectionHeader
        let footerKind = UICollectionView.elementKindSectionFooter
        let kind: String = isHeader ? headerKind : footerKind
        model?.layout.boundarySupplementaryItems.removeAll { $0.elementKind == kind }
    }
    
}

//MARK: - Layout
internal extension PowerItemModel {
    
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

//MARK: - Hashable
extension PowerItemModel: Hashable {
    
    
    public static func == (lhs: PowerItemModel, rhs: PowerItemModel) -> Bool {
        return lhs.section.id == rhs.section.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.section.id)
    }
    
}
