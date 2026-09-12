//
//  SoundOrchestrator.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-09-08.
//

import Foundation
import SwiftData
import SoundAnalysis
import Combine

@MainActor
final class SoundOrchestrator: ObservableObject {

    // Dependencies
    private let classifier = AudioClassifier()
    private var modelContext: ModelContext?
    private var activeSession: StudySession?

    // Combine
    private var cancellables = Set<AnyCancellable>()

    // State
    @Published private(set) var isRecording = false
    @Published private(set) var recentBlocks: [SoundBlock] = []

    // Aggregation state for building contiguous blocks
    private struct BlockState {
        var label: String
        var start: Date
        var end: Date
        var confidenceSum: Double
        var count: Int
    }

    private var blockState: BlockState?

    // MARK: - Init
    init(modelContext: ModelContext? = nil, session: StudySession? = nil) {
        self.modelContext = modelContext
        self.activeSession = session
        subscribe()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func setActiveSession(_ session: StudySession?) {
        // Finalize current block if the session is changing
        if session?.id != activeSession?.id {
            finalizeCurrentBlock()
        }
        self.activeSession = session
    }

    // MARK: - Control
    private func beginNewSession() {
        // Always create a fresh session on start
        let session = StudySession()
        self.activeSession = session

        if let ctx = modelContext {
            ctx.insert(session)
            // Do not save here; we will save on stop()
            print("StudySession created and inserted (pending save)")
        } else {
            print("StudySession created (no modelContext; will be unsaved)")
        }
    }

    func start() throws {
        // Begin a new session and reset aggregation
        beginNewSession()
        try classifier.startRecording()
        resetAggregation()
        isRecording = true
    }

    func stop() {
        classifier.stopRecording()
        finalizeCurrentBlock()
        isRecording = false

        // Mark the active session as ended
        activeSession?.endedAt = Date()

        if let ctx = modelContext {
            do {
                try ctx.save()
                print("StudySession and associated SoundBlocks saved on stop")
            } catch {
                print("Failed to save context on stop: \(error)")
            }
        }

        // Clear the active session after saving
        activeSession = nil
    }

    // MARK: - Subscribe to classifier events
    private func subscribe() {
        classifier.eventPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                self?.handleAggregation(for: event)
            }
            .store(in: &cancellables)
    }

    // MARK: - Aggregation
    private func resetAggregation() {
        blockState = nil
    }

    private func handleAggregation(for event: AudioClassificationEvent) {
        // We treat consecutive events with the same label as a single contiguous block
        let eventEnd = event.timestamp
        let eventStart = event.timestamp.addingTimeInterval(-event.duration)

        if var state = blockState {
            if state.label == event.label {
                // Extend current block
                state.end = eventEnd
                state.confidenceSum += event.confidence
                state.count += 1
                blockState = state
            } else {
                // Label changed: finalize previous block and start a new one
                finalizeCurrentBlock()
                blockState = BlockState(
                    label: event.label,
                    start: eventStart,
                    end: eventEnd,
                    confidenceSum: event.confidence,
                    count: 1
                )
            }
        } else {
            // Start first block
            blockState = BlockState(
                label: event.label,
                start: eventStart,
                end: eventEnd,
                confidenceSum: event.confidence,
                count: 1
            )
        }
    }

    private func finalizeCurrentBlock() {
        guard let state = blockState else { return }
        let avg = state.confidenceSum / Double(max(state.count, 1))
        let block = SoundBlock(
            label: state.label,
            startedAt: state.start,
            endedAt: state.end,
            averageConfidence: avg,
            eventCount: state.count,
            session: activeSession
        )

        // Keep a recent in-memory list for UI consumption
        recentBlocks.append(block)
        if recentBlocks.count > 10 {
            recentBlocks.removeFirst(recentBlocks.count - 10)
        }

        if let ctx = modelContext {
            ctx.insert(block)
            print("SoundBlock inserted (pending save): \(block.label) representing \(block.eventCount * 5) seconds of audio from \(block.startedAt) to \(block.endedAt)")
        } else {
            print("SoundBlock (unsaved) -> \(block.label) [\(block.eventCount) evts] from \(block.startedAt) to \(block.endedAt)")
        }

        // Clear for the next block
        blockState = nil
    }
}
