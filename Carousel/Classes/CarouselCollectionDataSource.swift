//
//  CarouselItemDataSource.swift
//
//  Created by Bogdan Manshilin on 7/15/16.
//

import Foundation

public typealias ImageLoadHandler = (URL, @escaping (UIImage)->Void) -> Void

//DataSource для элемента коллекции
public protocol CarouselItemDataSource {
    init(pack: CarouselItemProtocol)
}

//DataSource для ячейки карусели
open class CarouselCellDataSource {
    var imageUrl: String?
    /**
     * Замыкание, которое скачивает картинки
     **/
    var imageLoader: ImageLoadHandler?
    var itemTitle: String?
}

extension CarouselCellDataSource {
    func setImage(forImageView imageView: UIImageView) {
        switch (URL(string: imageUrl ?? ""), imageLoader) {
        case (let url?, let loader?):
            loader(url) { [weak self] image in
                guard let _ = self else { return }
                imageView.image = image
            }
        default: break
        }
    }
}

//DataSource для карусели
public protocol CarouselDataSource {
    var itemsCount: Int { get }
    func item(at index: Int) -> CarouselItemProtocol
    /**
     * Замыкание, которое скачивает картинки
     **/
    var imageLoader: ImageLoadHandler? { set get }
    /**
     * Конкретная реализация ответственна за вызов этого хэндлера после обновления коллекций
     **/
    var itemsDidUpdateHandler: (()->Void)? { set get }
    var isUpdatingNow: Bool { get }
    mutating func update()
}

extension CarouselDataSource {
    public func viewModelForCellAtIndexPath(_ path: IndexPath) -> CarouselCellDataSource {
        let cellDataSource = CarouselCellDataSource()
        cellDataSource.itemTitle = item(at: path.item).collectionTitle
        cellDataSource.imageUrl = item(at: path.item).imageUrl
        cellDataSource.imageLoader = imageLoader
        return cellDataSource
    }
    
    public func viewModelForCollectionAtIndex<T:CarouselItemDataSource>(_ index: Int) -> T {
        let collection = item(at: index)
        return T(pack: collection)
    }
}
