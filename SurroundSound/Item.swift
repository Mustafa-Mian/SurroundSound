//
//  Item.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-01-18.
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
