import SwiftUI

struct HomeView: View {
    @State private var isShowingStudy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Continue Studying - Hero Card
                Button(action: {
                    print("[HomeView] Continue Studying tapped")
                    isShowingStudy = true
                }) {
                    ContinueCard()
                }
                .buttonStyle(.plain)

                // Featured Decks
                SectionHeader(title: "Featured Decks", icon: "star.fill")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<6) { index in
                            FeaturedDeckCard(
                                title: "Deck \(index + 1)",
                                cardsCount: Int.random(in: 20...120),
                                progress: Double(index % 4) / 4
                            )
                            .frame(width: 260)
                        }
                    }
                    .padding(.vertical, 2)
                }

                // Quick Stats
                SectionHeader(title: "Quick Stats", icon: "gauge.with.dots.needle.67percent")

                AdaptiveStatsGrid()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .fullScreenCover(isPresented: $isShowingStudy) {
            StudyView(onClose: {
                print("[HomeView] onClose from StudyView received; dismissing cover")
                isShowingStudy = false
            })
        }
        .onChange(of: isShowingStudy) { newValue in
            print("[HomeView] isShowingStudy changed: \(newValue)")
        }
    }
}

private extension Color {
    static var cardBackground: Color { Color.secondary.opacity(0.08) }
    static var cardBorder: Color { Color.secondary.opacity(0.32) }
}

struct ContinueCard: View {
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 48, height: 48)
                Image(systemName: "brain.head.profile.fill")
                    .font(.title2)
                    .foregroundColor(ColorPalette.flame)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Continue Studying")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Resume your last session")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(.secondary)
                .opacity(0.8)
        }
        .padding(16)
        .background(.regularMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.18), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

struct FeaturedDeckCard: View {
    let title: String
    let cardsCount: Int
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.stack.fill")
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(cardsCount) cards")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ProgressView(value: progress)
                .tint(ColorPalette.flame)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(ColorPalette.flame)
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.title2).bold()
                .foregroundStyle(.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct AdaptiveStatsGrid: View {
    let items: [(String, String, String)] = [
        ("10", "Cards Today", "list.bullet.rectangle.fill"),
        ("5", "Streak", "flame.fill"),
        ("75%", "Accuracy", "checkmark.circle.fill"),
        ("120", "Total Cards", "square.stack.3d.up.fill")
    ]
    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(items, id: \.1) { value, label, icon in
                StatCard(value: value, label: label, icon: icon)
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2).bold()
                .foregroundStyle(.primary)
        }
        .padding(.top, 4)
    }
}

#Preview {
    HomeView()
}
