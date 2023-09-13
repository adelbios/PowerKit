//
//  PowerViewModel.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit
import Combine
import SwiftUI

open class PowerViewModel<T: Codable>: ObservableObject {
    
    //NEW
    public enum RequestType {
        case get
        case post
        case getPagination
        case staticList
    }
    
    //Internar Variables
    internal private(set) var requestType: RequestType?
    
    //Open Variables
    open var action = PowerActionListProxy()
    public let json = JSONDecoder()
    open var subscription = Set<AnyCancellable>()
    
    //Move to init
    open private(set) weak var viewController: UIViewController?
    open private(set) weak var collectionView: UICollectionView?
    
    //MARK: - Public Variables
   open private(set) var powerItemsModel = [PowerItemViewModel]()
    
    open var spaceBetweenSections: CGFloat {
        get { return 0 }
        set { spaceBetweenEachSections = newValue }
    }

    
    //MARK: - private Variables
    internal let dataViewModel = PowerDataViewModel()
    
    private(set) var registeredCellsModel = [RegisteredCellsModel]()
    
    private var spaceBetweenEachSections: CGFloat = 0
    
    //MARK: - Combine Variables
    @Published open private(set) var didRequestCompleteEvent: Bool?
    
    
    //MARK: - Netwrok Variables
    open var isRequestingInBackground: Bool {
        return false
    }
    
    open lazy var network: PowerNetwork = {
        let network = PowerNetwork(subscription: self.subscription, isLoadingInBackground: isRequestingInBackground)
        return network
    }()
    
    //MARK: - LifeCycle
    required public override init() {
        super.init()
        initViewModel()
        didSuccessFetchData()
        handlePowerCellAction()
        observeNetworkError()
        buildSettings()
    }
    
    open func set(viewController: UIViewController? = nil, collectionView: UICollectionView? = nil) {
        self.viewController = viewController
        self.collectionView = collectionView
    }
    
    //MARK: - Override functions
    open func onInternetErrorEventFire(title: String, message: String) { }
    
    open func handlePowerCellAction() { }
    
    open func didFetchModels(_ model: T) { }
    
    open func didFetchModels(_ model: T, data: Data) { }
    
    open func buildSettings() { }
    
    open func didPostResponse(data: Data) { }
    
    open func didPostResponse(model: T, data: Data) { }
    
    open func initViewModel() { }
    
    //MARK: - Requested func
    open func makeHTTPRequest(){
        self.requestType = .get
    }
    
    open func fetchNextPaging(){
        self.requestType = .getPagination
    }
    
    open func fetchNextPaging(section: Int){
        self.requestType = .getPagination
    }
    
    open func postRequestAt(_ view: UIView) {
        self.requestType = .post
    }
    
    open func fetchStaticData(){
        self.requestType = .staticList
        self.network.ignoreNetworkRequest()
    }
    
    
}

//MARK: - Settings
public extension PowerViewModel {
    
    /// confgure Items settings
    /// - Parameter items: Collection of PowerItemModel, so when data is alrady existi in (viewModel.powerItemsModel) nothing happens
    func add(settings: [PowerItemViewModel]) {
        settings.forEach {
            guard powerItemsModel.contains($0) == false else { return }
            powerItemsModel.append($0)
        }
        dataViewModel.delegate?.didCreateSettings()
    }
    
    
    /// Setup cells that used in collectionView
    /// - Parameter cells: Desired cell
    func registeredCells(_ cells: [RegisteredCellsModel]) {
        registeredCellsModel = cells
    }
    
}

//MARK: - Data
public extension PowerViewModel {
    
    /// Add New Row\(s) for CollectionViewCell
    /// - Parameters:
    ///   - id: section number
    ///   - header: section header
    ///   - items: viewModel Cells
    func addNew(_ model: PowerAddNewModel) {
        dataViewModel.setPaginationRequested(requestType == .getPagination)
        dataViewModel.addNew(settings: powerItemsModel, addNewModel: model)
    }
    
    func addNew(group: [PowerAddNewModel]) {
        dataViewModel.setPaginationRequested(requestType == .getPagination)
        dataViewModel.addNewGroup(settings: powerItemsModel, groups: group)
    }
    
    
    func updateHeader(id: Int, cell: PowerCells) {
        dataViewModel.update(settings: powerItemsModel, id: id, header: .init(cell))
    }
    
    func updateSection(id: Int) {
        dataViewModel.update(section: id)
    }
    
    func removeAt(indexPath: IndexPath) {
        dataViewModel.removeItemAt(indexPath: indexPath, settings: powerItemsModel)
    }
    
    func removeSection(_ section: Int) {
        dataViewModel.removeSection(section: section, settings: powerItemsModel)
    }
    
    func remove(cell: PowerCells, section: Int) {
        dataViewModel.remove(cell: cell, section: section, settings: powerItemsModel)
    }
    
}

//MARK: - CollectionView Layout
internal extension PowerViewModel {
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (section, layoutEnvironment) in
            if self?.powerItemsModel.isEmpty ?? true {
                fatalError("Please use add(settings: [PowerItemModel]) func becuse there is no inital items in powerItemsModel")
            }
           
            return self?.powerItemsModel[section].layout
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = self.spaceBetweenEachSections
        layout.configuration = config
    
        return layout
    }
    
}


//MARK: - Helper
private extension PowerViewModel {
    
    func didSuccessFetchData(){
        network.$data
            .compactMap { $0 } // to remove nil value & first lunsh when data is Empty
            .sink { [weak self] data in
                guard let self = self else { return }
                switch self.requestType {
                case .get, .none:
                    self.didGetResponseSuccess(model: T.self, data: data)
                case .post:
                    self.didPostResponseSuccessValue(model: T.self, data: data)
                case .getPagination:
                    self.didGetResponseSuccess(model: T.self, data: data)
                case .staticList:
                    break
                }
                self.didRequestCompleteEvent = true
            }.store(in: &subscription) // Store subscripton to cancelled when dienit calling
    }
    
    func didGetResponseSuccess(model: T.Type, data: Data) {
        json.implement(type: T.self, data: data){
            self.didFetchModels($0)
            self.didFetchModels($0, data: data)
        }
    }
    
    func didPostResponseSuccessValue(model: T.Type, data: Data) {
        json.implement(type: T.self, data: data){
            self.didPostResponse(data: data)
            self.didPostResponse(model: $0, data: data)
        }
    }
    
    
    func observeNetworkError(){
        network.$networkErrorModel
            .receive(on: DispatchQueue.main)
            .compactMap{ $0 }
            .sink { [weak self] model in
                guard let self = self else { return }
                guard self.requestType == .post else { return }
                self.onInternetErrorEventFire(title: model.description, message: model.message)
            }.store(in: &subscription)
    }

    
}



