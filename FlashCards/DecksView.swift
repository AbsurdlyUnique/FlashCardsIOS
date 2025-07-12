import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct DecksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var decks: [Deck]
    @Query private var users: [User]
    @State private var isShowingAddDeck = false

    private var user: User? { users.first }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    if let user = user {
                        Text("Hello, \(user.firstName)!")
                            .font(.largeTitle).bold()
                            .foregroundColor(ColorPalette.blackOlive)
                    }
                    Text("Ready to study?")
                        .font(.headline)
                        .foregroundColor(ColorPalette.timberwolf)
                }
                .padding(.horizontal)

                if decks.isEmpty {
                    EmptyStateView(isShowingAddDeck: $isShowingAddDeck)
                } else {
                    ScrollView {
                        ForEach(decks) { deck in
                            NavigationLink(destination: DeckDetailView(deck: deck)) {
                                DeckCard(deck: deck)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingAddDeck = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingAddDeck) {
                AddDeckView()
            }
        }
    }
}

struct EmptyStateView: View {
    @Binding var isShowingAddDeck: Bool

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 80))
                .foregroundColor(ColorPalette.timberwolf.opacity(0.3))
            Text("Your First Deck")
                .font(.title).bold()
                .foregroundColor(ColorPalette.blackOlive)
            Text("Tap the '+' button to create your first flashcard deck and start your learning journey.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(ColorPalette.timberwolf)
                .padding(.horizontal, 40)
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DeckCard: View {
    let deck: Deck

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(deck.title)
                .font(.title2).bold()
                .foregroundColor(ColorPalette.blackOlive)
                .lineLimit(2)

            Spacer()

            HStack {
                Text("\(deck.cards.count) cards")
                    .font(.headline)
                    .foregroundColor(ColorPalette.timberwolf)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(ColorPalette.timberwolf.opacity(0.8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(ColorPalette.floralWhite)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ColorPalette.timberwolf.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Deck.self, User.self, configurations: config)

    // Add sample data for preview
    let sampleUser = User(firstName: "Julian")
    let sampleDeck = Deck(title: "SwiftUI Basics")
    container.mainContext.insert(sampleUser)
    container.mainContext.insert(sampleDeck)
    
    return DecksView()
        .modelContainer(container)
}
