//
//  SoundByte.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-09-03.
//

import Foundation
import SwiftData

@Model
class SoundByte {
    var id: UUID
    var classification: String
    var time: Date
    var confidence: Float
    var duration: Float
    
    init(id: UUID, classification: String, time: Date, confidence: Float, duration: Float) {
        self.id = id
        self.classification = classification
        self.time = time
        self.confidence = confidence
        self.duration = duration
    }
}
