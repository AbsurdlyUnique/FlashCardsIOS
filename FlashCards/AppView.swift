import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

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
            
            StudyTabContainer(onCloseToDecks: {
                print("[AppView] onClose from StudyView in Study tab; switching to Decks tab")
                selectedTab = 1
            })
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
            #if canImport(UIKit)
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
            #endif
        }
    }
}

#Preview {
    AppView()
}

// MARK: - Study Tab Container that always presents StudyView full-screen
private struct StudyTabContainer: View {
    @State private var showCover = false
    var onCloseToDecks: () -> Void

    var body: some View {
        Color.clear
            .ignoresSafeArea()
            .onAppear {
                if !showCover {
                    print("[StudyTabContainer] onAppear -> presenting StudyView full-screen")
                    showCover = true
                }
            }
            .fullScreenCover(isPresented: $showCover) {
                StudyView(onClose: {
                    print("[StudyTabContainer] onClose received from StudyView")
                    showCover = false
                    onCloseToDecks()
                })
            }
    }
}
