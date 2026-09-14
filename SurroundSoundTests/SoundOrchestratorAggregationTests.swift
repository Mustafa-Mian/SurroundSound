#if canImport(Testing) && DEBUG
import Testing
import Foundation
@testable import SurroundSound

@Suite("SoundOrchestrator aggregation")
struct SoundOrchestratorAggregationTests {

    @MainActor
    @Test("Ignores low confidence events (< 0.6)")
    func ignoresLowConfidence() async throws {
        let orchestrator = SoundOrchestrator()
        orchestrator._testResetAggregation()
        let now = Date()
        let low = AudioClassificationEvent(label: "Talking", confidence: 0.4, timestamp: now, startOffset: 0, duration: 1)
        orchestrator._testInject(event: low)
        #expect(orchestrator.recentBlocks.isEmpty)
        #expect(orchestrator.currentLabel == "—")
        #expect(orchestrator.currentConfidence == 0)
    }

    @MainActor
    @Test("Finalizes block after label change with >=3 events")
    func finalizeOnLabelChange() async throws {
        let orchestrator = SoundOrchestrator()
        orchestrator._testResetAggregation()
        let base = Date()
        for i in 0..<3 {
            let ts = base.addingTimeInterval(Double(i + 1))
            let e = AudioClassificationEvent(label: "Silent", confidence: 0.8, timestamp: ts, startOffset: 0, duration: 1)
            orchestrator._testInject(event: e)
        }
        // inject different label to trigger finalize of previous block
        let after = base.addingTimeInterval(4)
        orchestrator._testInject(event: AudioClassificationEvent(label: "Music", confidence: 0.7, timestamp: after, startOffset: 0, duration: 1))
        #expect(orchestrator.recentBlocks.count == 1)
        let block = try #require(orchestrator.recentBlocks.first)
        #expect(block.label == "Silent")
        #expect(block.eventCount == 3)
        #expect(abs(block.averageConfidence - 0.8) < 0.0001)
        #expect(orchestrator.currentLabel == "Music")
    }

    @MainActor
    @Test("Manual finalize produces a block with expected duration and average")
    func manualFinalize() async throws {
        let orchestrator = SoundOrchestrator()
        orchestrator._testResetAggregation()
        let start = Date()
        for i in 0..<3 {
            let ts = start.addingTimeInterval(Double(10 + i))
            let e = AudioClassificationEvent(label: "Outdoors", confidence: 0.6 + Double(i) * 0.1, timestamp: ts, startOffset: 0, duration: 1)
            orchestrator._testInject(event: e)
        }
        orchestrator._testFinalizeBlock()
        #expect(orchestrator.recentBlocks.count == 1)
        let block = try #require(orchestrator.recentBlocks.first)
        #expect(block.label == "Outdoors")
        #expect(block.eventCount == 3)
        let expectedAvg = (0.6 + 0.7 + 0.8) / 3.0
        #expect(abs(block.averageConfidence - expectedAvg) < 0.0001)
        // duration should be (last end) - (first start) = (start+12) - (start+9) = 3
        #expect(abs(block.duration - 3.0) < 0.0001)
    }

    @MainActor
    @Test("Keeps only the 10 most recent blocks")
    func recentBlocksLimit() async throws {
        let orchestrator = SoundOrchestrator()
        orchestrator._testResetAggregation()
        let base = Date()
        for i in 0..<12 {
            let label = "L\(i)"
            for j in 0..<3 {
                let ts = base.addingTimeInterval(Double(i * 10 + j))
                let e = AudioClassificationEvent(label: label, confidence: 0.7, timestamp: ts, startOffset: 0, duration: 1)
                orchestrator._testInject(event: e)
            }
            orchestrator._testFinalizeBlock()
        }
        #expect(orchestrator.recentBlocks.count == 10)
        let first = try #require(orchestrator.recentBlocks.first)
        let last = try #require(orchestrator.recentBlocks.last)
        #expect(first.label == "L2")
        #expect(last.label == "L11")
    }
}
#else
// No-op placeholder when Swift Testing or DEBUG hooks are unavailable.
#endif
