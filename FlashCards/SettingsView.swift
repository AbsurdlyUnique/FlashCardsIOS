import SwiftUI

@available(iOS 17.0, *)
struct SettingsView: View {
    @AppStorage("theme") private var theme = "light"
    @AppStorage("notifications") private var notificationsEnabled = true
    @Environment(\.openURL) private var openURL
    
    // TODO: Replace with your real App Store ID, e.g., "1234567890"
    private let appStoreID = "YOUR_APP_STORE_ID"
    
    var body: some View {
        NavigationStack {
            List {
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
                
                // Data & Privacy
                Section {
                    NavigationLink {
                        Text("Backup & Restore")
                    } label: {
                        Label("Backup & Restore", systemImage: "icloud.fill")
                    }
                    
                    NavigationLink {
                        Text("Privacy Policy")
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

#Preview {
    SettingsView()
}

