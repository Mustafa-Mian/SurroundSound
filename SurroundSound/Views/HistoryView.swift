//  HistoryView.swift

import SwiftUI
import SwiftData

// Past sessions display.
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StudySession.startedAt, order: .reverse) private var sessions: [StudySession]

    var body: some View {
        Group {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock",
                    description: Text("Completed Study Sessions will show up here. Let's get to work!")
                )
            } else {
                List {
                    ForEach(sessions) { session in
                        NavigationLink(destination: StudySessionDetailView(session: session)) {
                            StudySessionRow(session: session)
                        }
                    }
                    .onDelete(perform: deleteSessions)
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !sessions.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    private func deleteSessions(at offsets: IndexSet) {
        withAnimation {
            for index in offsets { modelContext.delete(sessions[index]) }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(for: [StudySession.self, SoundBlock.self], inMemory: true)
}
