//
//  PowerNetworkReachability.swift
//  CTS
//
//  Created by adel radwan on 13/10/2022.
//

import UIKit
import Alamofire
import Combine

open class PowerNetworkReachability {
    
    //MARK: - Variables
    public static let shared = PowerNetworkReachability()
    
    open private(set) var networkStatus = PassthroughSubject<NetworkReachabilityManager.NetworkReachabilityStatus, Error>()
    
    private var reachability = NetworkReachabilityManager(host: "google.com")
    
    open var isReachableOnCellular: Bool {
        get {
            return reachability?.isReachableOnCellular ?? false
        }
    }
    
    open var isReachableOnEthernetOrWiFi: Bool {
        get {
            return reachability?.isReachableOnEthernetOrWiFi ?? false
        }
    }
    
    open var isReachable: Bool {
        get {
            return reachability?.isReachable ?? false
        }
    }
    
    //MARK: - .Init
    private init() { }
    
    deinit {
        stopListening()
    }
    
    func startListening() {
        reachability?.startListening { [weak self] status in
            guard let self else { return }
            self.networkStatus.send(status)
        }
    }
    
    private func stopListening() {
        reachability?.stopListening()
    }
    
}


