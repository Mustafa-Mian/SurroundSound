//
//  RootView.swift
//  SurroundSound
//

import SwiftUI
import SwiftData

/// Places the app can navigate to beyond the live Listen screen.
enum AppRoute: Hashable {
    case history
}

// App entry point. Owns the orchestrator and navigation, and keeps
// the live "Listen" screen as the default.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var orchestrator = SoundOrchestrator()
    @State private var path = NavigationPath()

    // Shown once per app launch. Resets naturally on the next cold start
    // since it's plain @State, not persisted. See WelcomeView.swift's
    // doc comment if you'd rather show this only on the very first
    // launch ever.
    @State private var showWelcome = true

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                ListenView(orchestrator: orchestrator)
                    .navigationTitle("SurroundSound")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                path.append(AppRoute.history)
                            } label: {
                                Image(systemName: "clock.arrow.circlepath")
                            }
                            .accessibilityLabel("View history")
                        }
                    }
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .history:
                            HistoryView()
                        }
                    }
            }
            .task {
                orchestrator.setModelContext(modelContext)
            }

            if showWelcome {
                WelcomeView {
                    withAnimation(.easeOut(duration: 0.4)) {
                        showWelcome = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [StudySession.self, SoundBlock.self], inMemory: true)
}
