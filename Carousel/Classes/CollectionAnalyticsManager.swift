//
//  CollectionAnalyticsManager.swift
//
//  Created by Bogdan Manshilin on 7/15/16.
//

import Foundation

public protocol CarouselAnalyticsManager {
    func onShowItems()
    func onOpen(item: CarouselItemProtocol)
}
