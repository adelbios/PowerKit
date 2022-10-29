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
    
    private var diffableDataSource: diffable?
    
    //MARK: - UI Variables
    open lazy var collectionView: PowerCollectionView = {
        let collectionView = PowerCollectionView(frame: .zero, collectionViewLayout: viewModel.createCollectionViewLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.prefetchDataSource = self
        return collectionView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        return view
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
        setupActivityIndicatorUI()
    }
    
    //MARK: - Override func
    open func settingConfigure() {
    }
    
    open func showAlertForInternetConnectionError(title: String, message: String) {
        
    }
    
    //MARK: - Collection View Protocol
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        fetchNextPage(indexPaths)
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
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
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
        self.view.isSkeletonable = true
        self.collectionView.isSkeletonable = true
        PowerNetworkReachability.shared.startListening()
        viewModel.viewController = self
        viewModel.collectionView = self.collectionView
    }
    
    func setupActivityIndicatorUI() {
        guard powerSettings.loadContentType == .normal else { return }
        collectionView.backgroundView = activityIndicator
    }
    
}


//MARK: - Request Status
private extension PowerViewController {
    
    func requestStatusLoading() {
        guard PowerNetworkReachability.shared.isReachable == true else { return }
        collectionView.setBackground(mode: .loading)
        switch self.viewModel.isPowerItemsModelEmpty {
        case true:
            self.setDwonloadContentStyle()
        case false:
            guard self.powerSettings.showSkeletonWhenPowerItemIsNotEmpty == true else { return }
            self.setDwonloadContentStyle()
        }
        
    }
    
    func requestStatusFinished() {
        endDownloadContentStyle()
        collectionView.termnatePullToRefresh()
        collectionView.setBackground(mode: .without)
    }
    
}

//MARK: - Diffable
private extension PowerViewController {
    
    func createDiffableDataSource() {
        diffableDataSource = diffable(
            collectionView: collectionView, registeredCells: viewModel.registeredCellsModel,
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
            var powerCell: PowerCells?
            let model = self.viewModel.powerItemsModel[indexPath.section]
            
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                powerCell = model.itemSection?.cell
                
            case UICollectionView.elementKindSectionFooter:
                powerCell = model.loadMoreSection?.cell
            default:
                break
            }
            
            guard let powerCell else { return UICollectionReusableView() }
            let cell = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: type(of: powerCell).cellId,
                for: indexPath
            )
            
            
            cell.semanticContentAttribute = .forceRightToLeft
            powerCell.configure(cell: cell)
            self.viewModel.action.invoke(action: .headerVisible, cell: cell, configurator: powerCell, indexPath: indexPath)
            
            return cell
        }
    }
    
    func updateDiffableDataSourceForLoadingMode() {
        guard PowerNetworkReachability.shared.isReachable == true else { return }
        var snapshot = snapshots()
        snapshot.appendSections(self.viewModel.powerItemsModel.map({ $0.section }))
        self.viewModel.powerItemsModel.forEach { snapshot.appendItems($0.item, toSection: $0.section) }
        self.diffableDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func updateDiffableDataSource() {
        var snapshot = snapshots()
        snapshot.appendSections(self.viewModel.powerItemsModel.map({ $0.section }))
        self.reloadSections(snapshot: &snapshot)
        self.appendItemUsing(snapshot: &snapshot)
        self.collectionView.stopSkeleton()
        self.diffableDataSource?.apply(
            snapshot,
            animatingDifferences: viewModel.sectionChangedIdentifier != nil ? false : powerSettings.animatingDifferences
        )
    }
    
    func appendItemUsing(snapshot: inout snapshots) {
        viewModel.powerItemsModel.forEach { model in
            switch model.isItemVisible {
            case true:
                appendForVisibleItem(model, snapshot: &snapshot)
            case false:
                snapshot.deleteItems(model.item)
            }
        }
    }
    
    func appendForVisibleItem(_ item: PowerItemModel, snapshot: inout snapshots) {
        let isEmptyUsed = item.item.isEmpty && item.emptyCell != nil
        switch isEmptyUsed {
        case true:
            if powerSettings.keepSectionVisibaleForEmptyPowerItem == false {
                self.collectionView.setBackground(mode: .empty)
                item.layout.boundarySupplementaryItems = []
            } else {
                snapshot.appendItems([item.emptyCell!], toSection: item.section)
            }
            
        case false:
            self.collectionView.setBackground(mode: .without)
            item.layout.boundarySupplementaryItems = item.boundarySupplementaryItem
            snapshot.appendItems(item.item, toSection: item.section)
        }
        
    }
    
    func reloadSections(snapshot: inout snapshots) {
        guard let sec = viewModel.sectionChangedIdentifier else { return }
        snapshot.reloadSections([sec])
        viewModel.sectionChangedIdentifier = nil
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
                self.updateDiffableDataSource()
            }.store(in: &viewModel.subscription)
    }
    
    func reloadSettingsModel() {
        viewModel.$isAddSettingsEventFire
            .compactMap { $0 }
            .filter { $0 == true }
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateDiffableDataSourceForLoadingMode()
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
                self.reloadRequest()
            }.store(in: &viewModel.subscription)
    }
    
}


//MARK: - Helper
private extension PowerViewController {
    
    
    func configureErrorModel(_ model: PowerNetworkErrorLoadingModel) {
        guard viewModel.isPowerItemsModelEmpty == true else { return }
        powerSettings.keepSectionVisibaleForEmptyPowerItem = false
        collectionView.setBackground(mode: .error)
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
            DispatchQueue.main.async { self.reloadRequest() }
        }
        
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
            self.showAlertForInternetConnectionError(title: title, message: message)
            self.collectionView.termnatePullToRefresh()
        }
    }
    
    func fetchNextPage(_ indexPaths: [IndexPath]) {
        guard viewModel.powerItemsModel.isEmpty == false else { return }
        indexPaths.forEach { indexPath in
            let model = self.viewModel.powerItemsModel[indexPath.section]
            guard model.item.isEmpty == false else { return }
            guard model.item.count - 1 == indexPath.item else { return }
            guard let loadMore = model.loadMoreSection?.item else { return }
            guard loadMore.currentPage < loadMore.lastPage else { return }
            viewModel.fetchNextPaging()
        }
    }
    
    func eventForCustomCell() {
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
    
    func didSelect(indexPath: IndexPath) {
        guard let model = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        self.viewModel.action.invoke(action: .didSelect, cell: cell, configurator: model as! PowerCells, indexPath: indexPath)
    }
    
    func didDeSelect(indexPath: IndexPath) {
        guard let model = diffableDataSource?.itemIdentifier(for: indexPath) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        self.viewModel.action.invoke(action: .didDeSelect, cell: cell, configurator: model as! PowerCells, indexPath: indexPath)
    }
    
    
}

//MARK: - DownloadContentStyle
private extension PowerViewController {
    
    func setDwonloadContentStyle() {
        switch powerSettings.loadContentType {
        case .skeleton:
            collectionView.startSkeleton()
        case .normal:
            activityIndicator.startAnimating()
        case .custom(view: let downloadView):
            downloadView.startAnimation()
            collectionView.backgroundView = downloadView
        }
    }
    
    func endDownloadContentStyle() {
        switch powerSettings.loadContentType {
        case .skeleton:
            collectionView.stopSkeleton()
        case .normal:
            activityIndicator.stopAnimating()
        case .custom(view: let downloadView):
            downloadView.stopAnimation()
            collectionView.backgroundView = nil
        }
    }
    
    
}
