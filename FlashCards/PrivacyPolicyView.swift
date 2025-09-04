import SwiftUI

@available(iOS 17.0, *)
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                HStack(spacing: 12) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(ColorPalette.flame)
                        .symbolRenderingMode(.hierarchical)
                    Text("Privacy Policy")
                        .font(.largeTitle).bold()
                }
                .padding(.top, 4)

                // Summary
                Group {
                    HStack(spacing: 10) {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(ColorPalette.flame)
                            .font(.title2)
                            .frame(width: 24, alignment: .leading)
                        Text("Summary")
                            .font(.title2).bold()
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• No external collection for analytics or ads.")
                        Text("• On-device processing by default.")
                        Text("• Optional iCloud sync (opt‑in) for multi‑device access.")
                    }
                    .foregroundStyle(.secondary)
                }

                // Data Processing
                Group {
                    HStack(spacing: 10) {
                        Image(systemName: "gearshape.2.fill")
                            .foregroundColor(ColorPalette.flame)
                            .font(.title2)
                            .frame(width: 24, alignment: .leading)
                        Text("How your data is processed")
                            .font(.title2).bold()
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• On-device calculation using the mastery engine.")
                        Text("• No server collection for analytics or ads.")
                        Text("• No third‑party tracking SDKs.")
                    }
                    .foregroundStyle(.secondary)
                }

                // What we store
                Group {
                    HStack(spacing: 10) {
                        Image(systemName: "internaldrive.fill")
                            .foregroundColor(ColorPalette.flame)
                            .font(.title2)
                            .frame(width: 24, alignment: .leading)
                        Text("What data is stored on your device")
                            .font(.title2).bold()
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Decks & Cards").font(.headline)
                            Text("• Deck titles and optional descriptions.\n• Card content (questions, answers, optional hints).")
                                .foregroundStyle(.secondary)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Study Metadata").font(.headline)
                            Text("• Review counters and lapses.\n• Scheduling (intervals, due dates).\n• Learning factors (ease, difficulty, stability).\n• Timestamps for last/next reviews.")
                                .foregroundStyle(.secondary)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("App Preferences").font(.headline)
                            Text("• Local settings like theme and notifications stored via iOS preferences.")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Deletion
                Group {
                    HStack(spacing: 10) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(ColorPalette.flame)
                            .font(.title2)
                            .frame(width: 24, alignment: .leading)
                        Text("How to delete your data")
                            .font(.title2).bold()
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("From this app").font(.headline)
                        Text("Open Settings → Account → Delete All Data. This removes your decks, cards, and profile stored by the app on this device.")
                            .foregroundStyle(.secondary)

                        Text("From iOS Settings").font(.headline)
                        Text("You can also delete app data by removing the app in iOS Settings. On reinstall, the app starts with a clean state.")
                            .foregroundStyle(.secondary)
                    }
                }

                // Connectivity & Sync
                Group {
                    HStack(spacing: 10) {
                        Image(systemName: "icloud")
                            .foregroundColor(ColorPalette.flame)
                            .font(.title2)
                            .frame(width: 24, alignment: .leading)
                        Text("Connectivity & Sync")
                            .font(.title2).bold()
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Optional iCloud Sync").font(.headline)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("• Off by default: The app keeps all data local unless you explicitly enable iCloud Sync in Settings → Cloud.")
                            Text("• What syncs: When enabled, your decks, cards, and study metadata may sync with your Apple ID using iCloud (CloudKit) so they’re available across your Apple devices.")
                            Text("• How it works: Sync is provided by Apple’s iCloud services. Data is transmitted to Apple’s servers for the purpose of syncing between your devices and is associated with your Apple ID.")
                        }
                        .foregroundStyle(.secondary)

                        Text("Control & Revocation").font(.headline)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("• Turning sync off: You can disable iCloud Sync anytime in Settings → Cloud. New changes will remain only on this device.")
                            Text("• Deleting iCloud data: You can delete app data from iCloud via iOS Settings → [your name] → iCloud → Manage Account Storage, or by removing the app from all devices. Availability of options may vary by iOS version.")
                        }
                        .foregroundStyle(.secondary)

                        Text("No Other Servers").font(.headline)
                        Text("Apart from optional iCloud sync, we do not send your data to any third-party servers for analytics, advertising, or profiling.")
                            .foregroundStyle(.secondary)
                    }
                }

                // Contact / Changes
                Group {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(ColorPalette.flame)
                            .font(.title2)
                            .frame(width: 24, alignment: .leading)
                        Text("Changes to this policy")
                            .font(.title2).bold()
                    }
                    Text("If we introduce new features (e.g., optional sync), we will clearly explain them here and require your consent where appropriate.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    NavigationStack { PrivacyPolicyView() }
}
#endif
