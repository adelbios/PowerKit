//
//  Devices.swift
//  CTS
//
//  Created by adel radwan on 14/10/2022.
//

import UIKit

struct PowerDevices {
    
    static var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIphone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var hasNotch: Bool {
        let bottom = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows.filter({$0.isKeyWindow}).first?.rootViewController?.view.safeAreaInsets.bottom ??  0
        return bottom > 0
    }
    
}
