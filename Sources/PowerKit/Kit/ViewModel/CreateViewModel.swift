//
//  CreateViewModel.swift
//  DemoPowerKit
//
//  Created by adel radwan on 15/11/2022.
//

import Foundation
import UIKit

internal class CreateViewModel: NSObject {
    
    var deletedViewModel: DeleteViewModel!
    
    func addNewTo(_ settings: [PowerItemModel], header: PowerUpdateItemSection?, footer: PowerUpdateItemSection?, newItems: [PowerCells], section: Int, at: Int? = nil, removeOld: Bool) {
        guard settings.isEmpty == false else { initFatelError(); return }
        addNewItems(
            settings: settings, items: newItems, headerItem: header, footerItem: footer,
            forSection: section, at: at, removeOld: removeOld
        )
    }
    
}

//MARK: - Helper
extension CreateViewModel {
    
    private func addNewItems(settings: [PowerItemModel], items: [PowerCells], headerItem: PowerUpdateItemSection?,footerItem: PowerUpdateItemSection?, forSection: Int, at: Int? = nil, removeOld: Bool) {
        guard let model = settings.filter({ $0.section.id == forSection }).first else { sectionFatelError(); return }
        createItemSectionUsing(setting: model, headerCell: headerItem, footerCell: footerItem)
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
            if let index = deletedViewModel.removedItemPositions {
                powerItemModel.items.insert(newItem, at: index)
                self.deletedViewModel.deleteValueFromRemovedItemPosition()
            }else {
                powerItemModel.items.append(newItem)
            }
            
        }
    }
    
    private func createItemSectionUsing(setting: PowerItemModel, headerCell: PowerUpdateItemSection?, footerCell: PowerUpdateItemSection?) {
        createHeader(model: headerCell, setting: setting)
        createFooter(model: footerCell, setting: setting)
    }
    
    
}

//MARK: - Item Section
extension CreateViewModel {
    
    private func createHeader(model: PowerUpdateItemSection?, setting: PowerItemModel) {
        guard let header = setting.section.header, let model, let hederCell = model.cell else { return }
        header.cell = hederCell
        header.isVisible = model.isVisible
        guard let size = model.size else { return }
        header.size = size
        updateItemSectinLayoutSize(isHeader: true, setting: setting, model: header)
        
    }
    
    private func createFooter(model: PowerUpdateItemSection?, setting: PowerItemModel) {
        guard let footer = setting.section.footer, let model, let footerCell = model.cell else { return }
        footer.cell = footerCell
        footer.isVisible = model.isVisible
        guard let size = model.size else { return }
        footer.size = size
        updateItemSectinLayoutSize(isHeader: false, setting: setting, model: footer)
        
    }
    
    func updateItemSectinLayoutSize(isHeader: Bool, setting: PowerItemModel, model: PowerItemSection.Section) {
        let newSection = setting.createSection(
            .init(size: model.size, pinToVisibleBounds: model.pinToVisibleBounds, isVisible: model.isVisible), isHeader: isHeader
        )
        setting.removeItemSection(model: setting, isHeader: isHeader)
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

