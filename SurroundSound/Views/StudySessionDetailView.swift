//  StudySessionDetailView.swift

import SwiftUI

struct StudySessionDetailView: View {
    let session: StudySession

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var environment: Double { session.calcEnvironmentScore() }
    private var consistency: Double { session.calcConsistencyScore() }
    private var confidence: Double { session.calcConfidenceScore() }

    private var studyScore: Double {
        (0.60 * environment + 0.10 * consistency + 0.30 * confidence) * 100
    }

    private var scoreTier: ScoreTier { ScoreTier(percentage: studyScore) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                    .cardAppear(appeared, delay: 0)

                scoreCard
                    .cardAppear(appeared, delay: 0.05)

                components
                    .cardAppear(appeared, delay: 0.10)

                if !categorySummaries.isEmpty {
                    breakdown
                        .cardAppear(appeared, delay: 0.15)
                }

                Spacer(minLength: 12)
            }
            .padding()
        }
        .background(Color.brandTeal.ignoresSafeArea())
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.name)
                .font(.title2.bold())
            Text(dateRange)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Score

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Session Score")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(Int(studyScore.rounded()))%")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                Spacer()
                Text(durationString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack(spacing: 10) {
                Image(systemName: scoreTier.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(scoreTier.color)
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)

                Text(scoreTier.message)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.primary)

                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Components

    private var components: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Components")
                .font(.headline)

            VStack(spacing: 10) {
                componentRow(title: "Environment", value: environment)
                Divider()
                componentRow(title: "Consistency", value: consistency)
                Divider()
                componentRow(title: "Confidence", value: confidence)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func componentRow(title: String, value: Double) -> some View {
        let tier = ScoreTier(percentage: value * 100)
        return HStack(spacing: 10) {
            Image(systemName: tier.icon)
                .font(.subheadline)
                .foregroundStyle(tier.color)
                .frame(width: 18)

            Text(title)
                .font(.subheadline)

            Spacer()

            Text(tier.compactLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tier.color)

            Text("\(Int((value * 100).rounded()))%")
                .font(.subheadline)
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .trailing)
        }
    }

    // MARK: - Breakdown (grouped by category)

    private struct CategorySummary: Identifiable {
        let id = UUID()
        let label: String
        let totalDuration: TimeInterval
        let averageConfidence: Double
    }

    private var categorySummaries: [CategorySummary] {
        Dictionary(grouping: session.blocks, by: \.label)
            .map { label, blocks in
                let totalDuration = blocks.reduce(0) { $0 + $1.duration }
                let weightedConfidence = blocks.reduce(0) { $0 + $1.averageConfidence * $1.duration }
                let avgConfidence = totalDuration > 0 ? weightedConfidence / totalDuration : 0
                return CategorySummary(label: label, totalDuration: totalDuration, averageConfidence: avgConfidence)
            }
            .sorted { $0.totalDuration > $1.totalDuration }
    }

    private var totalTrackedDuration: TimeInterval {
        categorySummaries.reduce(0) { $0 + $1.totalDuration }
    }

    private var breakdown: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Breakdown")
                .font(.headline)

            VStack(spacing: 14) {
                ForEach(Array(categorySummaries.enumerated()), id: \.element.id) { index, summary in
                    if index > 0 { Divider() }
                    categoryRow(summary)
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func categoryRow(_ summary: CategorySummary) -> some View {
        let share = totalTrackedDuration > 0 ? summary.totalDuration / totalTrackedDuration : 0

        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(summary.label)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(formatDuration(Int(summary.totalDuration)))
                    .font(.subheadline)
                    .monospacedDigit()
                Text("· \(Int((summary.averageConfidence * 100).rounded()))% avg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule()
                        .fill(Color.accentColor.opacity(0.85))
                        .frame(width: max(geo.size.width * share, 4))
                }
            }
            .frame(height: 5)
        }
    }

    // MARK: - Formatting

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

// MARK: - Score Tier

// Shared reactivity for any 0–100% score: an icon, color, and message
// that changes based on which bucket the value falls into. Used by
// both the overall Study Score and each individual component.
private enum ScoreTier {
    case needsWork
    case good
    case excellent

    init(percentage: Double) {
        switch percentage {
        case ..<50: self = .needsWork
        case ..<80: self = .good
        default: self = .excellent
        }
    }

    var icon: String {
        switch self {
        case .needsWork: "exclamationmark.triangle.fill"
        case .good: "checkmark.circle.fill"
        case .excellent: "star.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .needsWork: .red
        case .good: .brandGreen
        case .excellent: .brandYellow
        }
    }

    // Full message, used on the main score card.
    var message: String {
        switch self {
        case .needsWork: "Needs Improvement. This space is not recommended for studying."
        case .good: "A Solid Session. With some adjustments this space will work well for studying."
        case .excellent: "An Excellent Session. Recommend this space for future studying."
        }
    }

    // Short label, used inline on component rows.
    var compactLabel: String {
        switch self {
        case .needsWork: "Low"
        case .good: "Good"
        case .excellent: "Great"
        }
    }
}

// MARK: - Appear Animation

// A small staggered fade + rise used to bring each card in on appear.
// Disabled entirely under Reduce Motion.
private struct CardAppear: ViewModifier {
    let appeared: Bool
    let delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.35).delay(delay), value: appeared)
    }
}

private extension View {
    func cardAppear(_ appeared: Bool, delay: Double = 0) -> some View {
        modifier(CardAppear(appeared: appeared, delay: delay))
    }
}

#Preview {
    let session = StudySession(startedAt: Date().addingTimeInterval(-2 * 3600), name: "Deep Work")
    session.endedAt = Date()
    let b1 = SoundBlock(label: "Silence", startedAt: Date().addingTimeInterval(-7200), endedAt: Date().addingTimeInterval(-6300), averageConfidence: 0.9)
    let b2 = SoundBlock(label: "Silence", startedAt: Date().addingTimeInterval(-6000), endedAt: Date().addingTimeInterval(-3600), averageConfidence: 0.85)
    let b3 = SoundBlock(label: "Outdoors", startedAt: Date().addingTimeInterval(-3600), endedAt: Date().addingTimeInterval(-1800), averageConfidence: 0.6)
    let b4 = SoundBlock(label: "Talking", startedAt: Date().addingTimeInterval(-1800), endedAt: Date(), averageConfidence: 0.5)
    session.blocks = [b1, b2, b3, b4]

    return NavigationStack { StudySessionDetailView(session: session) }
}
