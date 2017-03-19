//
//  CarouselLayout.swift
//
//  Created by Bogdan Manshilin on 6/14/16.
//
//

import Foundation

@objc
public protocol CarouselLayoutDelegate: class {
    func interItemSpace(forCollectionViewSize size:CGSize) -> CGFloat
    func itemSize(atIndexPath indexPath: IndexPath, inCollectionView collectionView: UICollectionView, forLayout layout: UICollectionViewLayout) -> CGSize
    func didSelect(collection: CarouselItemProtocol)
}

open class CarouselLayout: UICollectionViewFlowLayout {
    //MARK: - Detectiong Changes Properties
    weak var delegate: CarouselLayoutDelegate?
    var indexPathsToAnimate: [IndexPath]?
    
    var getIndexPathInCenter: (()->IndexPath?)?
    var setIndexPathInCenter: ((IndexPath)->Void)?
    var indexPathNearestToPoint: ((CGPoint)->IndexPath?)?
    
    var transitioningTargetItemSize: CGSize = CGSize.zero
    var transitioningOriginItemSize: CGSize = CGSize.zero
}

//MARK: - Detectiong Changes Methods
extension CarouselLayout {
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let path = getIndexPathInCenter?(),
            let offset = contentOffset(forCellWithFrame: finalFrameForCell(atIndexPath: path)) else {
                return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }

        //MARK: - Проверить в UGT HD будет ли работать.
        return offset
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let attributes = collectionView!.layoutAttributesForItem(at: getIndexPathInCenter!()!)
        let cellRect = attributes!.frame
        let targetX = cellRect.origin.x + cellRect.size.width / 2 - collectionView!.frame.size.width / 2
        return CGPoint(x: targetX, y: 0)
    }
    
    func contentOffset(forCellWithFrame frame: CGRect) -> CGPoint? {
        if let cv = collectionView
        {
            return CGPoint(x: frame.origin.x + (frame.size.width - cv.frame.size.width)/2, y: 0)
        } else {
            return nil
        }
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return !collectionView!.bounds.size.equalTo(newBounds.size)
    }
    
    override open func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = layoutAttributesForItem(at: itemIndexPath)
        
        attr?.frame = initialFrameForCell(atIndexPath: itemIndexPath)
        
        //Т. к. ячейки появляются уже после начала анимации и в новом размере, то они не совпадают идеально с исчезающими
        //Чтобы скрыть кривой переход - уменьшаем и скрываем ячейки вначале
        attr?.alpha = 0
        attr?.transform = CGAffineTransform(scaleX: 0.0000001, y: 0.0000001)
        attr?.zIndex = -1
        
        return attr
    }
    
    override open func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = layoutAttributesForItem(at: itemIndexPath)
        
        attr?.frame = finalFrameForCell(atIndexPath: itemIndexPath)
        attr?.zIndex = Int.max
        
        return attr
    }
    
    func finalFrameForCell(atIndexPath path: IndexPath) -> CGRect {
        return frameForCell(atIndexPath: path, forContainerSize: transitioningTargetItemSize)
    }
    
    func initialFrameForCell(atIndexPath path: IndexPath) -> CGRect {
        return frameForCell(atIndexPath: path, forContainerSize: transitioningOriginItemSize)
    }
    
    func frameForCell(atIndexPath path: IndexPath, forContainerSize containerSize: CGSize) -> CGRect {
        let size = Carousel.itemSize(forContainerSize: containerSize)
        return CGRect(x: CGFloat((path as NSIndexPath).item) * (size.width + ((delegate?.interItemSpace(forCollectionViewSize: containerSize)) ?? 0)),
                      y: containerSize.height * ((1 - (Carousel.relativeHeightForCell )) / 2),
                      width: size.width,
                      height: size.height)
    }
    
    override open func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        var indexPaths = [IndexPath]()
        for updateItem in updateItems {
            switch updateItem.updateAction {
            case .insert:
                _ = updateItem.indexPathAfterUpdate.map { indexPaths.append($0) }
            case .delete:
                _ = updateItem.indexPathBeforeUpdate.map { indexPaths.append($0) }
            case .move:
                _ = updateItem.indexPathBeforeUpdate.map { indexPaths.append($0) }
                _ = updateItem.indexPathAfterUpdate.map { indexPaths.append($0) }
            default:
                break
            }
        }
        indexPathsToAnimate = indexPaths
    }
}
