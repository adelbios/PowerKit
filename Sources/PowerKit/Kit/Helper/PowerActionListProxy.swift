//
//  PowerActionListProxy.swift
//  CTS
//
//  Created by adel radwan on 19/10/2022.
//

import UIKit

struct PowerCellActionModel {
    let action: PowerCellsAction
    let cell: UIView
}

public enum PowerCellsAction: Hashable {
    
    static let notificationName = NSNotification.Name(rawValue: "powerCellAction")
    
    case didSelect
    case didDeSelect
    case headerVisible
    case footerVisible
    case custom(String)
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .didSelect:
            hasher.combine(1)
        case .didDeSelect:
            hasher.combine(2)
        case .headerVisible:
            hasher.combine(3)
        case .footerVisible:
            hasher.combine(4)
        case .custom(let custom):
            hasher.combine(custom)
        }
    }
    
    public static func ==(lhs: PowerCellsAction, rhs: PowerCellsAction) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func invoke(cell: UIView) {
        NotificationCenter.default.post(
            name: PowerCellsAction.notificationName,
            object: nil,
            userInfo: ["data": PowerCellActionModel(action: self, cell: cell)]
        )
    }
    
}

open class PowerActionListProxy {
    
    private var actions = [String: ((PowerCells, UIView, IndexPath) -> Void)]()
    
    open func invoke(action: PowerCellsAction, cell: UIView, configurator: PowerCells, indexPath: IndexPath) {
        let key = "\(action.hashValue)\(type(of: configurator).cellId)"
        guard let action = self.actions[key] else { return }
        action(configurator, cell, indexPath)
    }
    
    @discardableResult
    open func on<CellType, DataType>(_ action: PowerCellsAction, handler: @escaping ((PowerModel<CellType, DataType>, UIView, IndexPath) -> Void)) -> Self {
        let key = "\(action.hashValue)\(CellType.reuseIdentifier)"
        self.actions[key] = { list, cell, indexPath in
            
            handler(list as! PowerModel<CellType, DataType>, cell, indexPath)
        }
        return self
    }
    
}
