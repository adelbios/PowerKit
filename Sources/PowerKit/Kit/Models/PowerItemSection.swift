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
    public var pagination: Pagination?
    
    //MARK: - .Init
    public init(id: Int, header: Section? = nil, pagination: Pagination? = nil) {
        self.id = id
        self.header = header
        self.pagination = pagination
    }
    
    mutating internal func addHeader(cell: PowerCells?, isAutoHeaderUpdate: Bool, pagination: Pagination?) {
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
    
    //MARK: - .Init
    public init(size: NSCollectionLayoutSize = .dynamic(estimatedValue: 50), pinToTop: Bool = false) {
        self.size = size
        self.pinToTop = pinToTop
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
public struct Pagination: Hashable {
   
    public private(set) var isRequestMoreFire: Bool = false
    
    internal var size: NSCollectionLayoutSize
    
    internal var cell: PowerCells?
    
    public private(set) var current: Int?
    
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
         self.cell = PowerModel<PowerLoadMoreCell, Pagination>(item: .init(current: current, total: total))
    }
    
}
