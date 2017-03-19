//
//  Carousel.swift
//
//  Created by Bogdan Manshilin on 14.04.16.
//
//

import UIKit

//NSTimer создает сильную ссылку на свой таргет. Поэтому Карусель сама по себе таргетом таймера быть не может.
//Создаем прослойку в виде этой хуеты, чтобы никто не держал Карусель по сильной ссылке
private class CarouselScroller {
    weak var carousel: Carousel?
    
    @objc func scrollToNext(timer: Timer) {
        if let target = carousel {
            target.scrollToNext(timer)
        } else {
            timer.invalidate()
        }
    }
}

@objc open class Carousel: UICollectionViewController {
    
    //MARK: - Instance types
    
    enum CollectionConstants {
        static let cellReuseIdentifier = "CarouselCell"
        static let cellWidth: CGFloat = 350
        static let cellHeight: CGFloat = 250
    }
    
    //MARK: - Properties
    
    open var dataSource: CarouselDataSource! = nil {
        didSet {
            dataSource.itemsDidUpdateHandler = { [weak self] in
                if self?.dataSource?.itemsCount ?? 0 > 0 {
                    self?.collectionView?.reloadData()
                    _ = self?.currentIndexPathInCenter.map {
                        self?.collectionView!.scrollToItem(at: $0, at: .centeredHorizontally, animated: false)
                    }
                    self?.hideLoadingAnimation()
                    self?.createNewTimer()
                }
            }
        }
    }
    
    open weak var delegate: CarouselLayoutDelegate?
    open var shouldShowDescriptions = true
    open var placeholderColor: UIColor?
    
    var newBounds: CGRect?
    var carouselLayout: CarouselLayout? {
        return collectionView?.collectionViewLayout as? CarouselLayout
    }
    
    /*
     * Сколько должно быть дубликатов ячеек
     * При количестве 30 и более, анимация поворота ориентации разъёбывается пропорционально величине этой цифры
     */
    fileprivate var elementsToDuplicate = 20
    fileprivate var currentIP: IndexPath?
    open var currentIndexPathInCenter: IndexPath? {
        get {
            if currentIP == nil {
                currentIP = self.actualItemsCount > 0 ? IndexPath(item: self.elementsToDuplicate, section: 0) : .none
            }
            return currentIP
        }
        
        set {
            currentIP = newValue
        }
    }
    fileprivate var actualItemsCount: Int {
        let count = dataSource.itemsCount
        if count <= 0 {
            return 0
        }
        
        return count + elementsToDuplicate * 2
    }
    
    fileprivate weak var autroscrollTimer: Timer?
    open var collectionAnalyticsPlugin: CarouselAnalyticsManager?
    
    //MARK: - Initializers
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
        if let layout = layout as? CarouselLayout {
            layout.delegate = delegate
            layout.getIndexPathInCenter = { [weak self] in
                return self?.currentIndexPathInCenter
            }
            layout.setIndexPathInCenter = { [weak self] newPath in
                self?.currentIndexPathInCenter = newPath as IndexPath
            }
        }
    }
    
    //MARK: - Lifecycle
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView?.reloadData()
        collectionView?.backgroundColor = UIColor.clear
    }
    
    override open func viewDidLoad() {
        collectionView!.register(
            UINib(nibName: "CarouselCell", bundle: Bundle(for: Carousel.self)),
            forCellWithReuseIdentifier: CollectionConstants.cellReuseIdentifier
        )
        
        showLoadingAnimation()
        
        if let layout = self.collectionViewLayout as? CarouselLayout {
            layout.scrollDirection = .horizontal
            layout.delegate = self.delegate
            layout.getIndexPathInCenter = { [weak self] in
                return self?.currentIndexPathInCenter
            }
            layout.setIndexPathInCenter = { [weak self] newPath in
                self?.currentIndexPathInCenter = newPath as IndexPath
            }
            layout.indexPathNearestToPoint = { [weak self] in self?.indexPath(nearestToPoint: $0) }
        }
        
        super.viewDidLoad()
        
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let p = currentIndexPathInCenter {
            hideLoadingAnimation()
            collectionView?.scrollToItem(at: p, at: .centeredHorizontally, animated: false)
            collectionAnalyticsPlugin?.onShowItems()
        }
    }
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    func showLoadingAnimation() {
        collectionView?.alpha = 0
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint(item: activityIndicator,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .centerX,
                           multiplier: 1,
                           constant: 0
            ).isActive = true
        
        NSLayoutConstraint(item: activityIndicator,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .centerY,
                           multiplier: 1,
                           constant: 0
            ).isActive = true
        
        activityIndicator.startAnimating()
    }
    
    func hideLoadingAnimation() {
        guard dataSource.isUpdatingNow == false else { return }
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.collectionView?.alpha = 1
        }
    }
    
    deinit {
        autroscrollTimer?.invalidate()
    }
    
    //MARK: - Transitions
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        autroscrollTimer?.invalidate()
        
        carouselLayout?.transitioningOriginItemSize = view.bounds.size
        carouselLayout?.transitioningTargetItemSize = size
        super.viewWillTransition(to: size,
                                 with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.collectionView?.performBatchUpdates({ _ in self?.collectionView?.setCollectionViewLayout(self!.collectionView!.collectionViewLayout, animated: true)}) { _ in }
            }, completion: { [weak self] _ in
                //            _ = self?.currentIndexPathInCenter.map { self?.collectionView?.scrollToItemAtIndexPath($0, atScrollPosition: .CenteredHorizontally, animated: false) }
                self?.createNewTimer()
        })
    }
    
    open func indexPath(nearestToPoint point: CGPoint) -> IndexPath? {
        let horizontalCenterOfScrollView = collectionView!.frame.origin.x + collectionView!.frame.size.width / 2
        let actualcenterInContent = point.x + horizontalCenterOfScrollView
        if let selfFrame = view.window?.subviews.first?.convert(view.frame, from: view) {
            
            if let centerIndexPath = collectionView!.indexPathForItem(at: CGPoint(x: actualcenterInContent, y: selfFrame.origin.y+selfFrame.height/2)) ?? collectionView!.indexPathForItem(at: CGPoint(x: actualcenterInContent + 10, y: selfFrame.origin.y+1)) {
                return centerIndexPath
            }
        }
        return nil
    }
    
    //MARK: - duplicated items
    
    open func calculateIndexPathWithOffset(_ indexPath: IndexPath) -> IndexPath {
        var originalItem = 0
        
        if (indexPath as NSIndexPath).item < elementsToDuplicate { //Левые дубликаты
            originalItem = (dataSource.itemsCount - 1) - (elementsToDuplicate - 1 - (indexPath as NSIndexPath).item) % dataSource.itemsCount
        } else if (indexPath as NSIndexPath).item >= actualItemsCount - elementsToDuplicate { //Правые дубликаты
            originalItem = ((indexPath as NSIndexPath).item - (actualItemsCount - elementsToDuplicate)) % dataSource.itemsCount
        } else { //Оригинальные ячейки
            originalItem = (indexPath as NSIndexPath).item - elementsToDuplicate
        }
        
        return IndexPath(item: originalItem, section: 0)
    }
    
    //MARK: - Autroscroll
    
    private lazy var autoScroller = CarouselScroller()
    
    func createNewTimer() {
        autroscrollTimer?.invalidate()
        autroscrollTimer = nil
        autoScroller.carousel = self
        if dataSource?.itemsCount ?? 0 > 0 {
            autroscrollTimer = Timer.scheduledTimer(timeInterval: 5,
                                                    target: autoScroller,
                                                    selector: #selector(CarouselScroller.scrollToNext(timer:)),
                                                    userInfo: nil,
                                                    repeats: true)
        }
    }
    
    func scrollToNext(_ timer: Timer) {
        DispatchQueue.main.async { [weak self] in
            guard let _ = self?.currentIndexPathInCenter else { return }
            self?.currentIndexPathInCenter = IndexPath(item: (self!.currentIndexPathInCenter! as NSIndexPath).item + 1, section: 0)
            self?.collectionView?.scrollToItem(at: self!.currentIndexPathInCenter!, at: .centeredHorizontally, animated: true)
        }
    }
    
    //MARK: - Static layout methods
    class func itemSize(forContainerSize size: CGSize) -> CGSize {
        let height = size.height * relativeHeightForCell
        let width = height * 2
        return CGSize(width: width, height: height)
    }
    
    class var relativeHeightForCell: CGFloat {
        return UIDevice().userInterfaceIdiom == .pad ? 0.84 : 1
    }
}

//MARK: - Collection Data Source

extension Carousel {
    public func update() {
        dataSource.update()
    }
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = actualItemsCount
        return count
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionConstants.cellReuseIdentifier, for: indexPath) as? CarouselCell
        
        let indexPathForViewModel = calculateIndexPathWithOffset(indexPath)
        cell?.shouldShowBlur = shouldShowDescriptions
        cell?.placeholderColor = placeholderColor
        cell?.dataSource = dataSource.viewModelForCellAtIndexPath(indexPathForViewModel)
        cell?.configure()
        return cell!
    }
}

//MARK: - Collection delegate

extension Carousel {
    override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collection = dataSource.item(at: calculateIndexPathWithOffset(indexPath).item)
        collectionAnalyticsPlugin?.onOpen(item: collection)
        delegate?.didSelect(collection: collection)
    }
    
    override open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        autroscrollTimer?.invalidate()
    }
    
    
    override open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if autroscrollTimer == nil {
            createNewTimer()
        }
        
        //Если пользователь будкт скролить без остановки, то он может дойти до конца коллекции и подумать, что она не бесконечная
        //Поэтому если конец близок, делаем передышку
        if collectionView!.contentOffset.x + view.bounds.width * 3 > collectionView!.contentSize.width {
            collectionView!.isUserInteractionEnabled = false
        }
        
    }
    
    override open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        swapCellsIfNeeded()
        collectionView!.isUserInteractionEnabled = true
    }
    
    open override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        swapCellsIfNeeded()
        collectionView!.isUserInteractionEnabled = true
    }
    
    func swapCellsIfNeeded() {
        guard let currentIndexPathInCenter = currentIndexPathInCenter else { return }
        if (currentIndexPathInCenter as NSIndexPath).item < elementsToDuplicate {
            let originalItem = elementsToDuplicate + (dataSource.itemsCount - 1) - (elementsToDuplicate - 1 - (currentIndexPathInCenter as NSIndexPath).item) % dataSource.itemsCount
            self.currentIndexPathInCenter = IndexPath(item: originalItem, section: 0)
            collectionView!.scrollToItem(at: self.currentIndexPathInCenter!, at: .centeredHorizontally, animated: false)
        } else if (currentIndexPathInCenter as NSIndexPath).item >= actualItemsCount - elementsToDuplicate {
            let originalItem = elementsToDuplicate + ((currentIndexPathInCenter as NSIndexPath).item - (actualItemsCount - elementsToDuplicate)) % dataSource.itemsCount
            self.currentIndexPathInCenter = IndexPath(item: originalItem, section: 0)
            collectionView!.scrollToItem(at: self.currentIndexPathInCenter!, at: .centeredHorizontally, animated: false)
        }
    }
}

extension Carousel: UICollectionViewDelegateFlowLayout {
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let delegate = delegate else { return CGSize.zero }
        return delegate.itemSize(atIndexPath: indexPath, inCollectionView: collectionView, forLayout: collectionViewLayout)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1000
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return delegate!.interItemSpace(forCollectionViewSize: collectionView.bounds.size)
    }
}
