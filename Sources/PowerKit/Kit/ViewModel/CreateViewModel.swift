//
//  CreateViewModel.swift
//  DemoPowerKit
//
//  Created by adel radwan on 15/11/2022.
//

import Foundation

internal class CreateViewModel: NSObject {
    
    func addNewTo(_ settings: [PowerItemModel], header: PowerCells? = nil, newItems: [PowerCells], section: Int,
                  at: Int? = nil, removeOld: Bool) {
        guard settings.isEmpty == false else { initFatelError(); return }
        addNewItems(settings: settings, items: newItems, headerItem: header, forSection: section, at: at, removeOld: removeOld)
    }
    
}

//MARK: - Helper
extension CreateViewModel {
    
    private func addNewItems(settings: [PowerItemModel], items: [PowerCells], headerItem: PowerCells?,
                             forSection: Int, at: Int? = nil, removeOld: Bool) {
        guard let model = settings.filter({ $0.section == forSection }).first else { sectionFatelError(); return }
        createHeaderUsing(setting: model, header: headerItem)
        
        switch removeOld {
        case true:
            model.items = items
        case false:
            items.forEach {
                appendOrInsertNewItem(at: at, powerItemModel: model, newItem: $0, forSection: forSection, removeOld: removeOld)
            }
        }
        
    }
    
    func appendOrInsertNewItem(at: Int?, powerItemModel: PowerItemModel, newItem: PowerCells, forSection: Int, removeOld: Bool) {
        switch powerItemModel.items.isEmpty {
        case true:
            createNewItem(at: at, powerItemModel: powerItemModel, newItem: newItem, removeOld: removeOld)
        case false:
            guard let firstItem = powerItemModel.items.first else { return }
            guard type(of: firstItem).cellId == type(of: newItem).cellId else { sectionMismatchFatelError(); return }
            createNewItem(at: at, powerItemModel: powerItemModel, newItem: newItem, removeOld: removeOld)
        }
        
    }
    
    private func createNewItem(at: Int?, powerItemModel: PowerItemModel, newItem: PowerCells, removeOld: Bool) {
        guard powerItemModel.items.contains(newItem) == false else { return }
        switch at != nil {
        case true:
            powerItemModel.items.insert(newItem, at: at!)
        case false:
            powerItemModel.items.append(newItem)
        }
    }
    
    private func createHeaderUsing(setting: PowerItemModel, header: PowerCells?) {
        guard let itemSection = setting.itemSection else { return }
        itemSection.cell = header
        itemSection.sectionIndex = setting.section
        let newSection = setting.createItemSection(itemSection)
        guard setting.layout.boundarySupplementaryItems.contains(newSection) == false else { return }
        setting.layout.boundarySupplementaryItems.append(newSection)
    }
    
}

//MARK: - Error Messages
private extension CreateViewModel {
    
    func initFatelError() {
        fatalError("Please use add(settings: [PowerItemModel]) func becuse there is no inital items in powerItemsModel")
    }
    
    func sectionFatelError() {
        fatalError("The section does not exist in powerItemsModel")
    }
    
    func sectionMismatchFatelError() {
        fatalError("Item in section is mismatch")
    }
    
}
