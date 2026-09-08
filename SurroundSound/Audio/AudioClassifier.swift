// AudioClassifier
// Partially built using Apple documentation + guides

import AVFoundation
import SoundAnalysis
import SwiftData

class AudioClassifier {
    private var audioEngine: AVAudioEngine!
    private var inputBus: AVAudioNodeBus!
    private var inputFormat: AVAudioFormat!
    private var streamAnalyzer: SNAudioStreamAnalyzer!
    private let analysisQueue = DispatchQueue(label: "com.SurroundSound.AnalysisQueue")
    var onClassification = ((SNClassificationResult) -> Void)?
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
        request.overlapFactor = 0.0 // back 2 back snippets, non-overlapping

        try streamAnalyzer.add(request, withObserver: self)

        audioEngine.inputNode.installTap(onBus: inputBus, bufferSize: 8192, format: inputFormat) { [weak self] buffer, time in
            self?.analysisQueue.async {
                self?.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
    }

    func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: inputBus)
        audioEngine.stop()
        streamAnalyzer.completeAnalysis()
    }
}

extension AudioClassifier: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        onClassification?(result)
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Analysis failed: \(error)")
    }

    func requestDidComplete(_ request: SNRequest) {
        print("Analysis complete")
    }
}
