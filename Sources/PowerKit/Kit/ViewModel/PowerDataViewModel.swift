//
//  PowerDataViewModel.swift
//  PowerKitDemo
//
//  Created by adel radwan on 14/05/2023.
//

import Foundation

protocol PowerDataViewModelDelegate: AnyObject {
    
    func didCreateSettings()
    
    func didInsertNewItems()
    
    func didHeaderUpdated(section: Int)
    
    func didRemoveSection(_ section: Int)
    
    func didRemoveItemAt(indexPath: IndexPath)
    
    func didRemove(cell: PowerCells)
    
    func didUpdateSection(_ section: Int)
    
    func isEmpty(_ value: Bool)
    
}

internal class PowerDataViewModel {
    
    weak var delegate: PowerDataViewModelDelegate?

    private(set) var sectionId: Int!
    private(set) var isPaginationRequested: Bool = false
    

    func setPaginationRequested(_ value: Bool) {
        self.isPaginationRequested = value
    }
    
    func setEmpty(settings: [PowerItemViewModel]) {
        self.delegate?.isEmpty(settings.allSatisfy { $0.cells.isEmpty })
    }
    
}

//MARK: - Create
internal extension PowerDataViewModel {
    
    func addNew(settings: [PowerItemViewModel], addNewModel: PowerAddNewModel) {
        settings[addNewModel.id].append(model: addNewModel, isPaginationRequested: isPaginationRequested)
        self.delegate?.didInsertNewItems()
        if isPaginationRequested == false {
            self.delegate?.didHeaderUpdated(section: addNewModel.id)
        }
        setEmpty(settings: settings)
    }
    
    func addNewGroup(settings: [PowerItemViewModel], groups: [PowerAddNewModel]) {
        groups.forEach { settings[$0.id].append(model: $0, isPaginationRequested: isPaginationRequested) }
        self.delegate?.didInsertNewItems()
        if groups.count == 1 {
            guard let id = groups.first?.id else { return }
            guard isPaginationRequested == false else { return }
            self.delegate?.didHeaderUpdated(section: id)
        }
        setEmpty(settings: settings)
    }
    
    
}

//MARK: - Update
internal extension PowerDataViewModel {

    func update(settings: [PowerItemViewModel], id: Int, header: Section) {
        settings[id].updateHeader(newHeader: header)
        self.delegate?.didHeaderUpdated(section: id)
    }
    
    func update(section: Int) {
        self.delegate?.didHeaderUpdated(section: section)
    }
    
}

//MARK: - Delete
internal extension PowerDataViewModel {
    
    func removeItemAt(indexPath: IndexPath, settings: [PowerItemViewModel]) {
        let _ = settings[indexPath.section].removeAt(index: indexPath.item)
        self.delegate?.didRemoveItemAt(indexPath: indexPath)
        setEmpty(settings: settings)
    }
    
    func removeSection(section: Int, settings: [PowerItemViewModel]) {
        settings[section].removeSection()
        self.delegate?.didRemoveSection(section)
        setEmpty(settings: settings)
    }
    
    func remove(cell: PowerCells, section: Int, settings: [PowerItemViewModel]) {
        settings[section].remove(cell: cell)
        self.delegate?.didRemove(cell: cell)
        setEmpty(settings: settings)
    }

}
