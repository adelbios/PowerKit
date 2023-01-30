//
//  PowerViewController.swift
//  CTS
//
//  Created by adel radwan on 18/10/2022.
//
import UIKit
import Combine

fileprivate typealias diffable = PowerDiffableDataSource<Int, AnyHashable>
fileprivate typealias snapshots = NSDiffableDataSourceSnapshot<Int, AnyHashable>


open class PowerViewController<U: Any, Z: PowerViewModel<U>>: UIViewController, UICollectionViewDelegate,
                                                              UICollectionViewDataSourcePrefetching {
    
    //MARK: - Variables
    open var powerSettings = PowerSettings()
    open var viewModel = Z()
    
    private var isRequestReloadingFromPullToRefresh = false
    private var diffableDataSource: diffable?
    private var itemInSection = [AnyHashable]()
    private var supplementaryView = PowerHeaderFooterDiffableView()
    
    //MARK: - UI Variables
    open lazy var collectionView: PowerCollectionView = {
        let collectionView = PowerCollectionView(frame: .zero, collectionViewLayout: viewModel.createCollectionViewLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.prefetchDataSource = self
        return collectionView
    }()
    
    
    //MARK: - LifeCycle
    open override func viewDidLoad() {
        settingConfigure()
        super.viewDidLoad()
        settings()
        createDiffableDataSource()
        createDiffableSections()
        reloadSettingsModel()
        reloadPowerItemModel()
        observeRequestStatus()
        observeNetworkError()
        observeEmptyViewActionButtonClicked()
        eventForCustomCell()
        setupPullToRefresh()
        reloadSections()
        observeItemExpanding()
    }
    
    //MARK: - Override func
    open func settingConfigure() {
    }
    
    open func onInternetErrorEventFire(title: String, message: String) {
    }
    
    //MARK: - Collection View Protocol
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelect(indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didDeSelect(indexPath: indexPath)
    }
    
    
    //MARK: - ScrollView
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    open func scrollViewDidFinished(_ scrollView: UIScrollView) {
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidFinished(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidFinished(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidFinished(scrollView)
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        guard let section = viewModel.paginationSection, distance < 200  else { return }
        let model = self.viewModel.powerItemsModel[section]
        guard model.items.isEmpty == false else { return }
        guard let paginationModel = self.viewModel.paginationModel else { return }
        guard paginationModel.current <= paginationModel.last else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchNextPaging()
        }
    }
    
    /// Change color for both self.view & self.collectionView
    /// - Parameter color: New Color
    open func setBackground(color: UIColor) {
        self.collectionView.backgroundColor = color
        self.view.backgroundColor = color
    }
    
    /// To Fill Collection View to subView
    /// - Parameter padding: To add margin to constraint
    open func setupCollectionViewConstraint(padding: UIEdgeInsets = .zero) {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(padding.top)
            $0.leading.equalToSuperview().inset(padding.left)
            $0.bottom.equalToSuperview().inset(padding.bottom)
            $0.trailing.equalToSuperview().inset(padding.right)
        }
    }
    
}

//MARK: - Settings
private extension PowerViewController {
    
    func settings() {
        view.isSkeletonable = true
        collectionView.isSkeletonable = true
        viewModel.viewController = self
        viewModel.collectionView = self.collectionView
        PowerNetworkReachability.shared.startListening()
    }
    
}

//MARK: - Events
private extension PowerViewController {
    
    func reloadPowerItemModel() {
        viewModel.$isReloadEventFire
            .compactMap { $0 }
            .filter { $0 == true }
            .sink { [weak self] _ in
                guard let self else { return }
                self.setupSnapshot(isSettings: false)
            }.store(in: &viewModel.subscription)
    }
    
    func reloadSettingsModel() {
        viewModel.$isAddSettingsEventFire
            .compactMap { $0 }
            .filter { $0 == true }
            .sink { [weak self] _ in
                guard let self else { return }
                self.setupSnapshot(isSettings: true)
            }.store(in: &viewModel.subscription)
    }
    
    func observeRequestStatus() {
        self.viewModel.network.$status
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] status in
                guard let self = self else { return }
                status == .loading ? self.requestStatusLoading() : self.requestStatusFinished()
            }.store(in: &viewModel.subscription)
    }
    
    func observeNetworkError() {
        viewModel.network.$networkErrorModel
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] model in
                guard let self = self else { return }
                self.configureErrorModel(model)
            }.store(in: &viewModel.subscription)
    }
    
    
    func observeEmptyViewActionButtonClicked() {
        self.collectionView.emptyView.$isActionButtonClicked
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] _ in
                guard let self else { return }
                self.isRequestReloadingFromPullToRefresh = false
                self.reloadRequest()
            }.store(in: &viewModel.subscription)
    }
    
}


//MARK: - Request Status
private extension PowerViewController {
    
    func requestStatusLoading() {
        guard PowerNetworkReachability.shared.isReachable == true else { return }
        guard isRequestReloadingFromPullToRefresh == false else { return }
        guard let isEmpty = viewModel.isEmptyDataEventFire else { setDwonloadContentStyle(); return }
        switch isEmpty {
        case true:
            setDwonloadContentStyle()
        case false:
            guard powerSettings.showSkeletonWhenItemsIsNotEmpty == true else { return }
            setDwonloadContentStyle()
        }
    }
    
    func requestStatusFinished() {
        endDownloadContentStyle()
        collectionView.termnatePullToRefresh()
    }
    
}

//MARK: - Diffable
private extension PowerViewController {
    
    func createDiffableDataSource() {
        diffableDataSource = diffable(
            collectionView: collectionView,
            registeredCells: viewModel.registeredCellsModel,
            cellProvider: { collectionView, indexPath, models in
                let model = (models as! PowerCells)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type(of: model).cellId, for: indexPath)
                cell.semanticContentAttribute = .forceRightToLeft
                model.configure(cell: cell)
                return cell
            })
    }
    
    func createDiffableSections() {
        diffableDataSource?.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let self = self else { return UICollectionReusableView() }
            let x = self.supplementaryView.build(
                settings: self.viewModel.powerItemsModel, status: self.viewModel.network.status, kind: kind,
                collectionView: collectionView, indexPath: indexPath, action: self.viewModel.action
            )
            return x
        } // End Of supplementaryViewProvider
    }
    
}

//MARK: - Snapshot
private extension PowerViewController {
    
    
    func setupSnapshot(isSettings: Bool) {
        if viewModel.isStaticList {
            setupSnapshots(isSettings: isSettings)
        } else {
            guard PowerNetworkReachability.shared.isReachable == true else { return }
            setupSnapshots(isSettings: isSettings)
        }
        
    }
    
    
    func setupSnapshots(isSettings: Bool) {
        var snapshot = snapshots()
        snapshot.appendSections(self.viewModel.powerItemsModel.map({ $0.section.id }))
        createNewDiffableItemsUing(snapshot: &snapshot, issettings: isSettings)
        stopSkeleton(isSettings)
        diffableDataSource?.apply(snapshot, animatingDifferences: powerSettings.animatingDifferences) { [weak self] in
            guard let self = self else { return }
            guard self.viewModel.isFetchMoreData == false else { return }
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func createNewDiffableItemsUing(snapshot: inout snapshots, issettings: Bool) {
        guard issettings == false else { return }
        guard collectionView.mode != .error else { return }
        let itemCount = viewModel.powerItemsModel.filter { $0.items.isEmpty }.count
        let isItemEmpty = viewModel.powerItemsModel.count == itemCount
        viewModel.setItems(isEmpty: isItemEmpty)
        viewModel.powerItemsModel.forEach {
            appendNewItems($0, isEmpty: isItemEmpty, snap: &snapshot)
        }
    }
    
    func appendNewItems(_ model: PowerItemModel, isEmpty: Bool, snap: inout snapshots) {
        switch isEmpty {
        case true:
            snapshotForEmptyItems(model: model, snapshot: &snap)
        case false:
            snapshotForNotEmptyItems(model: model, snapshot: &snap)
        }
        
        snap.appendItems(model.items, toSection: model.section.id)
    }
    
    
    func snapshotForNotEmptyItems(model: PowerItemModel, snapshot: inout snapshots) {
        collectionView.setBackground(mode: .without)
        guard model.items.isEmpty else { return }
        guard let emptyCell = model.emptyCell else { return }
        snapshot.appendItems([emptyCell], toSection: model.section.id)
    }
    
    
    func snapshotForEmptyItems(model: PowerItemModel, snapshot: inout snapshots) {
        switch self.powerSettings.keepSectionVisibaleForEmptyPowerItem == true {
        case false:
            collectionView.setBackground(mode: .empty)
        case true:
            guard let emptyCell = model.emptyCell else { return }
            snapshot.appendItems([emptyCell], toSection: model.section.id)
        } // End inner switch
        
    }
    
    
    func reloadSections() {
        viewModel.$sectionChangedIdentifier
            .compactMap { $0 }
            .sink { [weak self] in
                guard let self = self else { return }
                guard var snapshot = self.diffableDataSource?.snapshot() else { return }
                snapshot.reloadSections([$0])
                let animation = self.powerSettings.animatingDifferencesForReloadSection
                self.stopSkeleton(false)
                self.diffableDataSource?.apply(snapshot, animatingDifferences: animation)
            }.store(in: &viewModel.subscription)
    }
    
    func observeItemExpanding() {
        viewModel.$isItemExpanding
            .compactMap { $0 }
            .sink { [weak self] (value: Bool, section: Int) in
                guard let self = self else { return }
                guard var snapshot = self.diffableDataSource?.snapshot() else { return }
                let item = snapshot.itemIdentifiers(inSection: section)
                if self.itemInSection.isEmpty == true { self.itemInSection = item }
                value == true ? snapshot.deleteItems(item) : snapshot.appendItems(self.itemInSection)
                self.diffableDataSource?.apply(snapshot, animatingDifferences: true)
            }.store(in: &viewModel.subscription)
        
    }
    
}

//MARK: - Helper
extension PowerViewController {
    
    func stopSkeleton(_ isSettings: Bool) {
        guard viewModel.network.status == .finished && isSettings == false else { return }
        self.collectionView.stopSkeleton()
    }
    
    public func reloadRequest() {
        switch PowerNetworkReachability.shared.isReachable {
        case true:
            self.collectionView.setBackground(mode: .loading)
            self.viewModel.makeHTTPRequest()
        case false:
            let model = self.viewModel.network.networkErrorModel
            let arTitle = "لا يوجد اتصال بالإنترنت"
            let arMessage = "يبدو انه لايوجد إتصال بالإنترنت تاكد من اتصالك من خلال الشبكة الخلوية او شبكة WI-FI"
            let title = model == nil ? arTitle : model!.description
            let message = model == nil ? arMessage : model!.message
            self.onInternetErrorEventFire(title: title, message: message)
            self.collectionView.termnatePullToRefresh()
        }
    }
    
    
    private func configureErrorModel(_ model: PowerNetworkErrorLoadingModel) {
        let isEmpty = viewModel.isEmptyDataEventFire ?? true
        guard isEmpty == true else { return }
        self.collectionView.setBackground(mode: .error)
        collectionView.emptyView.configure(
            viewType: .network, layoutPosition: .middle,
            title: model.description, message: model.message,
            actionButtonTitle: "إعادة تحميل الصفحة"
        )
        
    }
    
    private func setupPullToRefresh() {
        guard powerSettings.isPullToRefreshUsed else { return }
        collectionView.pullToRefreh { [ weak self] in
            guard let self else { return }
            self.isRequestReloadingFromPullToRefresh = true
            DispatchQueue.main.async { self.reloadRequest() }
        }
        
    }
    
    private func eventForCustomCell() {
        NotificationCenter.default.publisher(for: PowerCellsAction.notificationName)
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] in
                guard let self = self else { return }
                guard let eventData = $0.userInfo!["data"] as? PowerCellActionModel else { return }
                guard let cell = eventData.cell as? UICollectionViewCell else { return }
                guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
                guard let model = self.diffableDataSource?.itemIdentifier(for: indexPath) else { return }
                self.viewModel.action.invoke(
                    action: eventData.action,
                    cell: cell,
                    configurator: model as! PowerCells,
                    indexPath: indexPath
                )
            }.store(in: &viewModel.subscription)
    }
    
    private func didSelect(indexPath: IndexPath) {
        guard let model = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        self.viewModel.action.invoke(action: .didSelect, cell: cell, configurator: model as! PowerCells, indexPath: indexPath)
    }
    
    private func didDeSelect(indexPath: IndexPath) {
        guard let model = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        self.viewModel.action.invoke(action: .didDeSelect, cell: cell, configurator: model as! PowerCells, indexPath: indexPath)
    }
    
}

//MARK: - DownloadContentStyle
private extension PowerViewController {
    
    func setDwonloadContentStyle() {
        collectionView.setBackground(mode: .loading)
        collectionView.startSkeleton()
    }
    
    func endDownloadContentStyle() {
        collectionView.stopSkeleton()
    }
    
}
