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
    var studyScore: Double?
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \SoundBlock.session)
    var blocks: [SoundBlock] = []
    
    var focusWeights: [String: Double] = [
        "Silent": 1.0,
        "Outdoors": 0.7,
        "Music": 0.6,
        "Keyboard": 0.9,
        "Talking": 0.2,
        "Traffic": 0.2
    ]

    init(id: UUID = UUID(), startedAt: Date = .now, name: String) {
        self.id = id
        self.startedAt = startedAt
        if name.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: Date())
            self.name = dateString + " session"
        } else {
            self.name = name
        }
    }
    
    func calcEnvironmentScore() -> Double {
        var weightedScore = 0.0
        var totalDuration = 0.0
        
        for block in blocks {
            let weight = focusWeights[block.label] ?? 0.0

            weightedScore += block.duration * weight
            totalDuration += block.duration
        }

        guard totalDuration > 0 else { return 0 }

        return weightedScore / totalDuration
    }
    
    func calcConsistencyScore() -> Double {
        guard blocks.count > 1 else {
                return 1.0
            }

            let totalDuration = blocks.reduce(0) {
                $0 + $1.duration
            }

            let transitions = blocks.count - 1

            let transitionsPerMinute =
                Double(transitions) / (totalDuration / 60.0)

            // 0 transitions/min = perfect consistency
            // 10 transitions/min = very inconsistent
            let score = 1.0 - min(transitionsPerMinute / 10.0, 1.0)

            return score
    }
    
    func calcConfidenceScore() -> Double {
        guard !blocks.isEmpty else { return 0 }

        let totalDuration = blocks.reduce(0) {
            $0 + $1.duration
        }

        guard totalDuration > 0 else { return 0 }

        let weightedConfidence = blocks.reduce(0.0) {
            $0 + ($1.averageConfidence * $1.duration)
        }

        return weightedConfidence / totalDuration
    }
    
    func calcFocusScore() {
        let environment = calcEnvironmentScore()
        let consistency = calcConsistencyScore()
        let confidence = calcConfidenceScore()

        let score =
            0.60 * environment +
            0.10 * consistency +
            0.30 * confidence

        studyScore = score * 100
    }
}

