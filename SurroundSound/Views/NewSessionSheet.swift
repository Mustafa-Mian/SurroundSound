//
//  NewSessionSheet.swift
//
//  Shown before a session starts so the user can optionally name it.
//

import SwiftUI

struct NewSessionSheet: View {
    @Binding var name: String
    var onStart: () -> Void

    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(.secondary)
                Spacer()
            }

            VStack(spacing: 6) {
                Image(systemName: "waveform.badge.plus")
                    .font(.system(size: 34))
                    .foregroundStyle(Color.accentColor)
                Text("Name this session")
                    .font(.headline)
                Text("Optional. Helps you find it later in History.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            TextField("e.g. Algorithms Exam", text: $name)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .submitLabel(.go)
                .onSubmit(start)

            Button(action: start) {
                Text("Start Listening")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)

            Spacer(minLength: 0)
        }
        .padding()
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
        .onAppear { isFocused = true }
    }

    private func start() {
        onStart()
        dismiss()
    }
}

#Preview {
    NewSessionSheet(name: .constant(""), onStart: {})
}
