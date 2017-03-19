//
//  CarouselItemProtocol.swift
//
//  Created by Bogdan Manshilin on 7/15/16.
//

import Foundation

@objc public protocol CarouselItemProtocol {
    var collectionTitle: String? { get }
    var imageUrl: String? { get }
    var hitsCount: NSNumber? { get }
    var commentsCount: NSNumber? { get }
    var likesCount: NSNumber? { get }
}
