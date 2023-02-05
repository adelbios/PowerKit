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
    open private(set) var requestType: RequestType = .get
    open private(set) var isFetchMoreData: Bool = false
    open private(set) var paginationModel: PowerPaginationModel?
    open var subscription = Set<AnyCancellable>()
    open private(set) var powerItemsModel = [PowerItemModel]()
    open weak var viewController: UIViewController?
    open weak var collectionView: UICollectionView?
    open var action = PowerActionListProxy()
    public let json = JSONDecoder()
    
    open var spaceBetweenSections: CGFloat {
        get { return 16 }
        set { spaceBetweenEachSections = newValue }
    }
    
    open var useKeyDecodingStrategy: Bool {
        return false
    }
    
    public enum RequestType {
        case get
        case post
    }
    
    //MARK: - private Variables
    private let createViewModel = CreateViewModel()
    private let deleteViewModel = DeleteViewModel()
    private let helperViewModel = HelperViewModel()
    private(set) var registeredCellsModel = [RegisteredCellsModel]()
    private(set) var paginationSection: Int?
    private(set) var isStaticList: Bool = false
    private var spaceBetweenEachSections: CGFloat = 0
    
    //MARK: - Combine Variables
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
        self.isStaticList = false
    }
    
    open func postRequestAt(_ view: UIView) {
        self.requestType = .post
        self.isFetchMoreData = false
        self.isStaticList = false
    }
    
    open func fetchStaticData(){
        self.isStaticList = true
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
    
    open func setPagination(model: PowerPaginationModel, section: Int) -> PowerPaginationModel {
        let painationModel = PowerPaginationModel(current: model.current + 1, last: model.last)
        self.paginationSection = section
        self.paginationModel = painationModel
        return painationModel
    }
    
    open func contextMenuConfiguration(indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        return nil
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
    func addNew(
        headerItem: PowerUpdateItemSection? = nil, footerItem: PowerUpdateItemSection? = nil,
        item:  PowerCells, forSection: Int, at: Int? = nil, removeOld: Bool = false
    ) {
        createViewModel.deletedViewModel = deleteViewModel
        createViewModel.addNewTo(
            powerItemsModel, header: headerItem, footer: footerItem, newItems: [item],
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
    func addNew(
        headerItem: PowerUpdateItemSection? = nil, footerItem: PowerUpdateItemSection? = nil,
        items: [PowerCells], forSection: Int, at: Int? = nil, removeOld: Bool = false
    ) {
        createViewModel.deletedViewModel = deleteViewModel
        createViewModel.addNewTo(
            powerItemsModel, header: headerItem, footer: footerItem, newItems: items,
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
    
    /// Update PowerCell Item with new hashable value
    /// - Parameters:
    ///   - header: Update Header, set value to be null to avoid updating
    ///   - footer: Update Footer, set value to be null to avoid updating
    ///   - item: Update item in spesific section, set value to be null to avoid updating
    ///   - section: update values for spesific section
    func update(header: PowerCells?, footer: PowerCells?, item: PowerUpdatedModel?, section: Int) {
        helperViewModel.update(
            settings: powerItemsModel, newHeader: header, newFooter: footer,
            newItem: item, section: section
        )
        
        self.isReloadEventFire = true
    }
    
    /// collapse All Items from section, also we can use this func to collaps section items
    /// - Parameters:
    ///   - section: Section used to hide all element from it
    func collapseItem(section: Int) {
        let item = helperViewModel.setItemHidden(true, settings: powerItemsModel, section: section)
        self.isItemExpanding = (item.value, item.section)
    }
    
    /// Show All Items again for section, also we can use this func to expand section items
    /// - Parameters:
    ///   - section: Section used to hide all element from it
    func expandItem(section: Int) {
        let item = helperViewModel.setItemHidden(false, settings: powerItemsModel, section: section)
        self.isItemExpanding = (item.value, item.section)
    }
    
    /// Get PowerItemModel for spesific sections
    /// - Parameter Section: To set specific section
    /// - Returns: get current settings model
    func getPowerItemModel(section: Int) -> PowerItemModel? {
        return helperViewModel.getPowerItemModel(settings: powerItemsModel, section: section)
    }
    
    /// Show Or Hide Header you can use this func also to change size just pass visible value to be true
    /// - Parameters:
    ///   - visible: To Present or Hide
    ///   - newSize: Set new Footer size
    ///   - section: Pass section to implement this func in particular indexPath section
    func setHeaderSection(visible: Bool, newSize: NSCollectionLayoutSize?, section: Int) {
        helperViewModel.seItemtSection(
            isHeader: true, visible: visible, newSectionSize: newSize,
            settings: powerItemsModel, section: section
        )
        self.sectionChangedIdentifier = section
    }
    
    
    /// Show Or Hide Footer you can use this func also to change size just pass visible value to be true
    /// - Parameters:
    ///   - visible: To Present or Hide
    ///   - newSize: Set new Footer size
    ///   - section: Pass section to implement this func in particular indexPath section
    func setFooterSection(visible: Bool, newSize: NSCollectionLayoutSize?, section: Int) {
        helperViewModel.seItemtSection(
            isHeader: false, visible: visible, newSectionSize: newSize,
            settings: powerItemsModel, section: section
        )
        
        self.sectionChangedIdentifier = section
    }
    
    
    private func observeReloadUIForHeaderEvent() {
        helperViewModel.$didUpdateHeaderEventFire
            .compactMap { $0 }
            .sink { [weak self] in
                guard let self = self else { return }
                self.sectionChangedIdentifier = $0
            }.store(in: &subscription)
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
            
            if self?.network.status == .finished && model?.section.header?.cell == nil {
                model?.removeItemSection(model: model, isHeader: true)
            }
            
            if self?.network.status == .finished && model?.section.footer?.cell == nil {
                model?.removeItemSection(model: model, isHeader: false)
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
                self.json.implement(useKeyDecodingStrategy: self.useKeyDecodingStrategy, type: T.self, data: data){
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



