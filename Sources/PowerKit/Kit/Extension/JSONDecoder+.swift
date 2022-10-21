//
//  JSONDecoder+.swift
//  PowerHomeKit
//
//  Created by adel radwan on 21/10/2022.
//

import Foundation
import UIKit

extension JSONDecoder {
    
    func implement<T:Decodable>(useKeyDecodingStrategy: Bool = true, type: T.Type, data: Data,_ completion:(_ s: T)->() = { _ in }){
        if useKeyDecodingStrategy == true {
            self.keyDecodingStrategy = .convertFromSnakeCase
        }
        guard data.count > 0 else { return }
        do {
            let s = try self.decode(T.self, from: data)
            completion(s)
        }catch{
            log(type: .error, error)
        }
    }
    
}
