import SwiftUI

@available(iOS 17.0, *)
struct SettingsView: View {
    @AppStorage("theme") private var theme = "light"
    @AppStorage("notifications") private var notificationsEnabled = true
    @AppStorage("cloudSyncEnabled") private var cloudSyncEnabled = false
    // Study algorithm tuning
    @AppStorage("timeoutSeconds") private var timeoutSeconds: Double = 30.0
    @AppStorage("rtAlpha") private var rtAlpha: Double = 0.2
    @AppStorage("easyFactor") private var easyFactor: Double = 0.5
    @AppStorage("goodFactor") private var goodFactor: Double = 1.25
    @Environment(\.openURL) private var openURL
    
    // TODO: Replace with your real App Store ID, e.g., "1234567890"
    private let appStoreID = "YOUR_APP_STORE_ID"
    
    var body: some View {
        NavigationStack {
            List {
                // Cloud
                Section {
                    Toggle("iCloud Sync (Optional)", isOn: $cloudSyncEnabled)
                        .tint(ColorPalette.flame)
                    Text("When enabled, your decks and study data may sync via your Apple ID using iCloud across your Apple devices.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Cloud")
                }

                // Study Settings
                Section {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                        .tint(ColorPalette.flame)
                    
                    NavigationLink {
                        Text("Notification Schedule")
                    } label: {
                        Label("Notification Schedule", systemImage: "clock.fill")
                    }
                } header: {
                    Text("Study Settings")
                }

                // Study Algorithm
                Section {
                    // Timeout (5s - 60s)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Answer Timeout", systemImage: "hourglass")
                            Spacer()
                            Text("\(Int(timeoutSeconds))s")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $timeoutSeconds, in: 5...60, step: 1)
                            .tint(ColorPalette.flame)
                        Text("Automatically mark Incorrect if no answer after this many seconds from reveal.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    // EMA alpha (0.05 - 0.5)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Response-Time EMA α", systemImage: "chart.line.uptrend.xyaxis")
                            Spacer()
                            Text(String(format: "%.2f", rtAlpha))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $rtAlpha, in: 0.05...0.5, step: 0.01)
                            .tint(ColorPalette.flame)
                        Text("Higher α reacts faster to recent speeds; lower α is smoother.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    // Easy/Good thresholds as factors of baseline
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Easy Threshold × baseline", systemImage: "bolt.fill")
                            Spacer()
                            Text(String(format: "%.2f×", easyFactor))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $easyFactor, in: 0.2...1.0, step: 0.05)
                            .tint(ColorPalette.flame)
                        Text("If answered faster than this fraction of your baseline, the grade can be Easy (unless a hint was used).")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Good Threshold × baseline", systemImage: "checkmark.seal.fill")
                            Spacer()
                            Text(String(format: "%.2f×", goodFactor))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $goodFactor, in: 0.6...3.0, step: 0.05)
                            .tint(ColorPalette.flame)
                        Text("If answered faster than this factor, the grade can be Good; otherwise Hard.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Study Algorithm")
                }
                
                // Data & Privacy
                Section {
                    NavigationLink {
                        Text("Backup & Restore")
                    } label: {
                        Label("Backup & Restore", systemImage: "icloud.fill")
                    }
                    
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Privacy Policy", systemImage: "lock.fill")
                    }
                } header: {
                    Text("Data & Privacy")
                }
                
                // Account
                Section {
                    NavigationLink {
                        AccountView()
                    } label: {
                        Label("Account", systemImage: "person.crop.circle")
                    }
                } header: {
                    Text("Account")
                }
                
                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                    }
                    
                    Button {
                        // Open App Store product page directly
                        let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id\(appStoreID)")
                        if let url = appStoreURL {
                            openURL(url)
                        } else if let httpsURL = URL(string: "https://apps.apple.com/app/id\(appStoreID)") {
                            // Fallback to HTTPS if needed
                            openURL(httpsURL)
                        }
                    } label: {
                        Label("Rate in App Store", systemImage: "star.fill")
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#if DEBUG
#Preview {
    SettingsView()
}
#endif

