//
//  HelperViewModel.swift
//  DemoPowerKit
//
//  Created by adel radwan on 20/11/2022.
//

import Foundation
import UIKit



internal class HelperViewModel: NSObject {
    
    @Published private(set) var didUpdateHeaderEventFire: Int?
    private let createViewModel = CreateViewModel()
    
    func update(settings: [PowerItemModel], newHeader: PowerCells?, newFooter: PowerCells?, newItem: PowerUpdatedModel?, section: Int) {
        guard settings.isEmpty == false else { initFatelError(); return }
        guard let model = settings.first(where: { $0.section.id == section }) else { sectionFatelError(); return }
        
        if let newHeader { updateSection(newHeader, settings: model, isHeader: true) }
        if let newFooter { updateSection(newFooter, settings: model, isHeader: false)  }
        if let newItem { updateItem(updatedModel: newItem, settings: model) }

    }
    
    func setItemHidden(_ value: Bool, settings: [PowerItemModel], section: Int) -> (value: Bool, section: Int) {
        guard settings.isEmpty == false else {
            fatalError("Please use add(settings: [PowerItemModel]) func before Updated becuse there is no inital items in powerItemsModel")
        }
        return (value, section)
    }
    
    func getPowerItemModel(settings: [PowerItemModel], section: Int) -> PowerItemModel? {
        guard settings.isEmpty == false else { initFatelError(); return nil }
        guard let model = settings.first(where: { $0.section.id == section }) else { sectionFatelError(); return nil }
        return model
    }
    
    func seItemtSection(isHeader: Bool, visible: Bool, newSectionSize: NSCollectionLayoutSize?, settings: [PowerItemModel], section: Int) {
        guard settings.isEmpty == false else { initFatelError(); return }
        guard let model = settings.first(where: { $0.section.id == section }) else { sectionFatelError(); return }
        guard let itemSection = isHeader ? model.section.header : model.section.footer else { return }
        itemSection.isVisible = visible
        guard let newSectionSize else { return }
        itemSection.size = newSectionSize
        createViewModel.updateItemSectinLayoutSize(isHeader: isHeader, setting: model, model: itemSection)
    }
    
}

//MARK: - Helper functions
private extension HelperViewModel {
    
    
    func updateSection(_ data: PowerCells?, settings: PowerItemModel, isHeader: Bool) {
        guard let data = data else { return }
        if let header = settings.section.header {
            header.cell = data
        }
        
        if let footer = settings.section.footer {
            footer.cell = data
        }
        
        didUpdateHeaderEventFire = settings.section.id
    }
    
    func updateItem(updatedModel: PowerUpdatedModel, settings: PowerItemModel) {
        guard settings.items.isEmpty == false else { return }
        guard let index = settings.items.firstIndex(where: { $0 == updatedModel.oldItem }) else { return }
        settings.items[index] = updatedModel.newItem
    }
    
    
}

//MARK: - Error Messages
private extension HelperViewModel {
    
    func initFatelError() {
        fatalError("Please use add(settings: [PowerItemModel]) func before Updated becuse there is no inital items in powerItemsModel")
    }
    
    func sectionFatelError() {
        fatalError("The section does not exist in powerItemsModel")
    }
    
    func sectionMismatchFatelError() {
        fatalError("Item in section is mismatch")
    }
    
}

