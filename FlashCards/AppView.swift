import SwiftUI
import SwiftData
import UIKit

@available(iOS 17.0, *)
struct AppView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            DecksView()
                .tabItem {
                    Label("Decks", systemImage: "book.fill")
                }
                .tag(1)
            
            StudyView()
                .tabItem {
                    Label("Study", systemImage: "brain.head.profile")
                }
                .tag(2)
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(ColorPalette.flame)
        .onChange(of: selectedTab) { _ in
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}

#Preview {
    AppView()
}
