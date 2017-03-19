//
//  ExampleDataSource.swift
//  UGCarousel
//
//  Created by BogdanManshilin on 7/15/16.
//

import Foundation
import Carousel

class ExampleDataSource: CarouselDataSource {
    func item(at index: Int) -> CarouselItemProtocol {
        return collections[index]
    }

    var itemsCount: Int {
        return collections.count
    }

    var collectionsArray: [CarouselItemProtocol] {
        return collections
    }
    fileprivate var collections = [CarouselItemProtocol]()
    var itemsDidUpdateHandler: (() -> Void)?
    var isUpdatingNow = false
    var imageLoader: ImageLoadHandler? = { url, success in
        let components = url.pathComponents
        success(UIImage(named: components.last!)!)
    }
    
    func update() {
        fillCollectionsWithDummyData()
        itemsDidUpdateHandler?()
    }
    
    fileprivate func fillCollectionsWithDummyData() {
        collections.append(ExampleItem(collectionTitle: "Independence Day",
            imageUrl: "https://cdn.ustatik.com/storage/songbook/7/784341.png", hitsCount: 0,
            commentsCount: 0,
            likesCount: 0))
        
        collections.append(ExampleItem(collectionTitle: "Songs for beginners with just a few basic chords",
            imageUrl: "https://cdn.ustatik.com/storage/songbook/7/771934.png", hitsCount: 0,
            commentsCount: 0,
            likesCount: 0))
        
        collections.append(ExampleItem(collectionTitle: "Songs to celebrate the end of the academic year",
            imageUrl: "https://cdn.ustatik.com/storage/songbook/7/788863.png", hitsCount: 0,
            commentsCount: 0,
            likesCount: 0))
        
        collections.append(ExampleItem(collectionTitle: "Awaken your inner comic book geek",
            imageUrl: "https://cdn.ustatik.com/storage/songbook/7/742198.png", hitsCount: 0,
            commentsCount: 0,
            likesCount: 0))
        
        collections.append(ExampleItem(collectionTitle: "Party on with these singalong anthems",
            imageUrl: "https://cdn.ustatik.com/storage/songbook/7/742201.png", hitsCount: 0,
            commentsCount: 0,
            likesCount: 0))
        
        collections.append(ExampleItem(collectionTitle: "Spice up your next bachelor party",
            imageUrl: "https://cdn.ustatik.com/storage/songbook/7/788866.png", hitsCount: 0,
            commentsCount: 0,
            likesCount: 0))
        
        collections.append(ExampleItem(collectionTitle: "Expand your chord vocabulary",
            imageUrl: "https://cdn.ustatik.com/storage/songbook/7/778109.png", hitsCount: 0,
            commentsCount: 0,
            likesCount: 0))
        
        collections.append(ExampleItem(collectionTitle: "Classic hits that are suitable for kids",
            imageUrl: "https://cdn.ustatik.com/storage/songbook/7/788867.png", hitsCount: 0,
            commentsCount: 0,
            likesCount: 0))
        
        collections.append(ExampleItem(collectionTitle: "Have lots of fun playing riffs from these songs",
            imageUrl: "https://cdn.ustatik.com/storage/songbook/7/723881.png", hitsCount: 0,
            commentsCount: 0,
            likesCount: 0))
    }
}
