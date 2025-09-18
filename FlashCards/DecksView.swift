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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        seedEnglishDeck()
                    } label: {
                        Label("Add English Deck", systemImage: "text.book.closed")
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

    // MARK: - Seeding predefined English deck
    private func seedEnglishDeck() {
        let title = "English: Stronger Words and Basics"
        if let existing = decks.first(where: { $0.title == title }) {
            print("[DecksView] Deck already exists: \(existing.title). Skipping creation.")
            return
        }

        let deck = Deck(title: title, deckDescription: "Alternatives to 'very' and other basic English items")

        // Dataset: (question, answer, hint)
        let pairs: [(String,String,String?)] = englishSeedData()

        for (q, a, h) in pairs {
            let card = Card(question: q, answer: a, hint: h)
            deck.cards.append(card)
            modelContext.insert(card)
        }
        modelContext.insert(deck)
        print("[DecksView] Seeded deck '\(title)' with \(pairs.count) cards")
    }

    private func englishSeedData() -> [(String,String,String?)] {
        var items: [(String,String,String?)] = []
        func add(_ very: String, _ instead: String) {
            items.append(("Say instead of ‘very \(very)’:", instead.capitalized, "very \(very)"))
        }
        // Stronger words than 'very ...'
        add("angry", "furious")
        add("happy", "ecstatic")
        add("sad", "despondent")
        add("cold", "freezing")
        add("hot", "scorching")
        add("tired", "exhausted")
        add("hungry", "starving")
        add("small", "tiny")
        add("big", "enormous")
        add("fast", "rapid")
        add("slow", "sluggish")
        add("smart", "brilliant")
        add("stupid", "idiotic")
        add("good", "excellent")
        add("bad", "terrible")
        add("beautiful", "gorgeous")
        add("ugly", "hideous")
        add("clean", "spotless")
        add("dirty", "filthy")
        add("bright", "luminous")
        add("dark", "pitch-black")
        add("easy", "effortless")
        add("hard", "arduous")
        add("strong", "powerful")
        add("weak", "feeble")
        add("noisy", "deafening")
        add("quiet", "silent")
        add("rich", "wealthy")
        add("poor", "destitute")
        add("scared", "terrified")
        add("brave", "courageous")
        add("old", "ancient")
        add("young", "youthful")
        add("new", "brand-new")
        add("modern", "cutting-edge")
        add("early", "premature")
        add("late", "overdue")
        add("short", "brief")
        add("long", "lengthy")
        add("tall", "towering")
        add("thin", "slender")
        add("fat", "obese")
        add("interesting", "fascinating")
        add("boring", "tedious")
        add("funny", "hilarious")
        add("serious", "solemn")
        add("important", "crucial")
        add("unimportant", "trivial")
        add("necessary", "essential")
        add("unnecessary", "needless")
        add("simple", "straightforward")
        add("complicated", "complex")
        add("busy", "swamped")
        add("calm", "serene")
        add("rude", "obnoxious")
        add("polite", "courteous")
        add("kind", "compassionate")
        add("mean", "malicious")
        add("accurate", "precise")
        add("sharp", "razor-sharp")
        add("blunt", "dull")
        add("wet", "soaked")
        add("dry", "parched")
        add("windy", "blustery")
        add("rainy", "torrential")
        add("cloudy", "overcast")
        add("warm", "balmy")
        add("cool", "chilly")
        add("hot and humid", "sweltering")
        add("cold and windy", "bitter")
        add("sweet", "sugary")
        add("sour", "tart")
        add("salty", "briny")
        add("spicy", "fiery")
        add("bland", "tasteless")
        add("flavorful", "savory")
        add("expensive", "costly")
        add("cheap", "inexpensive")
        add("quick", "swift")
        add("careful", "meticulous")
        add("careless", "reckless")
        add("crowded", "packed")
        add("empty", "vacant")
        add("open", "spacious")
        add("closed", "sealed")
        add("loose", "slack")
        add("tight", "snug")

        // Basic English phrases and irregulars
        items.append(("Synonym of ‘start’:", "begin", nil))
        items.append(("Synonym of ‘help’:", "assist", nil))
        items.append(("Synonym of ‘make better’:", "improve", nil))
        items.append(("Opposite of ‘increase’:", "decrease", nil))
        items.append(("Opposite of ‘agree’:", "disagree", nil))
        items.append(("Irregular past of ‘go’:", "went", nil))
        items.append(("Irregular past of ‘see’:", "saw", nil))
        items.append(("Irregular past of ‘take’:", "took", nil))
        items.append(("Irregular past of ‘come’:", "came", nil))
        items.append(("Irregular past of ‘find’:", "found", nil))
        items.append(("Irregular past of ‘think’:", "thought", nil))
        items.append(("Irregular past of ‘give’:", "gave", nil))
        items.append(("Irregular past of ‘know’:", "knew", nil))
        items.append(("Irregular past of ‘get’:", "got", nil))
        items.append(("Irregular past of ‘eat’:", "ate", nil))
        items.append(("Irregular past of ‘drink’:", "drank", nil))
        items.append(("Irregular past of ‘write’:", "wrote", nil))
        items.append(("Irregular past of ‘read’:", "read", "pronounced ‘red’"))
        items.append(("Irregular past of ‘buy’:", "bought", nil))
        items.append(("Irregular past of ‘teach’:", "taught", nil))

        // Ensure ~100 cards by padding with collocations
        let collocations = [
            ("Make a decision", "decide", "Phrase → single word"),
            ("Do research", "research", "Verb form"),
            ("Give a hand", "help", "Idiom → verb"),
            ("Take a rest", "rest", nil),
            ("Keep in mind", "remember", nil),
            ("Catch a cold", "become ill", nil),
            ("Break the rules", "violate", nil),
            ("Look after", "care for", "Phrasal → verb"),
            ("Look forward to", "anticipate", nil),
            ("Put off", "postpone", nil),
            ("Set up", "establish", nil),
            ("Turn down", "reject", nil),
            ("Figure out", "discover", nil),
            ("Point out", "highlight", nil),
            ("Run out of", "exhaust", nil),
            ("Carry on", "continue", nil),
            ("Come across", "encounter", nil),
            ("Cut down on", "reduce", nil),
            ("Fill in", "complete", nil),
            ("Find out", "learn", nil)
        ]
        items.append(contentsOf: collocations)

        // Trim or pad to 100
        if items.count > 100 { items = Array(items.prefix(100)) }
        while items.count < 100 {
            items.append(("Common antonym of ‘hot’:", "cold", nil))
        }
        return items
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

#if DEBUG
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
#endif
