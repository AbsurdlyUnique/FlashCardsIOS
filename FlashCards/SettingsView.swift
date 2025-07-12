import SwiftUI

@available(iOS 17.0, *)
struct SettingsView: View {
    @AppStorage("theme") private var theme = "light"
    @AppStorage("notifications") private var notificationsEnabled = true
    
    var body: some View {
        NavigationStack {
            List {
                // Appearance
                Section {
                    Picker("Theme", selection: $theme) {
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .tint(ColorPalette.flame)
                    
                    Toggle("Dynamic Type", isOn: .constant(true))
                        .tint(ColorPalette.flame)
                } header: {
                    Text("Appearance")
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
                
                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                    }
                    
                    NavigationLink {
                        Text("Rate in App Store")
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
