//
//  ListeningIndicator.swift
//  SurroundSound
//

import SwiftUI

/// An animated, pulsing ring around a central waveform icon that
/// visually communicates whether the app is actively listening.
/// Respects Reduce Motion by holding a static state instead of pulsing.
struct ListeningIndicator: View {
    let isListening: Bool

    @State private var pulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if !reduceMotion {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.accentColor.opacity(isListening ? 0.35 : 0), lineWidth: 2)
                        .scaleEffect(pulse ? 1.35 + CGFloat(i) * 0.15 : 0.75)
                        .opacity(pulse ? 0 : 1)
                        .animation(
                            isListening
                                ? .easeOut(duration: 1.8).repeatForever(autoreverses: false).delay(Double(i) * 0.4)
                                : .easeOut(duration: 0.3),
                            value: pulse
                        )
                }
            }

            Circle()
                .fill(isListening ? Color.accentColor : Color(.systemGray5))
                .shadow(color: isListening ? Color.accentColor.opacity(0.35) : .clear, radius: 18)

            Image(systemName: isListening ? "waveform" : "waveform.slash")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(isListening ? .white : .secondary)
                .symbolEffect(.variableColor.iterative, isActive: isListening && !reduceMotion)
        }
        .onAppear { pulse = isListening }
        .onChange(of: isListening) { _, newValue in pulse = newValue }
        .accessibilityElement()
        .accessibilityLabel(isListening ? "Listening" : "Not listening")
    }
}

#Preview {
    VStack(spacing: 40) {
        ListeningIndicator(isListening: true).frame(width: 200, height: 200)
        ListeningIndicator(isListening: false).frame(width: 200, height: 200)
    }
}
