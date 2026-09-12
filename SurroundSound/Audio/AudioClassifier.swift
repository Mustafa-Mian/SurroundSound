// AudioClassifier
// Partially built using Apple Dev documentation + guides

import AVFoundation
import SoundAnalysis
import SwiftData
import Combine

struct AudioClassificationEvent {
    let label: String
    let confidence: Double
    let timestamp: Date
    let startOffset: TimeInterval
    let duration: TimeInterval
}

class AudioClassifier: NSObject {
    private var audioEngine: AVAudioEngine!
    private var inputBus: AVAudioNodeBus!
    private var inputFormat: AVAudioFormat!
    private var streamAnalyzer: SNAudioStreamAnalyzer!
    private let analysisQueue = DispatchQueue(label: "com.SurroundSound.AnalysisQueue")

    // Publishing classification events so observers can just subscribe
    private let classificationSubject = PassthroughSubject<AudioClassificationEvent, Never>()
    var eventPublisher: AnyPublisher<AudioClassificationEvent, Never> { classificationSubject.eraseToAnyPublisher() }

    var recordingStartDate: Date?

    func startRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .default)
        try session.setActive(true)

        audioEngine = AVAudioEngine()
        inputBus = AVAudioNodeBus(0)
        inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
        try audioEngine.start()
        recordingStartDate = Date()

        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)

        let config = MLModelConfiguration()
        let soundClassifier = try SurroundSoundClassifier_1(configuration: config)
        let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
        request.windowDuration = CMTimeMakeWithSeconds(5.0, preferredTimescale: 44_100) // 5 second sound chunks
        request.overlapFactor = 0.0 // back-to-back snippets, non-overlapping

        try streamAnalyzer.add(request, withObserver: self)

        audioEngine.inputNode.installTap(onBus: inputBus, bufferSize: 8192, format: inputFormat) { [weak self] buffer, time in
            self?.analysisQueue.async {
                self?.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
    }

    func stopRecording() {
        audioEngine?.inputNode.removeTap(onBus: inputBus)
        audioEngine?.stop()
        streamAnalyzer?.completeAnalysis()
        recordingStartDate = nil
    }
}

extension AudioClassifier: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        guard let best = result.classifications.max(by: { $0.confidence < $1.confidence }) else { return }

        let label = best.identifier
        let confidence = Double(best.confidence)

        let startOffset = result.timeRange.start.seconds
        let duration = result.timeRange.duration.seconds

        let timestamp: Date
        if let startDate = recordingStartDate {
            timestamp = startDate.addingTimeInterval(startOffset + duration)
        } else {
            timestamp = Date()
        }

        let event = AudioClassificationEvent(
            label: label,
            confidence: confidence,
            timestamp: timestamp,
            startOffset: startOffset,
            duration: duration
        )

        // Deliver on main so UI/persistence subscribers don't have to switch threads
        DispatchQueue.main.async { [weak self] in
            self?.classificationSubject.send(event)
        }
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Analysis failed: \(error)")
    }

    func requestDidComplete(_ request: SNRequest) {
        print("Analysis complete")
    }
}
