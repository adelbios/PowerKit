//
//  PaginationViewModel.swift
//  DemoPowerKit
//
//  Created by adel radwan on 27/11/2022.
//

import Foundation

internal class PaginationViewModel: NSObject {
    
    func increaseCurrentPage(settings: [PowerItemModel], section: Int) -> Int? {
        guard let model = fetchLoadMoreModel(settings: settings, section: section) else { return nil }
        let page = model.currentPage + 1
        guard model.lastPage > page else { return nil }
        model.currentPage = page
        return page
    }
    
    func updateLoadMore(settings: [PowerItemModel], section: Int, currentPage: Int? = nil, lastPage: Int? = nil) {
        guard settings.isEmpty == false else { return }
        guard let model = settings[section].loadMoreSection else { return }
        
        if let currentPage {
            model.item.currentPage = currentPage
        }
        
        if let lastPage {
            model.item.lastPage = lastPage
        } else {
            model.item.lastPage = model.item.currentPage
        }
    }
    
    
    
}

//MARK: - Helper
extension PaginationViewModel {
    
    func fetchLoadMoreModel(settings: [PowerItemModel], section: Int) -> PowerLoadMoreModel.Item? {
        guard settings.isEmpty == false else { return nil }
        guard let model = settings[section].loadMoreSection else { return nil }
        return model.item
    }
    
}
