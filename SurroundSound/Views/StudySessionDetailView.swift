import SwiftUI

struct StudySessionDetailView: View {
    let session: StudySession

    private var environment: Double { session.calcEnvironmentScore() }
    private var consistency: Double { session.calcConsistencyScore() }
    private var confidence: Double { session.calcConfidenceScore() }

    private var studyScore: Double {
        (0.60 * environment + 0.25 * consistency + 0.15 * confidence) * 100
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                scoreCard
                components
                if !session.blocks.isEmpty {
                    blockSummary
                }
                Spacer(minLength: 12)
            }
            .padding()
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.name)
                .font(.title2.bold())
            Text(dateRange)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Study Score")
                .font(.headline)
            HStack(alignment: .firstTextBaseline) {
                Text("\(Int(studyScore.rounded()))%")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Spacer()
                Text(durationString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var components: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Components")
                .font(.headline)
            VStack(spacing: 8) {
                componentRow(title: "Environment", value: environment)
                componentRow(title: "Consistency", value: consistency)
                componentRow(title: "Confidence", value: confidence)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func componentRow(title: String, value: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(Int((value * 100).rounded()))%")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
    }

    private var blockSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Breakdown")
                .font(.headline)
            ForEach(session.blocks) { block in
                HStack {
                    Text(block.label)
                    Spacer()
                    Text("\(formatDuration(Int(block.duration))) • \(Int((block.averageConfidence * 100).rounded()))%")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
    }

    private var dateRange: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        if let end = session.endedAt {
            return "\(df.string(from: session.startedAt)) – \(df.string(from: end))"
        } else {
            return df.string(from: session.startedAt)
        }
    }

    private var durationString: String {
        guard let end = session.endedAt else { return "In progress" }
        let total = Int(end.timeIntervalSince(session.startedAt))
        return formatDuration(total)
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
    let session = StudySession(startedAt: Date().addingTimeInterval(-2 * 3600), name: "Deep Work")
    session.endedAt = Date()
    let b1 = SoundBlock(label: "Silent", startedAt: Date().addingTimeInterval(-7200), endedAt: Date().addingTimeInterval(-3600), averageConfidence: 0.9)
    let b2 = SoundBlock(label: "Outdoors", startedAt: Date().addingTimeInterval(-3600), endedAt: Date().addingTimeInterval(-1800), averageConfidence: 0.6)
    let b3 = SoundBlock(label: "Talking", startedAt: Date().addingTimeInterval(-1800), endedAt: Date(), averageConfidence: 0.5)
    session.blocks = [b1, b2, b3]

    return NavigationStack { StudySessionDetailView(session: session) }
}
