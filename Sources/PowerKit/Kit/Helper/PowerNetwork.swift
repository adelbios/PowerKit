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

open class PowerNetwork: NSObject {
    
    //MARK: - Variables
    enum RequestStatus { case loading, finished }
    
    private var isLoadingInBackground: Bool = false
    
    private let loadingView = JGProgressHUD(style: .extraLight)
    
    private var printResultOut: Bool = true
    
    private(set) var fileSize: String = ""
    
    private lazy var provider: MoyaProvider<MultiTarget> = {
        let provider = MoyaProvider<MultiTarget>(plugins: isLoadingInBackground ? [PowerBackgroundPlugin()] : [])
        return provider
    }()
    
    //MARK: - Combine variable
    private var subscription: Set<AnyCancellable>!
    
    @Published private(set) var data: Data?
    
    @Published open var requestProgress: Progress?
    
    @Published private(set) var networkErrorModel: PowerNetworkErrorLoadingModel?
    
    @Published private(set) var status: RequestStatus = .finished
    
    
    //MARK: - LifeCycle
    init(subscription: Set<AnyCancellable>, isLoadingInBackground: Bool) {
        super.init()
        self.subscription = subscription
        self.isLoadingInBackground = isLoadingInBackground
    }
    
    open func request(_ target: TargetType, at view: UIView? = nil, printOutResult: Bool = false, withProgress: Bool = false){
        self.printResultOut = printOutResult
        guard self.status == .finished else { return }
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

//        provider.requestWithProgressPublisher(.target(target), callbackQueue: DispatchQueue.main)
//            .sink { [weak self] completion in
//                guard let self = self else { return }
//                guard case let .failure(error) = completion else { return }
//                self.didRequestFailure(error)
//            } receiveValue: { [weak self] response in
//                guard let self = self else { return }
//                guard let progress = response.progressObject else { return }
//                self.requestProgress = progress
//                self.fileSize = PowerUnits(bytes: progress.totalUnitCount).readablePrefexUnit
//                guard let res = response.response else { return }
//                self.didResponseSuccess(res, target: target)
//            }.store(in: &subscription)
    }
    
    func didResponseSuccess(_ response: Response, target: TargetType) {
        self.printRespinseResultUsing(target, data: response.data)
        guard requestFailure(response.statusCode) == false else { return }
        guard checkIfDataCorrupted(response.data) == false else { return }
        self.data = response.data
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
    
    func printRespinseResultUsing(_ target: TargetType, data: Data) {
        loadingView.dismiss(animated: true)
        guard printResultOut == true else { return }
        print("============Start (\(target.path))===================================")
        log(type: .warning, data.toJSONString)
        print("============End (\(target.path))======================================")
    }
    
    func checkIfDataCorrupted(_ data: Data) -> Bool {
        guard data.isEmpty else { return false }
        return self.requestFailure(9999)
    }
    
}
