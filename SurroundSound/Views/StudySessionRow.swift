import SwiftUI

struct StudySessionRow: View {
    let session: StudySession

    private var environmentScore: Double { session.calcEnvironmentScore() }
    private var consistencyScore: Double { session.calcConsistencyScore() }
    private var confidenceScore: Double { session.calcConfidenceScore() }
    private var studyScore: Double {
        let score = 0.60 * environmentScore + 0.10 * consistencyScore + 0.30 * confidenceScore
        return score * 100.0
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.name)
                    .font(.headline)
                Text(timeRangeString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(studyScoreString)
                    .monospacedDigit()
                    .font(.subheadline)
                Text(durationString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Study session, \(session.name), \(timeRangeString), duration \(durationString), study score \(studyScoreString)")
    }

    private var studyScoreString: String {
        let value = Int(round(studyScore))
        return "\(value)%"
    }

    private var durationString: String {
        guard let end = session.endedAt else { return "In progress" }
        let seconds = Int(end.timeIntervalSince(session.startedAt).rounded())
        return formatDuration(seconds)
    }

    private var timeRangeString: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        if let end = session.endedAt {
            let startStr = df.string(from: session.startedAt)
            let endStr = df.string(from: end)
            return "\(startStr) – \(endStr)"
        } else {
            return "\(df.string(from: session.startedAt))"
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    let session = StudySession(startedAt: Date().addingTimeInterval(-75 * 60), name: "Morning Focus")
    session.endedAt = Date()
    // Sample blocks to make the score non-zero
    let block1 = SoundBlock(label: "Silent", startedAt: Date().addingTimeInterval(-75 * 60), endedAt: Date().addingTimeInterval(-45 * 60), averageConfidence: 0.9)
    let block2 = SoundBlock(label: "Outdoors", startedAt: Date().addingTimeInterval(-45 * 60), endedAt: Date().addingTimeInterval(-15 * 60), averageConfidence: 0.6)
    let block3 = SoundBlock(label: "Talking", startedAt: Date().addingTimeInterval(-15 * 60), endedAt: Date(), averageConfidence: 0.5)
    session.blocks = [block1, block2, block3]

    return List { StudySessionRow(session: session) }
}
