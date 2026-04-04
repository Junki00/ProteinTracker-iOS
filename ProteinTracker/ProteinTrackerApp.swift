//
//  ProteinTrackerApp.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/19.
//

import SwiftData
import SwiftUI

@main
struct ProteinTrackerApp: App {
    private let sharedModelContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for: ProteinEntry.self, UserProfile.self)
            ProteinDataStore.ensureSeedData(in: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
