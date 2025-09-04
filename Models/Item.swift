//
//  Item.swift
//  app2
//
//  Created by AI Assistant on 2024/01/20.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}