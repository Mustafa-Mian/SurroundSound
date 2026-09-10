//
//  PersistenceController.swift
//  SurroundSound
//
//  Created by Mustafa Mian on 2026-09-08.
//


import SwiftData

enum PersistenceController {
    static let shared: ModelContainer = {
        let schema = Schema([StudySession.self, SoundEvent.self])
        let configuration = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
