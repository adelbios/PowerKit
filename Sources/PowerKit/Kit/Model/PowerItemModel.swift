//
//  PowerItemModel.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit


open class PowerItemModel {
    
    public final let section: Int
    open var loadMoreSection: PowerLoadMoreModel?
    open var emptyCell: PowerCells?
    open var layout: NSCollectionLayoutSection!
    open var items = [PowerCells]()
    internal var itemSection: PowerItemSection?
    
    
    //MARK: - .init
    public init(
            section: Int, loadMoreSection: PowerLoadMoreModel? = nil,
            emptyCell: PowerCells? = nil, itemSection: PowerItemSection? = nil,
            layout: LayoutKind
        ) {
            
            self.section = section
            self.itemSection = itemSection
            self.layout = layout.rawValue
            self.loadMoreSection = loadMoreSection
            self.emptyCell = emptyCell

            if let itemSection {
                self.layout.boundarySupplementaryItems.append(createItemSection(itemSection))
            }

            if let loadMoreSection {
                self.layout.boundarySupplementaryItems.append(createLoadMoreSection(loadMoreSection))
            }
    
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
    
    internal func removeHeader(model: PowerItemModel?) {
        model?.layout.boundarySupplementaryItems.removeAll { $0.elementKind == UICollectionView.elementKindSectionHeader }
    }
    
}

//MARK: - Hashable
extension PowerItemModel: Hashable {
    
    
    public static func == (lhs: PowerItemModel, rhs: PowerItemModel) -> Bool {
        return lhs.section == rhs.section
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.section)
    }
    
}

//MARK: - Item Section
internal extension PowerItemModel {
    
    func createItemSection(_ itemSection: PowerItemSection) -> NSCollectionLayoutBoundarySupplementaryItem {
        let z = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: itemSection.size,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        z.pinToVisibleBounds = itemSection.pinToVisibleBounds
        return z
    }
    
    
    private func createLoadMoreSection(_ section: PowerLoadMoreModel) -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(40)),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: section.alignment
        )
    }
    
}


