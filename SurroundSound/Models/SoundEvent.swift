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
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var label: String
    var confidence: Double
    var startOffset: Double?
    var duration: Double?
    var session: StudySession?

    init(
        id: UUID = UUID(),
        timestamp: Date,
        label: String,
        confidence: Double,
        startOffset: Double? = nil,
        duration: Double? = nil,
        session: StudySession? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.label = label
        self.confidence = confidence
        self.startOffset = startOffset
        self.duration = duration
        self.session = session
    }
}
