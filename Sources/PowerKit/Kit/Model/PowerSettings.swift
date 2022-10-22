//
//  PowerSettings.swift
//  CTS
//
//  Created by adel radwan on 20/10/2022.
//

import UIKit


public struct PowerSettings {
    
    /// Used to enable pull to refresh or not, default value is true
    public var isPullToRefreshUsed = true
    
    /// this flag used to show skeleton loading or not if there is powerCell in powerModel (Is not empty), default value is false
    public var showSkeletonWhenPowerItemIsNotEmpty = false
    
    /// For Keep Section visible when power item is Empty but When set this flag to false, the section layout will be heading & empty cells either, default value is true
    public var keepSectionVisibaleForEmptyPowerItem = true
    
    /// Used for collectionView update diffable data source animation, default value is true
    public var animatingDifferences = true
    
    /// UI Used for download content, default value is skeleton when it available to using, if not the default value is normal
    public lazy var loadContentType: LoadContentType = self.getLoadingContentType
    
    public enum LoadContentType: Hashable {
        case skeleton
        case normal
        case custom(view: PowerDownloadContentViewView)
    }
    
    private var getLoadingContentType: LoadContentType {
        #if canImport(SkeletonView)
        return .skeleton
        #else
        return .normal
        #endif
    }
    
}
