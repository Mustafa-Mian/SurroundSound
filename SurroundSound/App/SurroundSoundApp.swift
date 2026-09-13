//
//  SurroundSoundApp.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-08-27.
//

import SwiftUI
import SwiftData

@main
struct SurroundSoundApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [StudySession.self, SoundBlock.self, SoundEvent.self])
    }
}
