//
//  Item.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-08-27.
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
