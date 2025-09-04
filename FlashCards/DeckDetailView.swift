import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct DeckDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State var deck: Deck
    @State private var isShowingAddCard = false
    @State private var isShowingStudyView = false

    var body: some View {
        VStack {
            if deck.cards.isEmpty {
                CardEmptyStateView(isShowingAddCard: $isShowingAddCard)
            } else {
                VStack {
                    Button(action: {
                        print("[DeckDetailView] Study Deck tapped for deck: \(deck.title)")
                        isShowingStudyView = true
                    }) {
                        Label("Study Deck", systemImage: "book.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ColorPalette.flame)
                    .controlSize(.large)
                    .buttonBorderShape(.roundedRectangle(radius: 14))
                    .padding([.horizontal, .top], 14)
                    .disabled(deck.cards.isEmpty)
                    
                    List {
                        ForEach(deck.cards.indices, id: \.self) { index in
                            CardRow(card: deck.cards[index])
                        }
                        .onDelete(perform: deleteCards)
                    }
                }
            }
        }
        .navigationTitle(deck.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isShowingAddCard = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddCard) {
            AddCardView(deck: deck, onClose: { isShowingAddCard = false })
        }
        .fullScreenCover(isPresented: $isShowingStudyView) {
            StudyView(deck: deck, onClose: {
                print("[DeckDetailView] onClose from StudyView received; dismissing cover")
                isShowingStudyView = false
            })
        }
        .onChange(of: isShowingStudyView) { newValue in
            print("[DeckDetailView] isShowingStudyView changed: \(newValue)")
        }
    }

    private func deleteCards(at offsets: IndexSet) {
        let cardsToDelete = offsets.map { deck.cards[$0] }
        for card in cardsToDelete {
            modelContext.delete(card)
        }
        deck.cards.remove(atOffsets: offsets)
    }
}

@available(iOS 17.0, *)
private struct CardEmptyStateView: View {
    @Binding var isShowingAddCard: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up.slash.fill")
                .font(.system(size: 60))
                .foregroundStyle(ColorPalette.flame)
            Text("No Cards Yet")
                .font(.title).bold()
                .foregroundStyle(.primary)
            Text("Tap the '+' button to add your first card to this deck.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            Button(action: { isShowingAddCard = true }) {
                Label("Add First Card", systemImage: "plus")
                    .font(.headline)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(ColorPalette.flame)
            .controlSize(.large)
            .buttonBorderShape(.roundedRectangle(radius: 14))
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

@available(iOS 17.0, *)
private struct CardRow: View {
    let card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.question)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(card.answer)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let hint = card.hint, !hint.isEmpty {
                Text("Hint: \(hint)")
                    .font(.footnote)
                    .italic()
                    .foregroundStyle(.secondary)
            }

            // Inline stats rows
            VStack(alignment: .leading, spacing: 6) {
                statRow(icon: "calendar.badge.clock", title: "Due", value: nextReviewText(card))
                statRow(icon: "clock", title: "Interval", value: intervalText(card))
                statRow(icon: "arrow.uturn.backward", title: "Lapses", value: "\(card.lapses)")
                statRow(icon: "speedometer", title: "Ease", value: String(format: "%.2fx", card.easeFactor))
                statRow(icon: "shield", title: "Stability", value: String(format: "%.2f", card.stability))
                statRow(icon: "brain.head.profile", title: "Difficulty", value: String(format: "%.2f", card.difficulty))
                if let last = card.lastReviewed {
                    statRow(icon: "calendar", title: "Last", value: relativeText(from: last))
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }

    private var relativeFormatter: RelativeDateTimeFormatter {
        let rf = RelativeDateTimeFormatter()
        rf.unitsStyle = .full
        return rf
    }

    private func nextReviewText(_ card: Card) -> String {
        guard let due = card.nextReview else { return "today" }
        if Calendar.current.isDateInToday(due) { return "today" }
        if Calendar.current.isDateInTomorrow(due) { return "tomorrow" }
        // Relative for future/past
        return relativeText(from: due)
    }

    private func intervalText(_ card: Card) -> String {
        let days = card.interval
        if days <= 0 { return "—" }
        return days == 1 ? "1 day" : "\(Int(days)) days"
    }

    @ViewBuilder
    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(ColorPalette.flame)
            Text("\(title):")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.footnote)
        }
    }

    private func relativeText(from date: Date) -> String {
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
}

#if DEBUG
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Deck.self, configurations: config)
    let sampleDeck = Deck(title: "Sample Deck")
    // To preview the empty state, comment out the next line
    // sampleDeck.cards = [Card(question: "Test Q", answer: "Test A")]
    let anotherCard = Card(question: "What is the capital of France?", answer: "Paris", hint: "It's a famous European city.")
    sampleDeck.cards.append(anotherCard)
    
    return NavigationStack {
        DeckDetailView(deck: sampleDeck)
            .modelContainer(container)
    }
}
#endif
