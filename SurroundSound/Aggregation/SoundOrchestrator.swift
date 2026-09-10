//
//  SoundOrchestrator.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-09-08.
//

import Foundation
import SwiftData
import SoundAnalysis
internal import Combine

@MainActor
final class SoundOrchestrator: ObservableObject {

    // Dependencies
    private let classifier = AudioClassifier()
    private var modelContext: ModelContext?
    private var activeSession: StudySession?

    // State
    @Published private(set) var isRecording = false

    // MARK: - Init
    init(modelContext: ModelContext? = nil, session: StudySession? = nil) {
        self.modelContext = modelContext
        self.activeSession = session
        wireUpClassifier()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func setActiveSession(_ session: StudySession?) {
        self.activeSession = session
    }

    // MARK: - Control
    func start() throws {
        try classifier.startRecording()
        isRecording = true
    }

    func stop() {
        classifier.stopRecording()
        isRecording = false
    }

    // MARK: - Private
    private func wireUpClassifier() {
        classifier.onClassification = { [weak self] result in
            // Hop to main actor to interact with SwiftData
            Task { @MainActor in
                self?.persist(result)
            }
        }
    }

    private func persist(_ result: SNClassificationResult) {
        guard let best = result.classifications.max(by: { $0.confidence < $1.confidence }) else { return }

        let label = best.identifier
        let confidence = Double(best.confidence)

        // Compute a wall-clock timestamp for this 5s window
        let timestamp: Date
        if let startDate = classifier.recordingStartDate {
            let seconds = result.timeRange.start.seconds + result.timeRange.duration.seconds
            timestamp = startDate.addingTimeInterval(seconds)
        } else {
            timestamp = Date()
        }

        let event = SoundEvent(timestamp: timestamp, label: label, confidence: confidence, session: activeSession)

        guard let ctx = modelContext else {
            // If no context yet, you can still inspect the event in the console
            print("SoundEvent (unsaved) -> \(label) @ \(timestamp) [\(confidence)]")
            return
        }

        ctx.insert(event)
        do {
            try ctx.save()
        } catch {
            print("Failed to save SoundEvent: \(error)")
        }
    }
}
