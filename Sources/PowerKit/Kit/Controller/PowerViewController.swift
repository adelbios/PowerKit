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


open class PowerViewController<U: Any, Z: PowerViewModel<U>>: UIViewController, UICollectionViewDelegate {
    
    //MARK: - Public Variables
    open var powerSettings = PowerSettings()
    open var viewModel = Z()
    
    //MARK: - Private Variables
    private var diffableDataSource: diffable?
    private var supplementaryView = PowerHeaderFooterDiffableView()
    private var isDataSourceEmpty: Bool = true
    private var isRequestReloadingFromPullToRefresh = false
    
    //MARK: - UI Variables
    open lazy var collectionView: PowerCollectionView = {
        let collectionView = PowerCollectionView(frame: .zero, collectionViewLayout: viewModel.createCollectionViewLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    //MARK: - LifeCycle
    open override func viewDidLoad() {
        settingConfigure()
        super.viewDidLoad()
        settings()
        createDiffableDataSource()
        createDiffableSections()
        observeRequestStatus()
        observeNetworkError()
        observeEmptyViewActionButtonClicked()
        eventForCustomCell()
        setupPullToRefresh()
    }
    
    //MARK: - Override func
    open func settingConfigure() { }
    
    open func onInternetErrorEventFire(title: String, message: String) { }
    
    //MARK: - Collection View Protocol
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelect(indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didDeSelect(indexPath: indexPath)
    }
    
    //MARK: - ScrollView
    open func scrollViewDidScroll(_ scrollView: UIScrollView) { }
    
    open func scrollViewDidFinished(_ scrollView: UIScrollView) {
        loadMore(scrollView: scrollView)
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
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }
    
    /// Change color for both self.view & self.collectionView
    /// - Parameter color: New Color
    open func setBackground(color: UIColor) {
        self.collectionView.backgroundColor = color
        self.view.backgroundColor = color
    }
    
    /// To Fill Collection View to subView
    /// - Parameter padding: To add margin to constraint
    open func setupCollectionViewConstraint(padding: UIEdgeInsets = .zero) {
        setupConstraint(padding: padding)
    }
    
    open func setErroView(title: String, msg: String) {
        guard isDataSourceEmpty == true else { return }
        collectionView.setBackground(mode: .error)
        guard var snapshot = self.diffableDataSource?.snapshot() else { return }
        snapshot.deleteAllItems()
        apply(snapshot: snapshot, animated: false)
        collectionView.emptyView.configure(
            viewType: .network,
            layoutPosition: .middle,
            title: title,
            message: msg,
            actionButtonTitle: "إعادة تحميل الصفحة"
        )
        
    }
    
}

//MARK: - Settings
private extension PowerViewController {
    
    func settings() {
        view.isSkeletonable = true
        collectionView.isSkeletonable = true
        viewModel.set(viewController: self, collectionView: collectionView)
        viewModel.dataViewModel.delegate = self
        PowerNetworkReachability.shared.startListening()
    }
    
    func setupConstraint(padding: UIEdgeInsets = .zero) {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(padding.top)
            $0.leading.equalToSuperview().inset(padding.left)
            $0.bottom.equalToSuperview().inset(padding.bottom)
            $0.trailing.equalToSuperview().inset(padding.right)
        }
    }
    
    func loadMore(scrollView: UIScrollView) {
        let location = scrollView.panGestureRecognizer.location(in: collectionView)
        guard let section = collectionView.indexPathForItem(at: location)?.section else { return }
        let model = viewModel.powerItemsModel[section]
        guard let pagination = model.section.pagination, pagination.isRequestMoreFire == true else { return }
        guard collectionView.isLastItemVisible(section: section) == true else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchNextPaging(section: section)
            self.viewModel.fetchNextPaging()
        }
    }
    
}

//MARK: - Events
private extension PowerViewController {
    
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
        collectionView.emptyView.didReloadButtonClicked = { [weak self] in
            guard let self = self else { return }
            self.isRequestReloadingFromPullToRefresh = false
            self.reloadRequest()
        }
    }
    
}


//MARK: - Request Status
private extension PowerViewController {
    
    func requestStatusLoading() {
        guard PowerNetworkReachability.shared.isReachable == true else { return }
        guard isRequestReloadingFromPullToRefresh == false else { return }
        switch self.isDataSourceEmpty {
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
    
    func reloadRequest() {
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
            return self.supplementaryView.build(
                settings: self.viewModel.powerItemsModel, status: self.viewModel.network.status, kind: kind,
                collectionView: collectionView, indexPath: indexPath, action: self.viewModel.action
            )
        } // End Of supplementaryViewProvider
    }
    
}


//MARK: - Helper
extension PowerViewController {
    
    func stopSkeleton(_ isSettings: Bool) {
        guard viewModel.network.status == .finished && isSettings == false else { return }
        self.collectionView.stopSkeleton()
    }
    
    private func configureErrorModel(_ model: PowerNetworkErrorLoadingModel) {
        guard isDataSourceEmpty == true else { return }
        collectionView.setBackground(mode: .error)
        guard var snapshot = self.diffableDataSource?.snapshot() else { return }
        snapshot.deleteAllItems()
        apply(snapshot: snapshot, animated: false)
        
        collectionView.emptyView.configure(
            viewType: .network, layoutPosition: .middle, title: model.description, message: model.message,
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
extension PowerViewController {
    
    public func setDwonloadContentStyle() {
        collectionView.setBackground(mode: .loading)
        collectionView.startSkeleton()
    }
    
    public func endDownloadContentStyle() {
        collectionView.stopSkeleton()
    }
    
}

//MARK: - PowerDataViewModelDelegate
extension PowerViewController: PowerDataViewModelDelegate {
    
    func didCreateSettings() {
        var snapshot = snapshots()
        snapshot.appendSections(self.viewModel.powerItemsModel.map({ $0.section.id }))
        self.stopSkeleton(true)
        self.diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func didInsertNewItems() {
        var snapshot = snapshots()
        snapshot.appendSections(self.viewModel.powerItemsModel.map({ $0.section.id }))
        
        viewModel.powerItemsModel.forEach {
            switch $0.cells.isEmpty {
            case true:
                guard let empty = $0.emptyCell else { return }
                snapshot.appendItems([empty], toSection: $0.section.id)
            case false:
                snapshot.appendItems($0.cells, toSection: $0.section.id)
            }
        }
        
        let animation = self.viewModel.requestType == .getPagination ? false : true
        self.stopSkeleton(false)
        self.apply(snapshot: snapshot, animated: animation)
    }
    
    func didHeaderUpdated(section: Int) {
        guard var snapshot = self.diffableDataSource?.snapshot() else { return }
        snapshot.reloadSections([section])
        self.apply(snapshot: snapshot, animated: false)
    }
    
    func didUpdateSection(_ section: Int) {
       didHeaderUpdated(section: section)
    }
    
    func didRemoveSection(_ section: Int) {
        guard var snapshot = self.diffableDataSource?.snapshot() else { return }
        snapshot.deleteSections([section])
        self.apply(snapshot: snapshot, animated: true)
    }
    
    func didRemoveItemAt(indexPath: IndexPath) {
        guard var snapshot = self.diffableDataSource?.snapshot() else { return }
        guard let item = self.diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        snapshot.deleteItems([item])
        apply(snapshot: snapshot, animated: true)
    }
    
    func didRemove(cell: PowerCells) {
        guard var snapshot = self.diffableDataSource?.snapshot() else { return }
        snapshot.deleteItems([cell])
        apply(snapshot: snapshot, animated: true)
    }
    
    func isEmpty(_ value: Bool) {
        isDataSourceEmpty = value
        guard value == true else { return }
        let isEmptyCellUsed = viewModel.powerItemsModel.allSatisfy { $0.emptyCell == nil }
        guard isEmptyCellUsed == true else { return }
        guard var snapshot = self.diffableDataSource?.snapshot() else { return }
        snapshot.deleteAllItems()
        apply(snapshot: snapshot, animated: false)
        collectionView.setBackground(mode: .empty)
    }
    
    
    private func apply(snapshot: snapshots, animated: Bool) {
        self.diffableDataSource?.apply(snapshot, animatingDifferences: animated) { [weak self] in
            guard let self = self else { return }
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
}
