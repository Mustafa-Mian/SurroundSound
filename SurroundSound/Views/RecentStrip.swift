//
//  RecentStrip.swift
//  SurroundSound
//

import SwiftUI

// A horizontally-scrolling strip of the last few classifications
// during an active session.
struct RecentStrip: View {
    let blocks: [SoundBlock]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Just now")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(blocks.suffix(5).reversed(), id: \.id) { block in
                        Text(block.label)
                            .font(.caption)
                            .lineLimit(1)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    // Populate with real SoundBlock instances once you're viewing this
    // in your project — the initializer isn't visible from here.
    RecentStrip(blocks: [])
        .padding()
}
