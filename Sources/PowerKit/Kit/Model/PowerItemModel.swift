//
//  PowerItemModel.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit


public class PowerItemModel {
    
    final let section: Int
    final let registeredCells: [RegisteredCellsModel]
    var itemSection: ItemSection?
    var loadMoreSection: PowerLoadMoreModel?
    var emptyCell: PowerCells?
    var layout: NSCollectionLayoutSection!
    var item = [PowerCells]()
    
    var isItemVisible: Bool = true
    var boundarySupplementaryItem = [NSCollectionLayoutBoundarySupplementaryItem]()
    
    //MARK: - .init
    init(
        section: Int, itemSection: ItemSection? = nil, loadMoreSection: PowerLoadMoreModel? = nil,
        emptyCell: PowerCells? = nil, layout: LayoutKind, registeredCells: [RegisteredCellsModel]
    ) {
        
        self.section = section
        self.layout = layout.rawValue
        self.itemSection = itemSection
        self.loadMoreSection = loadMoreSection
        self.emptyCell = emptyCell
        self.registeredCells = registeredCells
        
        if let itemSection {
            self.layout.boundarySupplementaryItems = [create(itemSection)]
            self.boundarySupplementaryItem = [create(itemSection)]
        }
        
        if let loadMoreSection {
            self.layout.boundarySupplementaryItems += [createLoadMoreSection(loadMoreSection)]
            self.boundarySupplementaryItem += [createLoadMoreSection(loadMoreSection)]
        }
        
    }
    
    //MARK: - Check For Layout Kind
    enum LayoutKind: Hashable, Equatable {
        case vertical
        case horizontal
        case grid(numberOfItemPerRows: Int)
        case custom(layout: NSCollectionLayoutSection)
        
        var rawValue: NSCollectionLayoutSection {
            switch self {
            case .vertical:
                let collectionViewLayout = CollectionViewLayout()
                collectionViewLayout.itemSpacing = .init(top: 8, left: 0, bottom: 0, right: 0)
                collectionViewLayout.groupSpacing = .init(top: 0, left: 20, bottom: 0, right: 20)
                return collectionViewLayout.verticalDynamicLayout()
                
            case .horizontal:
                let collectionViewLayout = CollectionViewLayout()
                collectionViewLayout.itemSpacing = .init(top: 8, left: 0, bottom: 0, right: 0)
                collectionViewLayout.groupSpacing = .init(top: 0, left: 0, bottom: 0, right: 5)
                return collectionViewLayout.horizontalDynamicLayout()
            case .grid(let row):
                let collectionViewLayout = CollectionViewLayout()
                return collectionViewLayout.gridLayout(numberOfItemPerRows: row)
            case .custom(let layout):
                return layout
            }
        }
        
    }
    
    
}

//MARK: - Hashable
extension PowerItemModel: Hashable {
    
    
    public static func == (lhs: PowerItemModel, rhs: PowerItemModel) -> Bool {
        lhs.section == rhs.section
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(section)
    }
    
    
}

//MARK: - Create Item Section
extension PowerItemModel {
    
    func create(_ itemSection: 
                ItemSection) -> NSCollectionLayoutBoundarySupplementaryItem {
        let z = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: itemSection.size,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        z.pinToVisibleBounds = itemSection.pinToVisibleBounds
        return z
    }
    
    
    func createLoadMoreSection(_ section: PowerLoadMoreModel) -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .absolute(30), heightDimension: .absolute(40)),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: section.alignment
        )
    }
    
}


