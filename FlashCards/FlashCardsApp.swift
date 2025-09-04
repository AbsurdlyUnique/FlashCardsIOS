//
//  FlashCardsApp.swift
//  FlashCards
//
//  Created by Julian Richter on 7/12/25.
//

import SwiftUI
import SwiftData

@available(iOS 17.0, *)
@main
struct FlashCardsApp: App {
    @AppStorage("isOnboarding") private var isOnboarding: Bool = true
    @AppStorage("cloudSyncEnabled") private var cloudSyncEnabled: Bool = false
    // Optional: Configure a specific iCloud container in Xcode > Signing & Capabilities.
    // SwiftData can automatically use the default container when CloudKit is enabled.

    var sharedModelContainer: ModelContainer

    init() {
        let schema = Schema([
            Deck.self,
            Card.self,
            User.self
        ])

        do {
            // Avoid using @AppStorage in init before all stored properties are initialized
            let cloudEnabled = UserDefaults.standard.bool(forKey: "cloudSyncEnabled")
            if cloudEnabled {
                // Enable CloudKit using the default iCloud container (configured in Signing & Capabilities)
                let configuration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .automatic
                )
                self.sharedModelContainer = try ModelContainer(for: schema, configurations: [configuration])
            } else {
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                self.sharedModelContainer = try ModelContainer(for: schema, configurations: [configuration])
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                OnboardingView(isOnboarding: $isOnboarding)
            } else {
                AppView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
