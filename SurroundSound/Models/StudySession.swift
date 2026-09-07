//
//  StudySession.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-09-07.
//

import Foundation
import SwiftData

@Model
final class FocusSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    
    init(startTime: Date) {
        self.id = UUID()
        self.startTime = startTime
    }
    
    var duration: TimeInterval? {
        guard let endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
}
