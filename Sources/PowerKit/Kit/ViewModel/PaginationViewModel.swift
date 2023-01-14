//
//  PaginationViewModel.swift
//  DemoPowerKit
//
//  Created by adel radwan on 27/11/2022.
//

import Foundation

internal class PaginationViewModel: NSObject {
    
    func set(settings: [PowerItemModel], section: Int, loadMoreModel: PowerLoadMoreModel.Item?) {
        guard settings.isEmpty == false else { return }
        guard let model = settings[section].loadMoreSection else { return }
        guard let loadMoreModel else { return }
        model.item = loadMoreModel
    }
    
    func get(settings: [PowerItemModel], section: Int) -> PowerLoadMoreModel.Item? {
        guard settings.isEmpty == false else { return nil }
        guard let model = settings[section].loadMoreSection else { return nil }
        return model.item
    }
    
    
    
}

