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
    func configureOther(_ data: AnyHashable?)
    associatedtype DataType
    func configure(data: DataType)
}


open class PowerModel<CellType: PowerCellDelegate, DataType: Hashable>: PowerCells where CellType.DataType == DataType, CellType: UICollectionViewCell {
     
    static override var cellId: String {
        return CellType.name
    }
    
    public init(item: DataType, otherItem: AnyHashable? = nil) {
        super.init()
        self.otherItems = otherItem
        self.item = item
    }
    
    override func configure(cell: UIView) {
        let cell = (cell as! CellType)
        cell.configureOther(otherItems)
        cell.configure(data: self.item as! DataType)
    }
    
}

//MARK: - PowerCellDelegate
extension PowerCellDelegate {
    
    public static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
    
   public  func configureOther(_ data: AnyHashable?) { }
    
}


//MARK: - PowerDelegate
private protocol PowerDelegate {
    static var cellId: String { get }
    func configure(cell: UIView)
    associatedtype DataType
    func configure(data: DataType)
    func configureOther(data: AnyHashable?)
}


open class PowerCells: PowerDelegate, Hashable, Equatable   {
    
    open var item: AnyHashable!
    open var otherItems: AnyHashable?
    open var cell: UICollectionViewCell!
  
    class var cellId: String {
        return ""
    }
    
    func configure(cell: UIView) {
    }
    
    func configure(data: any Hashable) {
        self.item = data as? AnyHashable
    }
    
    func configureOther(data: AnyHashable?) {
        self.otherItems = data
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(item)
    }

    public static func == (lhs: PowerCells, rhs: PowerCells) -> Bool {
        lhs.item == rhs.item
    }
    
}
