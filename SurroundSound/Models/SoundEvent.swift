//
//  SoundEvent.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-09-07.
//


import Foundation
import SwiftData

@Model
final class SoundEvent {
    var id: UUID
    var category: String
    
    var startTime: Date
    var endTime: Date
    
    var averageConfidence: Double
    
    init(
        category: SoundClass,
        startTime: Date,
        endTime: Date,
        averageConfidence: Double
    ) {
        self.id = UUID()
        self.category = category.rawValue
        self.startTime = startTime
        self.endTime = endTime
        self.averageConfidence = averageConfidence
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
}
