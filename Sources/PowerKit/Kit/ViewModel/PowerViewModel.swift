//
//  PowerViewModel.swift
//  CTS
//
//  Created by adel radwan on 15/10/2022.
//

import UIKit
import Combine

open class PowerViewModel<T: Codable>: NSObject {
    
    //MARK: - Public Variables
    public let json = JSONDecoder()
    
    open var subscription = Set<AnyCancellable>()
    
    open weak var viewController: UIViewController?
    open weak var collectionView: UICollectionView?
    
    open var action = PowerActionListProxy()
    
    open var isPowerItemsModelEmpty: Bool {
        let items = self.powerItemsModel.map({ $0.item }).map { $0.isEmpty }.filter { $0 == false }
        return items.isEmpty
    }
    
    open var spaceBetweenSections: CGFloat {
        return 16
    }
    
    //MARK: - private Variables
    private(set) var powerItemsModel = [PowerItemModel]()
    private(set) var registeredCellsModel = [RegisteredCellsModel]()
    
    private var requestType: RequestType = .get
    
    private var errorModelInsertion: ErrorModelInsertion? {
        didSet {
            guard let errorModelInsertion else { return }
            checkErrorModelInsertion(errorModelInsertion)
        }
    }
    
    
    private enum ErrorModelInsertion: String {
        case sectionNotFound
        case sectionMismatch
        case useInit
        case setupSettings
    }
    
    private enum RequestType {
        case get
        case post
    }
    
    //MARK: - Combine Variables
    @Published private(set) var isReloadEventFire: Bool?
    @Published private var isSetupSettingsEnabled: Bool?
    @Published open var didRequestCompleteEvent: Bool?
    
    
    //MARK: - Netwrok Variables
    open var isLoadingInBackground: Bool {
        return false
    }
    
    open lazy var network: PowerNetwork = {
        let network = PowerNetwork(subscription: self.subscription, isLoadingInBackground: isLoadingInBackground)
        return network
    }()
    
    //MARK: - LifeCycle
    required public override init() {
        super.init()
        configureViewModelSettings()
        didSuccessFetchData()
        handlePowerCellAction()
        observeNetworkError()
    }
    
    
    //MARK: - Override functions
    open func showAlertForInternetConnectionError(title: String, message: String) {
        
    }
    
    @objc open dynamic func configureViewModelSettings() {
    }
    
    open func handlePowerCellAction() {
    }
    
    open func didFetchModels(_ model: T, data: Data) {
    }
    
    open func makeHTTPRequest(){
        self.requestType = .get
    }
    
    open func postRequestAt(_ view: UIView) {
        self.requestType = .post
    }
    
    open func fetchStaticData(){
        self.network.ignoreNetworkRequest()
    }
    
    //MARK: - Paging request
    open func fetchNextPaging(){
    }
    
    open func increaseCurrentPage(forSection: Int) -> Int? {
        guard let model = fetchLoadMoreModel(forSection: forSection) else { return nil }
        let page = model.currentPage + 1
        guard model.lastPage > page else { return nil }
        model.currentPage = page
        return page
    }
    
    open func updateLoadMore(forSection: Int, currentPage: Int? = nil, lastPage: Int? = nil) {
        guard self.powerItemsModel.isEmpty == false else { return }
        guard let model = self.powerItemsModel[forSection].loadMoreSection else { return }
        if let currentPage {
            model.item.currentPage = currentPage
        }
        
        if let lastPage {
            model.item.lastPage = lastPage
        } else {
            model.item.lastPage = model.item.currentPage
        }
    }
    
}

//MARK: - Items manipulation
public extension PowerViewModel {
    
    
    /// confgure Items settings
    /// - Parameter items: Collection of PowerItemModel, so when data is alrady existi in (viewModel.powerItemsModel) nothing happens
    func add(settings: [PowerItemModel]) {
        settings.forEach {
            guard powerItemsModel.contains($0) == false else { return }
            registeredCellsModel.append(contentsOf: $0.registeredCells)
            powerItemsModel.append($0)
        }
        isReloadEventFire = true
    }
    
    /// Append Or Insert new items to viewModel.powerItemsModel
    /// - Parameters:
    ///   - item: When new item is alrady existi in (viewModel.powerItemsModel) nothing happens
    ///   - forSection: To add new item at specific section
    ///   - at: Used for append or insert, so when ignoring this we append new item
    func addNew(item:  PowerCells, forSection: Int, at: Int? = nil) {
        switch powerItemsModel.isEmpty {
        case true:
            self.errorModelInsertion = .useInit
        case false:
            addNewItem(item, forSection: forSection, at: at)
            isReloadEventFire = true
        }
        
    }
    
    
    /// Append Or Insert new collection of items to viewModel.powerItemsModel
    /// - Parameters:
    ///   - items: When new collection of items is alrady existi in (viewModel.powerItemsModel) nothing happens
    ///   - forSection: To add new item at specific section, it's work only when new items has same type of PowerCells
    ///   - at: Used for append or insert, so when ignoring this we append new item
    func addNew(items:  [PowerCells], forSection: Int, at: Int? = nil) {
        switch powerItemsModel.isEmpty {
        case true:
            self.errorModelInsertion = .useInit
        case false:
            addNewItems(items, forSection: forSection, at: at)
            isReloadEventFire = true
        }
        
    }
    
    
    /// Remove All Item for spesific section
    /// - Parameter section: To select which section and delete all its data
    /// - Parameter keepSectionVisible: After Remove All Keep Section Visibale or not
    func removeAllItemsUsing(section: Int, keepSectionVisible: Bool) {
        guard powerItemsModel.isEmpty == false else { return }
        guard let model = powerItemsModel.filter({ $0.section == section }).first else {
            self.errorModelInsertion = .sectionNotFound
            return
        }
        model.item.removeAll()
        isReloadEventFire = true
    }
    
    /// Remove Item from spesific section
    /// - Parameter item: New item to be insertion
    /// - Parameter section: To select which section and delete all its data
    /// - Parameter keepSectionVisible: When item is Empty Keep Section Visibale or not
    func remove(item: PowerCells, section: Int, keepSectionVisible: Bool) {
        guard let model = self.powerItemsModel.filter({ $0.section == section }).first else { return }
        guard let index = model.item.firstIndex(where: { $0.item == item.item }) else { return }
        let powerModel = powerItemsModel[section]
        powerModel.item.remove(at: index)
        if powerModel.item.isEmpty {
            setSectionVisibale(keepSectionVisible, model: powerModel)
        }
        
        isReloadEventFire = true
    }
    
    
    /// Remove All Items in All Sections
    /// - Parameter keepSectionVisible: When item is Empty Keep Section Visibale or not
    func removeAll(keepSectionVisible: Bool) {
        guard powerItemsModel.isEmpty == false else { return }
        powerItemsModel.forEach {
            setSectionVisibale(keepSectionVisible, model: $0)
        }
        isReloadEventFire = true
    }
    
    
    /// Update Header Section Item for speisifc section
    /// - Parameters:
    ///   - itemSection: new sectionHeader to updating
    ///   - forSection: To update item in specific section
    func update(itemSection: PowerCells, forSection: Int) {
        guard powerItemsModel.isEmpty == false else { return }
        guard let item = powerItemsModel.first(where: { $0.section == forSection }) else {
            self.errorModelInsertion = .sectionNotFound
            return
        }
        guard let sectionItem = item.itemSection else { return }
        sectionItem.cell = itemSection
        isReloadEventFire = true
    }
    
    
}

//MARK: - Show & Hide
public extension PowerViewModel {
    
    
    /// Hide All Items from section, also we can use this func to collaps section items
    /// - Parameters:
    ///   - section: Section used to hide all element from it
    ///   - removePowerCells: To remove all item from list, so when you show again the list for spisific section is empty
    ///   - keepSectionVisible: To Keep Section Visible after hide or not
    func hide(section: Int, removePowerCells: Bool, keepSectionVisible: Bool) {
        guard let model = powerItemsModel.first(where: { $0.section == section }) else {
            self.errorModelInsertion = .sectionNotFound; return
        }
        
        model.isItemVisible = false
        setSectionVisibale(keepSectionVisible, model: model)
        
        if removePowerCells == true {
            model.item.removeAll()
        }
        isReloadEventFire = true
    }
    
    
    /// Show All Items again for section, also we can use this func to expand section items
    /// - Parameters:
    ///   - section: Section used to hide all element from it
    ///   - keepSectionVisible: To Keep Section Visible after show section agin
    func show(section: Int, keepSectionVisible: Bool) {
        guard let model = powerItemsModel.first(where: { $0.section == section }) else {
            self.errorModelInsertion = .sectionNotFound; return
        }
        model.isItemVisible = true
        setSectionVisibale(keepSectionVisible, model: model)
        isReloadEventFire = true
    }
    
    
}

//MARK: - CollectionView Layout
public extension PowerViewModel {
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (section, layoutEnvironment) in
            if self?.powerItemsModel.isEmpty ?? true { self?.errorModelInsertion = .setupSettings }
            return self?.powerItemsModel[section].layout
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = self.spaceBetweenSections
        layout.configuration = config
        return layout
    }
    
}

//MARK: - Add New Item
private extension PowerViewModel {
    
    func addNewItem(_ item:  PowerCells, forSection: Int, at: Int? = nil) {
        guard let model = self.powerItemsModel.filter({ $0.section == forSection }).first else {
            errorModelInsertion = .sectionNotFound; return
        }
        model.isItemVisible = true
        setSectionVisibale(true, model: model)
        appendOrInsertNewItem(at: at, powerItemModel: model, newItem: item, forSection: forSection)
    }
    
    func addNewItems(_ items: [PowerCells], forSection: Int, at: Int? = nil) {
        guard let model = self.powerItemsModel.filter({ $0.section == forSection }).first else {
            errorModelInsertion = .sectionNotFound; return
        }
        model.isItemVisible = true
        setSectionVisibale(true, model: model)
        items.forEach { cell in
            appendOrInsertNewItem(at: at, powerItemModel: model, newItem: cell, forSection: forSection)
        }//End foreach
    }
    
}

//MARK: - Helper
private extension PowerViewModel {
    
    func didSuccessFetchData(){
        network.$data
            .compactMap { $0 } // to remove nil value & first lunsh when data is Empty
            .sink { [weak self] data in
                guard let self = self else { return }
                self.json.implement(useKeyDecodingStrategy: false, type: T.self, data: data){
                    self.didFetchModels($0, data: data)
                    self.didRequestCompleteEvent = true
                }
            }.store(in: &subscription) // Store subscripton to cancelled when dienit calling
    }
    
    
    func appendOrInsertNewItem(at: Int?, powerItemModel: PowerItemModel, newItem: PowerCells, forSection: Int) {
        
        switch powerItemModel.item.isEmpty {
        case true:
            createNewItem(at: at, powerItemModel: powerItemModel, newItem: newItem)
        case false:
            guard let firstItem = powerItemModel.item.first else { return }
            guard type(of: firstItem).cellId == type(of: newItem).cellId else {
                errorModelInsertion = .sectionMismatch; return
            }
            createNewItem(at: at, powerItemModel: powerItemModel, newItem: newItem)
        }
        
    }
    
    func createNewItem(at: Int?, powerItemModel: PowerItemModel, newItem: PowerCells) {
        guard powerItemModel.item.contains(newItem) == false else { return }
        switch at != nil {
        case true:
            powerItemModel.item.insert(newItem, at: at!)
        case false:
            powerItemModel.item.append(newItem)
        }
    }
    
    func setSectionVisibale(_ value: Bool, model: PowerItemModel) {
        switch value {
        case true:
            guard model.layout.boundarySupplementaryItems.isEmpty == true else { return }
            model.layout.boundarySupplementaryItems = model.boundarySupplementaryItem
        case false:
            model.layout.boundarySupplementaryItems = []
        }
    }
    
    func fetchLoadMoreModel(forSection: Int) -> PowerLoadMoreModel.Item? {
        guard self.powerItemsModel.isEmpty == false else { return nil }
        guard let model = self.powerItemsModel[forSection].loadMoreSection else { return nil }
        return model.item
    }
    
    private func checkErrorModelInsertion(_ model: ErrorModelInsertion) {
        switch model {
            case .useInit:
                fatalError("Please use add(items: [PowerItemModel]) func becuse there is no inital items in powerItemsModel")
            case .sectionMismatch:
                fatalError("Item in section is mismatch")
            case .sectionNotFound:
                fatalError("Section not exist in powerItemsModel")
            case .setupSettings:
                fatalError("Please setup Settings for PowerItemModel, Note: the required settings is (section & layout & registeredCells) other settings is optional (not necessary)")
        }
    }
    
    func observeNetworkError(){
        network.$networkErrorModel
            .receive(on: DispatchQueue.main)
            .compactMap{ $0 }
            .sink { model in
                guard self.requestType == .post else { return }
                self.showAlertForInternetConnectionError(title: model.description, message: model.message)
            }.store(in: &subscription)
    }
    
    
    
}


