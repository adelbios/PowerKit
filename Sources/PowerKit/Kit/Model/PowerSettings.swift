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
    public var showSkeletonWhenItemsIsNotEmpty = false
    
    /// Keep Section visible when items in each section is Empty but When set this flag to false, the section layout will be heading & Empty Cells either (that added in settings), default value is false
    public var keepSectionVisibaleForEmptyPowerItem = false
    
    /// Used for collectionView update diffable data source animation, default value is true
    public var animatingDifferences = true
    
    /// Used for collectionView update Item section animation, default value is false
    public var animatingDifferencesForReloadSection = false
    
    
}
