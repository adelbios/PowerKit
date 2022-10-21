//
//  PowerBackgroundPlugin.swift
//  CTS
//
//  Created by adel radwan on 18/10/2022.
//

import UIKit
import Moya

class PowerBackgroundPlugin : PluginType {
    
    var bgTask : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    var numInFlight = 0

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if numInFlight == 0 {
            bgTask = UIApplication.shared.beginBackgroundTask(withName: "Moya bg plugin") {
                if self.bgTask != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(self.bgTask)
                    self.bgTask = .invalid
                    self.numInFlight = 0
                }
            }
        }
        numInFlight+=1
        return request
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        numInFlight -= 1
        if (numInFlight <= 0) {
            UIApplication.shared.endBackgroundTask(self.bgTask)
            self.bgTask = .invalid
        }
    }
    
}
