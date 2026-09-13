//
//  ListenView.swift
//  SurroundSound
//

import SwiftUI

/// The primary "live" screen: shows what's currently being heard and
/// lets the user start or stop a listening session.
struct ListenView: View {
    @ObservedObject var orchestrator: SoundOrchestrator

    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 12)

                ListeningIndicator(isListening: orchestrator.isRecording)
                    .frame(width: 200, height: 200)

                CurrentClassificationCard(
                    label: orchestrator.currentLabel,
                    confidence: orchestrator.currentConfidence,
                    isActive: orchestrator.isRecording
                )
                .padding(.horizontal)

                controlButton
                    .padding(.horizontal)

                if orchestrator.isRecording && !orchestrator.recentBlocks.isEmpty {
                    RecentStrip(blocks: orchestrator.recentBlocks)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer(minLength: 24)
            }
            .padding(.vertical)
            .animation(.easeInOut(duration: 0.3), value: orchestrator.isRecording)
        }
        .alert("Recording Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private var controlButton: some View {
        Button(action: toggleRecording) {
            Label(
                orchestrator.isRecording ? "Stop Listening" : "Start Listening",
                systemImage: orchestrator.isRecording ? "stop.fill" : "play.fill"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(orchestrator.isRecording ? .red : .accentColor)
        .sensoryFeedback(.impact(weight: .medium), trigger: orchestrator.isRecording)
    }

    private func toggleRecording() {
        if orchestrator.isRecording {
            orchestrator.stop()
        } else {
            do {
                try orchestrator.start(name: "")
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        ListenView(orchestrator: SoundOrchestrator())
    }
}
