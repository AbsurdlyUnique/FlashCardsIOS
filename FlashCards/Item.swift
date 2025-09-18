//
//  Item.swift
//  FlashCards
//
//  Created by Julian Richter on 7/12/25.
//

import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
