//
//  PowerNetwork.swift
//  CTS
//
//  Created by adel radwan on 18/10/2022.
//

import UIKit
import JGProgressHUD
import Moya
import Combine

private struct ErrorModel: Codable {
    let success: Bool
    let errorCode: Int
}

open class PowerNetwork: NSObject {
    
    //MARK: - Variables
    enum RequestStatus { case loading, finished }
    
    private var isLoadingInBackground: Bool = false
    
    private let loadingView = JGProgressHUD(style: .extraLight)
    
    private var printResultOut: Bool = true
    
    open private(set) var fileSize: String = ""
    
    private lazy var provider: MoyaProvider<MultiTarget> = {
        let provider = MoyaProvider<MultiTarget>(plugins: isLoadingInBackground ? [PowerBackgroundPlugin()] : [])
        return provider
    }()
    
    //MARK: - Combine variable
    private var subscription: Set<AnyCancellable>!
    
    @Published open private(set) var data: Data?
    
    @Published open private(set) var requestProgress: Progress?
    
    @Published open private(set) var networkErrorModel: PowerNetworkErrorLoadingModel?
    
    @Published private(set) var status: RequestStatus = .loading
    
    
    //MARK: - LifeCycle
    init(subscription: Set<AnyCancellable>, isLoadingInBackground: Bool) {
        super.init()
        self.subscription = subscription
        self.isLoadingInBackground = isLoadingInBackground
    }
    
    open func request(_ target: TargetType, at view: UIView? = nil, printOutResult: Bool = false, withProgress: Bool = false){
        self.printResultOut = printOutResult
//        guard self.status == .finished else { return }
        self.status = .loading
        self.showLoadingViewAt(view)
        self.completeRequest(target)
    }
    
    open func ignoreNetworkRequest() {
        self.status = .finished
    }
    
}

//MARK: - Request & Response
private extension PowerNetwork {
    
    func completeRequest(_ target: TargetType) {
        provider.request(.target(target), callbackQueue: DispatchQueue.main) { [weak self] progress in
            guard let self = self else { return }
            guard let progress = progress.progressObject else { return }
            self.requestProgress = progress
            self.fileSize = PowerUnits(bytes: progress.totalUnitCount).readablePrefexUnit
        } completion: { result in
            switch result {
            case .failure(let error):
                self.didRequestFailure(error)
            case .success(let response):
                self.didResponseSuccess(response, target: target)
            }
        }
    }
    
    func didResponseSuccess(_ response: Response, target: TargetType) {
        self.checkErrorModel(response) { [weak self] in
            guard let self = self else { return }
            self.printRespinseResultUsing(target, response: response, data: response.data)
            guard self.requestFailure(response.statusCode) == false else { return }
            guard self.checkIfDataCorrupted(response.data) == false else { return }
            self.data = response.data
        }
    }
    
    func didRequestFailure(_ moyaError : MoyaError){
        guard requestFailure(moyaError.errorCode) == true else { return }
    }
    
    func requestFailure(_ statusCode: Int) -> Bool {
        let request = PowerNetworkErrorLoadingModel(statusCode: statusCode)
        status = .finished
        loadingView.dismiss(animated: true)
        switch request.error == .noError {
        case true:
            return false
        case false:
            networkErrorModel = request
            return true
        }
    }
    
}

//MARK: - Helper
private extension PowerNetwork {
    
    func showLoadingViewAt(_ view: UIView?) {
        guard let view else { return }
        loadingView.show(in: view, animated: true)
        view.endEditing(true)
    }
    
    func printRespinseResultUsing(_ target: TargetType, response: Response, data: Data) {
        loadingView.dismiss(animated: true)
        guard printResultOut == true else { return }
        print("============Start (\(target.path)_\(response.statusCode)===================================")
        log(type: .warning, data.toJSONString)
        print("============End (\(target.path))======================================")
    }
    
    func checkIfDataCorrupted(_ data: Data) -> Bool {
        guard data.isEmpty else { return false }
        return self.requestFailure(9999)
    }
    
    func checkErrorModel(_ response: Response, _ completion: @escaping () -> ()) {
        let json = JSONDecoder()
        json.implement(useKeyDecodingStrategy: true, type: ErrorModel.self, data: response.data) { [weak self] s in
            guard let self = self else { return }
            guard s.success == false && s.errorCode == 57716 else { completion(); return }
            let _ = self.requestFailure(9999)
        }
    }
    
}
