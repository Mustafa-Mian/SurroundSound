//
//  HelpView.swift
//
//  How the app works!

import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                VStack(spacing: 12) {
                    ForEach(HelpTopic.all) { topic in
                        HelpRow(topic: topic)
                    }
                }
            }
            .padding()
        }
        .background(Color.brandTeal.ignoresSafeArea())
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image("SurroundSound_Icon_Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 64, height: 64)
                .background(Color.accentColor.opacity(0.15), in: Circle())
            Spacer(minLength: 20)
            Text("A quick overview of the essentials.")
                .font(.subheadline)
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }
}

private struct HelpTopic: Identifiable {
    let id = UUID()
    let icon: String
    let tint: Color
    let title: String
    let description: String

    static let all: [HelpTopic] = [
        HelpTopic(
            icon: "play.circle.fill",
            tint: .accentColor,
            title: "Start a Session",
            description: "Tap Start a Session to begin. You can give the session an optional name to make it easier to find later."
        ),
        HelpTopic(
            icon: "waveform",
            tint: .purple,
            title: "See What's Playing",
            description: "While listening, the sound currently being detected, and how confident the app is, shows live at the top of the screen."
        ),
        HelpTopic(
            icon: "rectangle.stack.fill",
            tint: .orange,
            title: "Recent Sounds",
            description: "A few of your most recent environment sounds appear just below, so you can glance back without losing your place."
        ),
        HelpTopic(
            icon: "stop.circle.fill",
            tint: .red,
            title: "Stop Anytime",
            description: "Tap End Session to end the session. It's saved automatically — nothing else to do."
        ),
        HelpTopic(
            icon: "chart.line.uptrend.xyaxis",
            tint: .blue,
            title: "Unlock Powerful Metrics",
            description: "View a summary of your session, including an overall focus score and a breakdown of your time."
        ),
        HelpTopic(
            icon: "clock.arrow.circlepath",
            tint: .green,
            title: "Browse History",
            description: "Tap the icon at the top of the Listen screen to revisit past sessions and review."
        )
    ]
}

private struct HelpRow: View {
    let topic: HelpTopic

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: topic.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(topic.tint)
                .frame(width: 40, height: 40)
                .background(topic.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .font(.subheadline.bold())
                Text(topic.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
}
