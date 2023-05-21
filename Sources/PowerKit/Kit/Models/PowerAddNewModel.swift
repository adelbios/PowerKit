//
//  PowerAddNewModel.swift
//  PowerKitDemo
//
//  Created by adel radwan on 14/05/2023.
//

import Foundation

public struct PowerAddNewModel {
    //MARK: - Variables
    public let id: Int
    public let header: Section?
    public let isAutoHeaderUpdating: Bool
    public let pagination: PaginationModel?
    public var items: [PowerCells]
    public var emptyCell: PowerCells?
    
    //MARK: - .Init
    public init(
        id: Int, header: Section? = nil, isAutoHeaderUpdating: Bool = true,
        pagination: PaginationModel? = nil, emptyCell: PowerCells? = nil, items: [PowerCells]
    ) {
        self.id = id
        self.header = header
        self.isAutoHeaderUpdating = isAutoHeaderUpdating
        self.pagination = pagination
        self.items = items
        self.emptyCell = emptyCell
    }
    
}
