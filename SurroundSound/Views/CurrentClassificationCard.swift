//
//  CurrentClassificationCard.swift
//  SurroundSound
//

import SwiftUI

/// Displays the current classification label and confidence,
/// crossfading smoothly whenever the label changes rather than
/// popping to the new value instantly.
struct CurrentClassificationCard: View {
    let label: String
    let confidence: Double
    let isActive: Bool

    var body: some View {
        VStack(spacing: 10) {
            Text(isActive ? label : "Not listening")
                .font(.title2.bold())
                .contentTransition(.opacity)
                .id(isActive ? label : "idle")
                .transition(.opacity.combined(with: .scale(scale: 0.96)))

            if isActive {
                ConfidenceMeter(value: confidence)
                    .frame(height: 6)
                    .padding(.horizontal, 32)

                Text("\(Int((confidence * 100).rounded()))% confidence")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
        }
        .animation(.easeInOut(duration: 0.25), value: label)
        .animation(.easeInOut(duration: 0.25), value: isActive)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

/// A thin, color-coded progress bar representing classification confidence.
private struct ConfidenceMeter: View {
    let value: Double // 0...1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(.systemGray5))
                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * min(max(value, 0), 1))
            }
        }
        .animation(.easeOut(duration: 0.3), value: value)
    }

    private var color: Color {
        switch value {
        case ..<0.4: .orange
        case ..<0.7: .yellow
        default: .green
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CurrentClassificationCard(label: "Dog Barking", confidence: 0.87, isActive: true)
        CurrentClassificationCard(label: "—", confidence: 0, isActive: false)
    }
    .padding()
}
