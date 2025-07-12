import SwiftUI
import SwiftData

struct StudyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Deck.title) private var allDecks: [Deck]

    @State var deck: Deck?
    @State private var cardsToStudy: [Card] = []
    @State private var currentCardIndex = 0
    @State private var isFlipped = false
    @State private var showHint = false

    init(deck: Deck? = nil) {
        _deck = State(initialValue: deck)
    }

    private var currentCard: Card? {
        guard let currentDeck = deck, currentCardIndex < cardsToStudy.count else { return nil }
        return cardsToStudy[currentCardIndex]
    }

    private var progress: Double {
        guard let currentDeck = deck, !cardsToStudy.isEmpty else { return 1.0 }
        return Double(currentCardIndex) / Double(cardsToStudy.count)
    }

    var body: some View {
        NavigationStack {
            if let currentDeck = deck {
                VStack {
                    if let card = currentCard {
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: ColorPalette.flame))
                            .padding(.vertical)

                        Spacer()

                        FlashcardView(card: card, isFlipped: $isFlipped)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    isFlipped.toggle()
                                    showHint = false
                                }
                            }

                        if let hint = card.hint, !hint.isEmpty, !isFlipped {
                            Button(action: { showHint.toggle() }) {
                                Label("Show Hint", systemImage: "lightbulb.fill")
                            }
                            .padding(.top)
                            .foregroundColor(ColorPalette.flame)

                            if showHint {
                                Text(hint)
                                    .padding()
                                    .background(ColorPalette.timberwolf.opacity(0.2))
                                    .cornerRadius(10)
                                    .transition(.opacity.animation(.easeInOut))
                            }
                        }

                        Spacer()

                        if isFlipped {
                            HStack(spacing: 20) {
                                Button(action: { markAnswer(correct: false) }) {
                                    Label("Incorrect", systemImage: "xmark")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(Color.red)
                                        .cornerRadius(12)
                                }

                                Button(action: { markAnswer(correct: true) }) {
                                    Label("Correct", systemImage: "checkmark")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(Color.green)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                            .transition(.opacity.animation(.easeInOut))
                        }
                    } else {
                        StudyCompletionView(onDismiss: { dismiss() })
                    }
                }
                .padding()
                .background(Color.white.edgesIgnoringSafeArea(.all))
                .navigationTitle(currentDeck.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .onAppear {
                    if let currentDeck = deck {
                        let dueCards = currentDeck.cards.filter { $0.nextReview == nil || ($0.nextReview ?? .distantPast) <= Date() }
                        cardsToStudy = (dueCards.isEmpty ? currentDeck.cards : dueCards).shuffled()
                    }
                }
            } else {
                // Deck Selection View
                VStack {
                    Text("Select a Deck to Study")
                        .font(.title2).bold()
                        .padding()
                    List {
                        ForEach(allDecks) { availableDeck in
                            Button(action: { deck = availableDeck }) {
                                Text(availableDeck.title)
                            }
                        }
                    }
                }
                .navigationTitle("Study")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        
    }

    private func markAnswer(correct: Bool) {
        guard let card = currentCard else {
            goToNextCard()
            return
        }
        let now = Date()
        let quality = correct ? 5 : 2 // Simplified quality score
        let minEase: Double = 1.3

        // Update ease factor (SM-2 formula)
        var ef = card.easeFactor
        ef = ef + (0.1 - (5.0 - Double(quality)) * (0.08 + (5.0 - Double(quality)) * 0.02))
        card.easeFactor = max(minEase, ef)

        if correct {
            card.reviewCount += 1
            if card.reviewCount == 1 {
                card.interval = 1
            } else if card.reviewCount == 2 {
                card.interval = 6
            } else {
                card.interval = (card.interval * card.easeFactor).rounded()
            }
        } else {
            // Reset on incorrect answer
            card.reviewCount = 0
            card.interval = 1
        }

        card.lastReviewed = now
        card.nextReview = Calendar.current.date(byAdding: .day, value: Int(card.interval), to: now)
        card.updatedAt = now

        // SwiftData will track these changes automatically
        goToNextCard()
    }

    private func goToNextCard() {
        withAnimation {
            currentCardIndex += 1
            isFlipped = false
            showHint = false
        }
    }
}

struct StudyCompletionView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            Text("Session Complete!")
                .font(.largeTitle).bold()
            Text("You've reviewed all the cards in this deck.")
                .font(.headline)
                .foregroundColor(ColorPalette.timberwolf)
            Button(action: onDismiss) {
                Text("Back to Deck")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(ColorPalette.flame)
                    .cornerRadius(12)
            }
            .padding(.top)
        }
    }
}
