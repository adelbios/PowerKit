//
//  PowerCell.swift
//  CTS
//
//  Created by adel radwan on 14/10/2022.
//

import UIKit


//MARK: - PowerCell
public protocol PowerCellDelegate {
    static var reuseIdentifier: String { get }
    func passOtherData(_ data: Any?)
    associatedtype DataType
    func configure(data: DataType)
}


public class PowerModel<CellType: PowerCellDelegate, DataType: Hashable>: PowerCells where CellType.DataType == DataType, CellType: UICollectionViewCell {
  
    var otherItem: Any?
   
    static override var cellId: String {
        return CellType.name
    }
    
    
    init(item: DataType, otherItem: Any? = nil) {
        super.init()
        self.item = item
        self.otherItem = otherItem
    }
    
    override func configure(cell: UIView) {
        let cell = (cell as! CellType)
        if let other = otherItem { cell.passOtherData(other) }
        cell.configure(data: self.item as! DataType)
    }
    
}

//MARK: - PowerCellDelegate
extension PowerCellDelegate {
    
    public static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
    
   public  func passOtherData(_ data: Any?) { }
    
}


//MARK: - PowerDelegate
private protocol PowerDelegate {
    static var cellId: String { get }
    func configure(cell: UIView)
    associatedtype DataType
    func configure(data: DataType)
}


public class PowerCells: PowerDelegate, Hashable, Equatable   {
    
    var item: AnyHashable!
    var cell: UICollectionViewCell!
  
    class var cellId: String {
        return ""
    }
    
    func configure(cell: UIView) {
    }
    
    func configure(data: any Hashable) {
        self.item = data as? AnyHashable
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(item)
    }

    public static func == (lhs: PowerCells, rhs: PowerCells) -> Bool {
        lhs.item == rhs.item
    }
    
}
