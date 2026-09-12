//
//  ContentView.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-08-27.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    // Persisted data
    @Query(sort: \SoundBlock.startedAt, order: .reverse) private var blocks: [SoundBlock]

    @Query private var items: [Item]

    // Orchestrator drives live state
    @StateObject private var orchestrator = SoundOrchestrator()

    // UI state
    @State private var showError = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationSplitView {
            content
        } detail: {
            detail
        }
        .task {
            orchestrator.setModelContext(modelContext)
        }
        .alert("Recording Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Primary Content
    private var content: some View {
        List {
            headerSection
            controlsSection
            if orchestrator.isRecording {
                liveNowSection
            }
            persistedBlocksSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("SurroundSound")
        .toolbar { toolbarContent }
    }

    private var detail: some View {
        VStack(spacing: 16) {
            Image(systemName: orchestrator.isRecording ? "waveform" : "waveform.slash")
                .font(.system(size: 48, weight: .semibold))
                .symbolEffect(
                    .variableColor.reversing,
                    options: orchestrator.isRecording ? .repeat(3) : .default
                )
                .foregroundStyle(orchestrator.isRecording ? .red : .secondary)
            Text(orchestrator.isRecording ? "Listening for sounds…" : "Select an item")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }

    // MARK: - Sections
    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome!")
                    .font(.title2).bold()
                Text("Let’s have a productive day.")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var controlsSection: some View {
        Section("Session") {
            HStack(spacing: 12) {
                Circle()
                    .fill(orchestrator.isRecording ? .red : .gray.opacity(0.4))
                    .frame(width: 12, height: 12)
                    .shadow(color: orchestrator.isRecording ? .red.opacity(0.6) : .clear, radius: 6)
                Text(orchestrator.isRecording ? "Session in progress" : "Session idle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: toggleRecording) {
                    Label(orchestrator.isRecording ? "Stop" : "Start", systemImage: orchestrator.isRecording ? "stop.circle.fill" : "record.circle")
                }
                .buttonStyle(.borderedProminent)
                .tint(orchestrator.isRecording ? .red : .accentColor)
            }
        }
    }

    private var liveNowSection: some View {
        Section("Live (recent)") {
            if orchestrator.recentBlocks.isEmpty {
                Text("Waiting for classifications…")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(orchestrator.recentBlocks.reversed(), id: \.id) { block in
                    SoundBlockRow(block: block)
                }
            }
        }
    }

    private var persistedBlocksSection: some View {
        Section("History") {
            if blocks.isEmpty {
                Text("No blocks yet. Start a session to begin collecting data.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(blocks) { block in
                    SoundBlockRow(block: block)
                }
                .onDelete(perform: deleteBlocks)
            }
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: addItem) {
                Label("Add Item", systemImage: "plus")
            }
            .help("Temporary sample action")
        }
    }

    // MARK: - Actions
    private func toggleRecording() {
        if orchestrator.isRecording {
            orchestrator.stop()
        } else {
            do {
                try orchestrator.start()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteBlocks(at offsets: IndexSet) {
        withAnimation {
            for index in offsets { modelContext.delete(blocks[index]) }
        }
    }
}

// MARK: - SoundBlockRow
private struct SoundBlockRow: View {
    let block: SoundBlock

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(block.label)
                    .font(.headline)
                Text(timeRange)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(confidenceString)
                    .monospacedDigit()
                    .font(.subheadline)
                Text(durationString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(block.label), \(durationString), confidence \(confidenceString)")
    }

    private var confidenceString: String {
        let pct = Int(round(block.averageConfidence * 100))
        return "\(pct)%"
    }

    private var durationString: String {
        let seconds = Int(block.duration.rounded())
        return "\(seconds)s"
    }

    private var timeRange: String {
        let df = DateFormatter()
        df.timeStyle = .short
        df.dateStyle = .none
        return "\(df.string(from: block.startedAt))–\(df.string(from: block.endedAt))"
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [StudySession.self, SoundBlock.self, Item.self], inMemory: true)
}
