import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct DecksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var decks: [Deck]
    @Query private var users: [User]
    @State private var isShowingAddDeck = false
    @State private var deckToDelete: Deck?
    @State private var isConfirmingDelete = false

    private var user: User? { users.first }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    if let user = user {
                        Text("Hello, \(user.firstName)!")
                            .font(.largeTitle).bold()
                            .foregroundStyle(.primary)
                    }
                    Text("Ready to study?")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                if decks.isEmpty {
                    EmptyStateView(isShowingAddDeck: $isShowingAddDeck)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(decks) { deck in
                                NavigationLink(destination: DeckDetailView(deck: deck)) {
                                    DeckCard(deck: deck)
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deckToDelete = deck
                                        isConfirmingDelete = true
                                    } label: {
                                        Label("Delete Deck", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingAddDeck = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddDeck) { AddDeckView() }
            .confirmationDialog(
                "Delete deck?",
                isPresented: $isConfirmingDelete,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let deck = deckToDelete { deleteDeck(deck) }
                }
                Button("Cancel", role: .cancel) { deckToDelete = nil }
            } message: {
                Text(deckToDelete != nil ? "This will remove \(deckToDelete!.title) and its cards." : "")
            }
        }
    }

    private func deleteDeck(_ deck: Deck) {
        withAnimation {
            // Delete child cards first to avoid relationship inconsistencies
            for card in deck.cards {
                modelContext.delete(card)
            }
            modelContext.delete(deck)
            // Reset dialog state
            deckToDelete = nil
            isConfirmingDelete = false
        }
    }
}

@available(iOS 17.0, *)
struct EmptyStateView: View {
    @Binding var isShowingAddDeck: Bool

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 80))
                .foregroundStyle(ColorPalette.flame)
                .opacity(0.85)
            Text("Your First Deck")
                .font(.title).bold()
                .foregroundStyle(.primary)
            Text("Tap the '+' button to create your first flashcard deck and start your learning journey.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
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
                .foregroundStyle(.primary)
                .lineLimit(2)

            Spacer()

            HStack {
                Text("\(deck.cards.count) cards")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .opacity(0.8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
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
