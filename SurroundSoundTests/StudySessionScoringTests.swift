#if canImport(Testing)
import Testing
import Foundation
@testable import SurroundSound

@Suite("StudySession scoring and model tests")
struct StudySessionScoringTests {

    @Test("SoundBlock duration computed property")
    func soundBlockDuration() async throws {
        let start = Date()
        let end = start.addingTimeInterval(90)
        let block = SoundBlock(label: "Silent", startedAt: start, endedAt: end, averageConfidence: 0.8)
        #expect(abs(block.duration - 90) < 0.001)
    }

    @Test("Default session naming when name is empty")
    func defaultSessionName() async throws {
        let session = StudySession(name: "")
        #expect(session.name.hasSuffix(" session"))
        #expect(!session.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    @Test("Environment score weighted by durations and focusWeights")
    func environmentScore() async throws {
        let session = StudySession(name: "Test")
        // 30s Silent (1.0), 30s Talking (0.2)
        let start = Date()
        let b1 = SoundBlock(label: "Silent", startedAt: start, endedAt: start.addingTimeInterval(30), averageConfidence: 0.9)
        let b2 = SoundBlock(label: "Talking", startedAt: b1.endedAt, endedAt: b1.endedAt.addingTimeInterval(30), averageConfidence: 0.6)
        session.blocks = [b1, b2]
        let env = session.calcEnvironmentScore()
        // expected = (30*1.0 + 30*0.2) / 60 = (30 + 6)/60 = 0.6
        #expect(abs(env - 0.6) < 0.0001)
    }

    @Test("Consistency score based on transitions per minute")
    func consistencyScore() async throws {
        let session = StudySession(name: "Test")
        let start = Date()
        let b1 = SoundBlock(label: "Silent", startedAt: start, endedAt: start.addingTimeInterval(40), averageConfidence: 0.9)
        let b2 = SoundBlock(label: "Music", startedAt: b1.endedAt, endedAt: b1.endedAt.addingTimeInterval(40), averageConfidence: 0.6)
        let b3 = SoundBlock(label: "Silent", startedAt: b2.endedAt, endedAt: b2.endedAt.addingTimeInterval(40), averageConfidence: 0.8)
        session.blocks = [b1, b2, b3]
        // total 120s, transitions = 2 => transitions/min = 2 / 2 = 1 => score = 1 - 0.1 = 0.9
        let consistency = session.calcConsistencyScore()
        #expect(abs(consistency - 0.9) < 0.0001)
    }

    @Test("Confidence score weighted by duration")
    func confidenceScore() async throws {
        let session = StudySession(name: "Test")
        let start = Date()
        // 20s at 0.5, 40s at 1.0 => (20*0.5 + 40*1.0) / 60 = (10 + 40)/60 = 0.8333...
        let b1 = SoundBlock(label: "Outdoors", startedAt: start, endedAt: start.addingTimeInterval(20), averageConfidence: 0.5)
        let b2 = SoundBlock(label: "Silent", startedAt: b1.endedAt, endedAt: b1.endedAt.addingTimeInterval(40), averageConfidence: 1.0)
        session.blocks = [b1, b2]
        let conf = session.calcConfidenceScore()
        #expect(abs(conf - (50.0/60.0)) < 0.0001)
    }

    @Test("calcFocusScore combines components into 0-100")
    func focusScore() async throws {
        let session = StudySession(name: "Test")
        let start = Date()
        let b1 = SoundBlock(label: "Silent", startedAt: start, endedAt: start.addingTimeInterval(60), averageConfidence: 0.9)
        session.blocks = [b1]
        session.calcFocusScore()
        let score = try #require(session.studyScore)
        #expect(score >= 0 && score <= 100)
        // With all silent and high confidence, should be high
        #expect(score > 80)
    }
}
#else
import XCTest
import Foundation
@testable import SurroundSound

final class StudySessionScoringTests: XCTestCase {

    func testSoundBlockDuration() throws {
        let start = Date()
        let end = start.addingTimeInterval(90)
        let block = SoundBlock(label: "Silent", startedAt: start, endedAt: end, averageConfidence: 0.8)
        XCTAssertEqual(block.duration, 90, accuracy: 0.001)
    }

    func testDefaultSessionName() throws {
        let session = StudySession(name: "")
        XCTAssertTrue(session.name.hasSuffix(" session"))
        XCTAssertFalse(session.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    func testEnvironmentScore() throws {
        let session = StudySession(name: "Test")
        let start = Date()
        let b1 = SoundBlock(label: "Silent", startedAt: start, endedAt: start.addingTimeInterval(30), averageConfidence: 0.9)
        let b2 = SoundBlock(label: "Talking", startedAt: b1.endedAt, endedAt: b1.endedAt.addingTimeInterval(30), averageConfidence: 0.6)
        session.blocks = [b1, b2]
        let env = session.calcEnvironmentScore()
        XCTAssertEqual(env, 0.6, accuracy: 0.0001)
    }

    func testConsistencyScore() throws {
        let session = StudySession(name: "Test")
        let start = Date()
        let b1 = SoundBlock(label: "Silent", startedAt: start, endedAt: start.addingTimeInterval(40), averageConfidence: 0.9)
        let b2 = SoundBlock(label: "Music", startedAt: b1.endedAt, endedAt: b1.endedAt.addingTimeInterval(40), averageConfidence: 0.6)
        let b3 = SoundBlock(label: "Silent", startedAt: b2.endedAt, endedAt: b2.endedAt.addingTimeInterval(40), averageConfidence: 0.8)
        session.blocks = [b1, b2, b3]
        let consistency = session.calcConsistencyScore()
        XCTAssertEqual(consistency, 0.9, accuracy: 0.0001)
    }

    func testConfidenceScore() throws {
        let session = StudySession(name: "Test")
        let start = Date()
        let b1 = SoundBlock(label: "Outdoors", startedAt: start, endedAt: start.addingTimeInterval(20), averageConfidence: 0.5)
        let b2 = SoundBlock(label: "Silent", startedAt: b1.endedAt, endedAt: b1.endedAt.addingTimeInterval(40), averageConfidence: 1.0)
        session.blocks = [b1, b2]
        let conf = session.calcConfidenceScore()
        XCTAssertEqual(conf, 50.0/60.0, accuracy: 0.0001)
    }

    func testFocusScore() throws {
        let session = StudySession(name: "Test")
        let start = Date()
        let b1 = SoundBlock(label: "Silent", startedAt: start, endedAt: start.addingTimeInterval(60), averageConfidence: 0.9)
        session.blocks = [b1]
        session.calcFocusScore()
        XCTAssertNotNil(session.studyScore)
        let score = session.studyScore!
        XCTAssertTrue(score >= 0 && score <= 100)
        XCTAssertTrue(score > 80)
    }
}
#endif
