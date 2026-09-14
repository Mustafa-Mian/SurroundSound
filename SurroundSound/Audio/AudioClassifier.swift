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

enum AudioClassifierError: LocalizedError {
    case microphonePermissionDenied

    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone access is required to classify sounds. You can enable it in Settings > Privacy & Security > Microphone."
        }
    }
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

    func startRecording() async throws {
        // Without this, a denied/undetermined permission state leaves
        // inputNode.inputFormat(forBus:) reporting an invalid (zero
        // channel) format, which is what was surfacing as OSStatus -50
        // further down in installTap.
        try await ensureMicrophonePermission()

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .default)
        try session.setPreferredSampleRate(44_100)
        try session.setPreferredInputNumberOfChannels(1)
        try session.setPreferredIOBufferDuration(0.02)
        try session.setActive(true)

        // Log current audio route for debugging
        let route = session.currentRoute
        let inputNames = route.inputs.map(\.portName).joined(separator: ", ")
        print("Audio session active. Mode: measurement. Inputs: \(inputNames)")

        audioEngine = AVAudioEngine()
        inputBus = AVAudioNodeBus(0)
        inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
        try audioEngine.start()
        recordingStartDate = Date()

        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)

        let config = MLModelConfiguration()
        let soundClassifier = try SurroundSoundClassifier_1(configuration: config)
        if let labels = soundClassifier.model.modelDescription.classLabels as? [String] {
            print("Loaded model labels: \(labels)")
        } else {
            print("Loaded model labels: (unavailable)")
        }
        let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)

        try streamAnalyzer.add(request, withObserver: self)

        audioEngine.inputNode.installTap(onBus: inputBus, bufferSize: 8192, format: inputFormat) { [weak self] buffer, time in
            self?.analysisQueue.async {
                self?.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
    }

    // Checks current mic authorization and, if undetermined, prompts
    // for it — rather than relying on the audio session to trigger
    // the system dialog implicitly on activation.
    private func ensureMicrophonePermission() async throws {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            return
        case .denied:
            throw AudioClassifierError.microphonePermissionDenied
        case .undetermined:
            let granted = await AVAudioApplication.requestRecordPermission()
            if !granted {
                throw AudioClassifierError.microphonePermissionDenied
            }
        @unknown default:
            throw AudioClassifierError.microphonePermissionDenied
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
