//
//  SoundBlock.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-09-11.
//

import Foundation
import SwiftData

@Model
final class SoundBlock {
    @Attribute(.unique) var id: UUID
    var label: String
    var startedAt: Date
    var endedAt: Date
    var averageConfidence: Double
    var eventCount: Int
    
    // Association to a study session
    var session: StudySession?

    // Derived, not stored in the model container
    var duration: TimeInterval { endedAt.timeIntervalSince(startedAt) }

    init(
        id: UUID = UUID(),
        label: String,
        startedAt: Date,
        endedAt: Date,
        averageConfidence: Double,
        eventCount: Int = 1,
        session: StudySession? = nil
    ) {
        self.id = id
        self.label = label
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.averageConfidence = averageConfidence
        self.eventCount = eventCount
        self.session = session
    }
}
