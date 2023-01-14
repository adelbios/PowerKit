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
    public enum RequestType { case get, post }
    open private(set) var powerItemsModel = [PowerItemModel]()
    open var subscription = Set<AnyCancellable>()
    open weak var viewController: UIViewController?
    open weak var collectionView: UICollectionView?
    open var action = PowerActionListProxy()
    public let json = JSONDecoder()
    
    open var spaceBetweenSections: CGFloat {
        get { return 16 }
        set { spaceBetweenEachSections = newValue }
    }
    
    //MARK: - private Variables
    private(set) var isFetchMoreData: Bool = false
    private(set) var registeredCellsModel = [RegisteredCellsModel]()
    private(set) var paginationSection: Int?
    private var spaceBetweenEachSections: CGFloat = 0
    private let createViewModel = CreateViewModel()
    private let deleteViewModel = DeleteViewModel()
    private let helperViewModel = HelperViewModel()
    private let paginationViewModel = PaginationViewModel()
    
    //MARK: - Combine Variables
    open private(set) var requestType: RequestType = .get
    @Published open private(set) var didRequestCompleteEvent: Bool?
    @Published open private(set) var isEmptyDataEventFire: Bool?
    @Published private(set) var isReloadEventFire: Bool?
    @Published private(set) var isAddSettingsEventFire: Bool?
    @Published private(set) var isItemExpanding: (value: Bool, section: Int)?
    @Published private(set) var sectionChangedIdentifier: Int?
    
    
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
        observeDeleteItemEvent()
        observeHeaderUpdatedEvent()
        observeReloadUIForHeaderEvent()
        observeReloadUIEvent()
    }
    
    
    //MARK: - Override functions
    open func onInternetErrorEventFire(title: String, message: String) {
    }
    
    open func handlePowerCellAction() {
    }
    
    open func didFetchModels(_ model: T) {
    }
    open func didFetchModels(_ model: T, data: Data) {
    }
    
    open func makeHTTPRequest(){
        self.requestType = .get
        self.isFetchMoreData = false
    }
    
    open func postRequestAt(_ view: UIView) {
        self.requestType = .post
        self.isFetchMoreData = false
    }
    
    open func fetchStaticData(){
        self.network.ignoreNetworkRequest()
    }
    
    @objc open dynamic func configureViewModelSettings() {
    }
    
    //MARK: - Paging request
    open func fetchNextPaging(){
        self.isFetchMoreData = true
    }
    
    open func updateUI() {
        isReloadEventFire = true
    }
    
    internal func setItems(isEmpty: Bool) {
        self.isEmptyDataEventFire = isEmpty
    }
    
}

//MARK: - Settings
public extension PowerViewModel {
    
    /// confgure Items settings
    /// - Parameter items: Collection of PowerItemModel, so when data is alrady existi in (viewModel.powerItemsModel) nothing happens
    func add(settings: [PowerItemModel]) {
        settings.forEach {
            guard powerItemsModel.contains($0) == false else { return }
            powerItemsModel.append($0)
        }
        isAddSettingsEventFire = true
    }
    
    
    /// Setup cells that used in collectionView
    /// - Parameter cells: Desired cell
    func registeredCells(_ cells: [RegisteredCellsModel]) {
        registeredCellsModel = cells
    }
    
}

//MARK: - Create
public extension PowerViewModel {
    
    /// Append Or Insert new items to viewModel.powerItemsModel
    /// - Parameters:
    ///   - item: When new item is alrady existi in (viewModel.powerItemsModel) nothing happens
    ///   - forSection: To add new item at specific section
    ///   - at: Used for append or insert, so when ignoring this we append new item
    ///   - removeOld: Used for remove previous item to avoid dubplication sometimes, defualt value is false
    func addNew(headerItem: PowerCells? = nil, item:  PowerCells, forSection: Int, at: Int? = nil, removeOld: Bool = false) {
        createViewModel.addNewTo(
            powerItemsModel, header: headerItem, newItems: [item],
            section: forSection, at: at, removeOld: removeOld
        )
        self.isReloadEventFire = true
    }
    
    
    /// Append Or Insert new collection of items to viewModel.powerItemsModel
    /// - Parameters:
    ///   - items: When new collection of items is alrady existi in (viewModel.powerItemsModel) nothing happens
    ///   - forSection: To add new item at specific section, it's work only when new items has same type of PowerCells
    ///   - at: Used for append or insert, so when ignoring this we append new item
    ///   - removeOld: Used for remove previous item to avoid dubplication sometimes, defualt value is false
    func addNew(headerItem: PowerCells? = nil, items:  [PowerCells], forSection: Int, at: Int? = nil, removeOld: Bool = false) {
        createViewModel.addNewTo(
            powerItemsModel, header: headerItem, newItems: items,
            section: forSection, at: at, removeOld: removeOld
        )
        self.isReloadEventFire = true
    }
    
    
}

//MARK: - Delete
public extension PowerViewModel {
    
    
    /// Remove All Items for each Sections
    /// - Parameter keepSectionVisible: When item is Empty Keep Section Visibale or not
    /// - Parameter headerModel: Some times you need to update header after deleted, and it's work only when keepSectionVisible is true
    func removeAll(headerModel: PowerCells? = nil, keepSectionVisible: Bool) {
        deleteViewModel.removeAll(
            settings: powerItemsModel,
            header: headerModel,
            keepSectionVisible: keepSectionVisible
        )
    }
    
    /// Remove All Item for spesific section
    /// - Parameter section: To select which section and delete all its data
    /// - Parameter keepSectionVisible: After Remove All Keep Section Visibale or not
    /// - Parameter headerModel: Some times you need to update header after deleted, and it's work only when keepSectionVisible is true
    func removeItemsFrom(headerModel: PowerCells? = nil, section: Int, keepSectionVisible: Bool) {
        deleteViewModel.removeItems(
            settings: powerItemsModel,
            header: headerModel,
            section: section,
            keepSectionVisible: keepSectionVisible
        )
    }
    
    /// Remove Item from spesific section
    /// - Parameter item: reomve item from model
    /// - Parameter section: To select which section and delete all its data
    /// - Parameter keepSectionVisibleWhenRemovedAll: When item is Empty Keep Section Visibale or not
    /// - Parameter headerModel: Some times you need to update header after deleted
    func remove(headerModel: PowerCells? = nil, item: PowerCells, section: Int, keepSectionVisibleWhenRemovedAll: Bool) {
        deleteViewModel.remove(
            settings: powerItemsModel,
            header: headerModel,
            item: item,
            section: section,
            keepSectionVisible: keepSectionVisibleWhenRemovedAll
        )
    }
    
    /// Remove Item from spesific section
    /// - Parameter index: item index position
    /// - Parameter section: To select which section and delete all its data
    /// - Parameter headerModel: Some times you need to update header after deleted
    func remove(index: Int, headerModel: PowerCells? = nil, section: Int, keepSectionVisibleWhenRemovedAll: Bool) {
        deleteViewModel.remove(
            settings: powerItemsModel,
            header: headerModel,
            itemIndex: index,
            section: section,
            keepSectionVisible: keepSectionVisibleWhenRemovedAll
        )
    }
    
    
    private func observeDeleteItemEvent() {
        deleteViewModel.$didItemDeletedSuccessfully
            .compactMap { $0 }
            .filter { $0 == true }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isReloadEventFire = true
            }.store(in: &subscription)
    }
    
    private func observeHeaderUpdatedEvent() {
        deleteViewModel.$didUpdateHeaderEventFire
            .compactMap { $0 }
            .sink { [weak self] in
                guard let self = self else { return }
                self.sectionChangedIdentifier = $0
            }.store(in: &subscription)
    }
    
}

//MARK: - HelperViewModel
public extension PowerViewModel {
    
    /// Update Header Section Item for speisifc section
    /// - Parameters:
    ///   - itemSection: new sectionHeader to be updating
    ///   - forSection: To update item in specific section
    func update(header: PowerCells?, item: PowerUpdatedModel?, section: Int) {
        helperViewModel.update(
            settings: powerItemsModel,
            newHeader: header,
            newItem: item,
            section: section
        )
    }
    
    /// Hide All Items from section, also we can use this func to collaps section items
    /// - Parameters:
    ///   - section: Section used to hide all element from it
    func hide(section: Int) {
        let item = helperViewModel.setItemHidden(true, settings: powerItemsModel, section: section)
        self.isItemExpanding = (item.value, item.section)
    }
    
    /// Show All Items again for section, also we can use this func to expand section items
    /// - Parameters:
    ///   - section: Section used to hide all element from it
    func show(section: Int) {
        let item = helperViewModel.setItemHidden(false, settings: powerItemsModel, section: section)
        self.isItemExpanding = (item.value, item.section)
    }
    
    /// search for items
    /// - Parameters:
    ///   - newItems: to replace old item with new item
    ///   - section: To update item in specific section
    ///   - header: update header data if you needed
    func search(header: PowerCells? = nil, newItems: [PowerCells], section: Int) {
        helperViewModel.search(settings: powerItemsModel, headerData: header, item: newItems, section: section)
    }
    
    /// Get PowerItemModel for spesific sections
    /// - Parameter Section: To set specific section
    /// - Returns: get current settings model
    func getPowerItemModel(section: Int) -> PowerItemModel? {
        return helperViewModel.getPowerItemModel(settings: powerItemsModel, section: section)
    }
    
    private func observeReloadUIForHeaderEvent() {
        helperViewModel.$didUpdateHeaderEventFire
            .compactMap { $0 }
            .sink { [weak self] in
                guard let self = self else { return }
                self.sectionChangedIdentifier = $0
            }.store(in: &subscription)
    }
    
    private func observeReloadUIEvent() {
        helperViewModel.$reloadUI
            .compactMap { $0 }
            .filter { $0 == true }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isReloadEventFire = true
            }.store(in: &subscription)
    }
    
}

//MARK: - Pagination ViewModel
public extension PowerViewModel {
    
    
    /// Get model that used in pagination
    /// - Parameter section: To set correct section
    /// - Returns: PowerLoadMoreModel.Item with nil value
    func getLoadMoreModel(section: Int) -> PowerLoadMoreModel.Item? {
        paginationSection = section
        return paginationViewModel.get(settings: powerItemsModel, section: section)
    }
    
    /// Update Load more model, use this function in web serves response, NOTE: when you call this function and web service does not have (current page & last page) values avoid to pass current page, set last page value to be estemated value and check for last page if have next url or not
    ///  - Example: self.updateLoadMore(section: 0, lastPage: model.nextURL == nil ? nil : 50000)
    /// - Parameters:
    ///   - section: update it for specific section
    ///   - currentPage: new current page
    ///   - lastPage: new last Page
    func updateLoadMore(section: Int, model: PowerLoadMoreModel.Item) {
        paginationSection = section
        paginationViewModel.set(
            settings: powerItemsModel,
            section: section,
            loadMoreModel: model
        )
    }
    
}

//MARK: - CollectionView Layout
internal extension PowerViewModel {
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (section, layoutEnvironment) in
            if self?.powerItemsModel.isEmpty ?? true {
                fatalError("Please use add(settings: [PowerItemModel]) func becuse there is no inital items in powerItemsModel")
            }
            let model = self?.powerItemsModel[section]
            
            if self?.network.status == .finished && model?.itemSection?.cell == nil {
                model?.removeHeader(model: model)
            }
            
            return model?.layout
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
                self.json.implement(useKeyDecodingStrategy: false, type: T.self, data: data){
                    self.didFetchModels($0)
                    self.didFetchModels($0, data: data)
                    self.didRequestCompleteEvent = true
                }
            }.store(in: &subscription) // Store subscripton to cancelled when dienit calling
    }
    
    
    func observeNetworkError(){
        network.$networkErrorModel
            .receive(on: DispatchQueue.main)
            .compactMap{ $0 }
            .sink { model in
                guard self.requestType == .post else { return }
                self.onInternetErrorEventFire(title: model.description, message: model.message)
            }.store(in: &subscription)
    }
    
    
}


