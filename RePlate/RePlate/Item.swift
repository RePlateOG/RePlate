//
//  Item.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
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
