//
//  ExampleCarouselLayoutDelegate.swift
//
//  Created by Bogdan Manshilin on 7/15/16.
//

import Foundation
import Carousel

class ExampleCarouselLayoutDelegate: CarouselLayoutDelegate {
    open func itemSize(atIndexPath indexPath: IndexPath, inCollectionView collectionView: UICollectionView, forLayout layout: UICollectionViewLayout) -> CGSize {
        let height = collectionView.bounds.size.height * relativeHeightForCell
        let width = height * 2
        return CGSize(width: width, height: height)
    }
    
    func interItemSpace(forCollectionViewSize size:CGSize) -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? size.height * (1 - relativeHeightForCell)/2 : CGFloat(20)
    }
    
    var relativeHeightForCell: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 0.84 : 1
    }
    
    func didSelect(collection: CarouselItemProtocol) {
        
    }

}
