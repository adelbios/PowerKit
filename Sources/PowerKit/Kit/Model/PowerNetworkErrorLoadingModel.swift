//
//  PowerNetworkErrorLoadingModel.swift
//  CTS
//
//  Created by adel radwan on 18/10/2022.
//

import Foundation


import UIKit

public struct PowerNetworkErrorLoadingModel {
    
    public let statusCode: Int
    
    public enum NetworkError: Int, Error {
        case noInternet = 6
        case badRequest = 400
        case unauthorized = 401
        case forBidden = 403
        case notFound = 404
        case methodNotAllowed = 405
        case notAcceptable = 406
        case timeOut = 408
        case internalServerError = 500
        case badGetaway = 502
        case undefined = -1
        case noError = 200
        case dataCorrupted = 9999
        
    }
    
    public var error: NetworkError {
        if (0...6).contains(statusCode) {
            return .noInternet
        } else if (200...299).contains(statusCode) {
            return .noError
        } else if (400...499).contains(statusCode) {
            let value = NetworkError(rawValue: statusCode)
            return value ?? .undefined
        } else if (500...599).contains(statusCode) {
            let value = NetworkError(rawValue: statusCode)
            return value ?? .undefined
        } else if (700...).contains(statusCode) {
            let value = NetworkError(rawValue: statusCode)
            return value ?? .undefined
        } else {
            let value = NetworkError(rawValue: statusCode)
            return value ?? .undefined
        }
    }
    
    public var description: String {
        let status = NetworkError(rawValue: statusCode) ?? .undefined
        switch status {
        case .noError:
            return ""
        case .badRequest:
            return "\(status.rawValue) - " + "طلب غير صالح"
        case .unauthorized:
            return "\(status.rawValue) - " + "لاتوجد صلاحية للوصول"
        case .forBidden:
            return "\(status.rawValue) - " + "طلب ممنوع"
        case .notFound:
            return "\(status.rawValue) - " + "الطلب غير موجود"
        case .methodNotAllowed:
            return "\(status.rawValue) - " + "طريقة غير مسموح بها"
        case .notAcceptable:
            return "\(status.rawValue) - " + "طلب غير مقبول"
        case .timeOut:
            return "\(status.rawValue) - " + "طلب انتهت مهلته"
        case .internalServerError:
            return "\(status.rawValue) - " + "خطأ داخلي في الخادم"
        case .badGetaway:
            return "\(status.rawValue) - لايوجد استجابة من الخادم"
        case .noInternet:
            return "\(status.rawValue) - " + "لا يوجد اتصال بالإنترنت"
        case .dataCorrupted:
            return "تنسيق البيانات غير صحيح"
        case .undefined:
            return "\(statusCode) - خطأ غير معرف"
            
        }
    }
    
    public var message: String {
        let status = NetworkError(rawValue: statusCode) ?? .undefined
        switch status {
        case .noInternet:
            return "يبدو انه لايوجد إتصال بالإنترنت تاكد من اتصالك من خلال الشبكة الخلوية او شبكة WI-FI"
        case .dataCorrupted:
            return "يبدو ان البيانات القادمة من الخادم ذات تنسيق غير صالح، حاول إعادة الطلب مره اخرى او قم بالتواصل مع الدعم الفني"
        default:
            return "نأسف منك، يوجد خطأ ما ولايمكن الوصول للصفحة اللتي تم طلبها حاول مره اخرى او قم بالتواصل مع الدعم الفني"

        }
    }
    
}






            
