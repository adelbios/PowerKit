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
import Alamofire

private struct ErrorModel: Codable {
    let success: Bool?
    let errorCode: Int?
}

open class PowerNetwork: NSObject {
    
    //MARK: - Variables
    enum RequestStatus { case loading, finished }
    
    private var isReuestLoading: Bool = false
    
    private var isLoadingInBackground: Bool = false
    
    private var isUploadingRequest: Bool = false
    
    private let loadingView = JGProgressHUD(style: .extraLight)
    
    private var printResultOut: Bool = true
    
    open private(set) var fileSize: String = ""
    
    private var previousRequest: Moya.Cancellable?
    
    private lazy var provider: MoyaProvider<MultiTarget> = {
        let configuration = URLSessionConfiguration.default
        if isUploadingRequest {
            configuration.timeoutIntervalForRequest = 60 * 5
            configuration.timeoutIntervalForResource = 60 * 5
        }
        let alamoFireManager = Alamofire.Session(configuration: configuration)
        let provider = MoyaProvider<MultiTarget>(
            session: alamoFireManager,
            plugins: isLoadingInBackground ? [PowerBackgroundPlugin()] : []
        )
        return provider
    }()
    
    //MARK: - Combine variable
    private var subscription: Set<AnyCancellable>!
    
    @Published open private(set) var data: Data?
    
    @Published open private(set) var requestProgress: Progress?
    
    @Published open private(set) var networkErrorModel: PowerNetworkErrorLoadingModel?
    
    @Published private(set) var status: RequestStatus = .loading
    
    
    //MARK: - LifeCycle
    public init(subscription: Set<AnyCancellable>,
         isUploadingRequest: Bool, isLoadingInBackground: Bool
    ) {
        super.init()
        self.subscription = subscription
        self.isUploadingRequest = true
        self.isLoadingInBackground = isLoadingInBackground
    }
    
    open func request(_ target: TargetType, at view: UIView? = nil, printOutResult: Bool = false, withProgress: Bool = false){
        self.printResultOut = printOutResult
        guard self.isReuestLoading == false else { return }
        self.isReuestLoading = true
        self.status = .loading
        self.showLoadingViewAt(view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.completeRequest(target)
        }
       
        
    }
    
    open func ignoreNetworkRequest() {
        self.status = .finished
    }
    
    open func cancleRequest() {
        previousRequest?.cancel()
    }
}

//MARK: - Request & Response
private extension PowerNetwork {
    
    func completeRequest(_ target: TargetType) {
        previousRequest = provider.request(.target(target), callbackQueue: DispatchQueue.main) { [weak self] progress in
            guard let self = self else { return }
            guard let progress = progress.progressObject else { return }
            self.requestProgress = progress
            self.fileSize = PowerUnits(bytes: progress.totalUnitCount).readablePrefexUnit
        } completion: { result in
            switch result {
            case .failure(let error):
                print(error)
                self.isReuestLoading = false
                self.didRequestFailure(error)
            case .success(let response):
                self.isReuestLoading = false
                if response.statusCode != 200 {
                    guard self.requestFailure(response.statusCode) == true else { return }
                } else {
                    self.didResponseSuccess(response, target: target)
                }
                
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
