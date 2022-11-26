//
//  DeleteViewModel.swift
//  DemoPowerKit
//
//  Created by adel radwan on 20/11/2022.
//

import Foundation
import UIKit

internal class DeleteViewModel: NSObject {
    
    @Published private(set) var didItemDeletedSuccessfully: Bool?
    @Published private(set) var didUpdateHeaderEventFire: Int?
    
    func removeAll(settings: [PowerItemModel], header: PowerCells?, keepSectionVisible: Bool) {
        guard settings.isEmpty == false else { initFatelError(); return }
        settings.forEach {
            deleteItemSectionFrom(settings: $0, headerData: header, keepSectionVisible: keepSectionVisible)
            $0.items.removeAll()
        }
        self.didItemDeletedSuccessfully = true
    }
    
    func removeItems(settings: [PowerItemModel], header: PowerCells?, section: Int, keepSectionVisible: Bool) {
        guard settings.isEmpty == false else { initFatelError(); return }
        guard let model = settings.filter({ $0.section == section }).first else { sectionFatelError(); return }
        deleteItemSectionFrom(settings: model, headerData: header, keepSectionVisible: keepSectionVisible)
        model.items.removeAll()
        self.didItemDeletedSuccessfully = true
    }
    
    //Using PowerCells
    func remove(settings: [PowerItemModel], header: PowerCells?, item: PowerCells, section: Int, keepSectionVisible: Bool) {
        guard settings.isEmpty == false else { initFatelError(); return }
        guard let model = settings.filter({ $0.section == section }).first else { sectionFatelError(); return }
        guard let index = model.items.firstIndex(where: { $0.item == item.item }) else { return }
        model.items.remove(at: index)
        if model.items.isEmpty {
            deleteItemSectionFrom(settings: model, headerData: header, keepSectionVisible: keepSectionVisible)
        } else {
            updateHeader(header, settings: model)
        }
        didItemDeletedSuccessfully = true
    }
    
    //Using index
    func remove(settings: [PowerItemModel], header: PowerCells?, itemIndex: Int, section: Int, keepSectionVisible: Bool) {
        guard settings.isEmpty == false else { initFatelError(); return }
        guard let model = settings.filter({ $0.section == section }).first else { return }
        guard model.items.isEmpty == false else { return }
        model.items.remove(at: itemIndex)
        if model.items.isEmpty {
            deleteItemSectionFrom(settings: model, headerData: header, keepSectionVisible: keepSectionVisible)
        } else {
            updateHeader(header, settings: model)
        }
        
        didItemDeletedSuccessfully = true
    }
    
    
}

//MARK: - Helper
private extension DeleteViewModel {
    
    
    func deleteItemSectionFrom(settings: PowerItemModel, headerData: PowerCells?, keepSectionVisible: Bool) {
        switch keepSectionVisible {
        case true:
            updateHeader(headerData, settings: settings)
        case false:
            let header = UICollectionView.elementKindSectionHeader
            settings.layout.boundarySupplementaryItems.removeAll { $0.elementKind == header }
        }
        
    }
    
    func updateHeader(_ data: PowerCells?, settings: PowerItemModel) {
        guard let itemSection = settings.itemSection else { return }
        guard let data = data else { return }
        itemSection.cell = data
        self.didUpdateHeaderEventFire = settings.section
    }
    
}

//MARK: - Error Messages
private extension DeleteViewModel {
    
    func initFatelError() {
        fatalError("Please use add(settings: [PowerItemModel]) func before delete item becuse there is no inital items in powerItemsModel")
    }
    
    func sectionFatelError() {
        fatalError("The section does not exist in powerItemsModel")
    }
    
    func sectionMismatchFatelError() {
        fatalError("Item in section is mismatch")
    }
    
}

