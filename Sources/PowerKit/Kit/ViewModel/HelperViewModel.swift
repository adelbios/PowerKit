//
//  HelperViewModel.swift
//  DemoPowerKit
//
//  Created by adel radwan on 20/11/2022.
//

import Foundation



internal class HelperViewModel: NSObject {
    
    private let createViewModel = CreateViewModel()
    @Published private(set) var reloadUI: Bool?
    @Published private(set) var didUpdateHeaderEventFire: Int?
    
    
    func update(settings: [PowerItemModel], newHeader: PowerCells?, newItem: PowerUpdatedModel?, section: Int) {
        guard settings.isEmpty == false else { initFatelError(); return }
        guard let model = settings.first(where: { $0.section == section }) else { sectionFatelError(); return }
        
        if let newHeader { updateHeader(newHeader, settings: model) }
        if let newItem { updateItem(updatedModel: newItem, settings: model) }
       
        reloadUI = true
    }
    
    func setItemHidden(_ value: Bool, settings: [PowerItemModel], section: Int) -> (value: Bool, section: Int) {
        guard settings.isEmpty == false else {
            fatalError("Please use add(settings: [PowerItemModel]) func before Updated becuse there is no inital items in powerItemsModel")
        }
        return (value, section)
    }
    
    
    func search(settings: [PowerItemModel], headerData: PowerCells?, item: [PowerCells], section: Int) {
        guard settings.isEmpty == false else { initFatelError(); return }
        guard let model = settings.first(where: { $0.section == section }) else { sectionFatelError(); return }
        model.items.removeAll()
        updateHeader(headerData, settings: model)
        item.forEach { createViewModel.appendOrInsertNewItem(at: nil, powerItemModel: model, newItem: $0, forSection: section) }
        self.reloadUI = true
    }
    
    func getPowerItemModel(settings: [PowerItemModel], section: Int) -> PowerItemModel? {
        guard settings.isEmpty == false else { initFatelError(); return nil }
        guard let model = settings.first(where: { $0.section == section }) else { sectionFatelError(); return nil }
        return model
    }
    
}

//MARK: - Helper functions
private extension HelperViewModel {
    
    func updateHeader(_ data: PowerCells?, settings: PowerItemModel) {
        guard let itemSection = settings.itemSection else { return }
        guard let data = data else { return }
        itemSection.cell = data
        self.didUpdateHeaderEventFire = settings.section
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
