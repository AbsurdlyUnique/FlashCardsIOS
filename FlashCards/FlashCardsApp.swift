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

        // Avoid using @AppStorage in init before all stored properties are initialized
        let cloudEnabled = UserDefaults.standard.bool(forKey: "cloudSyncEnabled")
        if cloudEnabled {
            do {
                // Try CloudKit configuration first
                let configuration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .automatic
                )
                self.sharedModelContainer = try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                // Fallback to local store to avoid crash when iCloud is not available/misconfigured
                #if DEBUG
                print("[FlashCardsApp] CloudKit ModelContainer init failed: \(error). Falling back to local store.")
                #endif
                do {
                    let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                    self.sharedModelContainer = try ModelContainer(for: schema, configurations: [localConfig])
                } catch {
                    fatalError("Could not create local ModelContainer after CloudKit failure: \(error)")
                }
            }
        } else {
            do {
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                self.sharedModelContainer = try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                #if DEBUG
                print("[FlashCardsApp] Local ModelContainer init failed: \(error). Falling back to in-memory store.")
                #endif
                do {
                    let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                    self.sharedModelContainer = try ModelContainer(for: schema, configurations: [memoryConfig])
                } catch {
                    fatalError("Could not create in-memory ModelContainer: \(error)")
                }
            }
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
