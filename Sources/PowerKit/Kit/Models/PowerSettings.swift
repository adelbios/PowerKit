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
    
}
