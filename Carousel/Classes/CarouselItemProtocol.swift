//
//  CarouselItemProtocol.swift
//
//  Created by Bogdan Manshilin on 7/15/16.
//

import Foundation

@objc
public protocol CarouselItemProtocol {
    var collectionTitle: String? { get }
    var imageUrl: String? { get }
    var hitsCount: Int32 { get }
    var commentsCount: Int32 { get }
    var likesCount: Int32 { get set }
    var dislikes: Int32 { get set }
    var myVote: Int32 { get set }
}
