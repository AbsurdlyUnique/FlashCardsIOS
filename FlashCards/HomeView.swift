import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Continue Studying Card
                NavigationLink {
                    StudyView()
                } label: {
                    CardView(
                        title: "Continue Studying",
                        subtitle: "Resume your last session",
                        icon: "brain.head.profile.fill"
                    )
                }
                
                // Featured Decks
                Text("Featured Decks")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.blackOlive)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<3) { index in
                            FeaturedDeckCard(
                                title: "Deck \(index + 1)",
                                cardsCount: 50,
                                progress: Double(index) / 3
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Quick Stats
                VStack(spacing: 16) {
                    Text("Quick Stats")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.blackOlive)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        StatCard(
                            value: "10",
                            label: "Cards Today",
                            icon: "list.bullet.rectangle.fill"
                        )
                        StatCard(
                            value: "5",
                            label: "Streak",
                            icon: "flame.fill"
                        )
                        StatCard(
                            value: "75%",
                            label: "Accuracy",
                            icon: "checkmark.circle.fill"
                        )
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(ColorPalette.floralWhite)
    }
}

struct CardView: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(ColorPalette.flame)
                Spacer()
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(ColorPalette.blackOlive)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(ColorPalette.timberwolf)
        }
        .padding()
        .background(ColorPalette.timberwolf.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: ColorPalette.eerieBlack.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct FeaturedDeckCard: View {
    let title: String
    let cardsCount: Int
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(ColorPalette.blackOlive)
            
            Text("\(cardsCount) cards")
                .font(.subheadline)
                .foregroundColor(ColorPalette.timberwolf)
            
            ProgressView(value: progress)
                .tint(ColorPalette.flame)
        }
        .padding()
        .background(ColorPalette.timberwolf.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: ColorPalette.eerieBlack.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(ColorPalette.flame)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.blackOlive)
            
            Text(label)
                .font(.caption)
                .foregroundColor(ColorPalette.timberwolf)
        }
        .frame(width: 100)
    }
}

#Preview {
    HomeView()
}
