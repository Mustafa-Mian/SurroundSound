//
//  StudySession.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-09-07.
//

import Foundation
import SwiftData

@Model
final class StudySession {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \SoundBlock.session)
    var blocks: [SoundBlock] = []

    init(id: UUID = UUID(), startedAt: Date = .now) {
        self.id = id
        self.startedAt = startedAt
    }
}

