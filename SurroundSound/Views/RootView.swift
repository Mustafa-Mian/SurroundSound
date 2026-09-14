//  RootView.swift

import SwiftUI
import SwiftData

// Places the app can navigate to beyond the live Listen screen.
enum AppRoute: Hashable {
    case history
    case help
}

// App entry point. Owns the orchestrator and navigation, and keeps
// the live "Listen" screen as the default.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var orchestrator = SoundOrchestrator()
    @State private var path = NavigationPath()

    // Shown once per app launch. Resets naturally on the next cold start.
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
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                path.append(AppRoute.help)
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                            .accessibilityLabel("View help")
                        }
                    }
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .history:
                            HistoryView()
                        case .help:
                            HelpView()
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
