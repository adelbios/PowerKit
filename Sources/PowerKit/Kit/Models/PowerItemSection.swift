//
//  ItemSection.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit

//MARK: - PowerItemSection
public struct PowerItemSection: Hashable {
    
    //MARK: - Variables
    public var id: Int
    public var header: Section?
    public var pagination: PaginationModel?
    
    //MARK: - .Init
    public init(id: Int, header: Section? = nil, pagination: PaginationModel? = nil) {
        self.id = id
        self.header = header
        self.pagination = pagination
    }
    
    mutating internal func addHeader(cell: PowerCells?, isAutoHeaderUpdate: Bool, pagination: PaginationModel?) {
        if let newCell = cell { updateHeader(cell: newCell, isAutoHeaderUpdate: isAutoHeaderUpdate) }
        if let page = pagination { self.pagination?.add(current: page.current ?? 1, total: page.total ?? 1) }
    }
    
    
    private mutating func updateHeader(cell: PowerCells, isAutoHeaderUpdate: Bool) {
        switch isAutoHeaderUpdate {
        case true:
            self.header?.add(cell: cell)
        case false:
            guard header?.cell == nil else { return }
            self.header?.add(cell: cell)
        }
    }
    
}

//MARK: - Section
public struct Section: Hashable {
    
    //MARK: - Variables
    internal var cell: PowerCells?
    internal var size: NSCollectionLayoutSize
    internal var pinToTop: Bool
    internal var kind: String
    
    //MARK: - .Init
    public init(size: NSCollectionLayoutSize = .dynamic(estimatedValue: 50), pinToTop: Bool = false,
                kind: String = UICollectionView.elementKindSectionHeader) {
        self.size = size
        self.pinToTop = pinToTop
        self.kind = kind
    }
    
    //MARK: - .Init
    public init(_ cell: PowerCells) {
        self.init()
        self.cell = cell
    }
    
    mutating fileprivate func add(cell: PowerCells?) {
        guard let newCell = cell else { return }
        self.cell = newCell
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cell?.item)
    }

    public static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.cell?.item == rhs.cell?.item
    }
    
}

//MARK: - Pagination
public struct PaginationModel: Hashable {
   
    public private(set) var isRequestMoreFire: Bool = false
    
    internal private(set) var current: Int?
    
    internal var size: NSCollectionLayoutSize
    
    internal var cell: PowerCells?
    
    internal private(set) var total: Int?
    
    //MARK: - .Init
    public init(size: NSCollectionLayoutSize = .dynamic(estimatedValue: 50)) {
        self.size = size
    }
    
    //MARK: - .Init
    public init(current: Int, total: Int) {
        self.init()
        self.current = current
        self.total = total
        self.isRequestMoreFire = current <= total ? true : false
    }
    
     fileprivate mutating func add(current: Int, total: Int) {
         self.current = current
         self.total = total
         self.isRequestMoreFire = current <= total ? true : false
         self.cell = PowerModel<PowerLoadMoreCell, PaginationModel>(item: .init(current: current, total: total))
    }
    
}
