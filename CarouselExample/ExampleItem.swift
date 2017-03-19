//
//  ExampleItem.swift
//
//  Created by Bogdan Manshilin on 7/15/16.
//

import Foundation
import Carousel

class ExampleItem: CarouselItemProtocol {
    @objc var collectionTitle: String?
    @objc var imageUrl: String?
    @objc var hitsCount: Int32
    @objc var commentsCount: Int32
    @objc var likesCount: Int32
    @objc var dislikes: Int32
    @objc var myVote: Int32
    
    init(collectionTitle title: String?, imageUrl url: String?, hitsCount hits: Int32 = 0, commentsCount comments: Int32 = 0, likesCount likes: Int32 = 0) {
        collectionTitle = title
        imageUrl = url
        hitsCount = hits
        commentsCount = comments
        likesCount = likes
        dislikes = 0
        myVote = 0
    }
}
