import SwiftUI
import SwiftData

struct StudyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Deck.title) private var allDecks: [Deck]

    @State var deck: Deck?
    var onClose: (() -> Void)? = nil
    @State private var cardsToStudy: [Card] = []
    @State private var currentCardIndex = 0
    @State private var isFlipped = false
    @State private var showHint = false
    @State private var showDeckPicker = false

    init(deck: Deck? = nil, onClose: (() -> Void)? = nil) {
        _deck = State(initialValue: deck)
        self.onClose = onClose
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
                            .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                            .padding(.vertical)

                        Spacer()

                        FlashcardView(card: card, isFlipped: $isFlipped)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    isFlipped.toggle()
                                    showHint = false
                                    print("[StudyView] Tapped card. isFlipped=\(isFlipped)")
                                }
                            }

                        if let hint = card.hint, !hint.isEmpty, !isFlipped {
                            Button(action: {
                                showHint.toggle()
                                print("[StudyView] Toggled hint. showHint=\(showHint)")
                            }) {
                                Label("Show Hint", systemImage: "lightbulb.fill")
                            }
                            .padding(.top)
                            .foregroundColor(.accentColor)

                            if showHint {
                                Text(hint)
                                    .padding()
                                    .background(Color.secondary.opacity(0.15))
                                    .cornerRadius(10)
                                    .transition(.opacity.animation(.easeInOut))
                            }
                        }

                        Spacer()

                        if isFlipped {
                            HStack(spacing: 20) {
                                Button(action: {
                                    print("[StudyView] Mark incorrect tapped at index \(currentCardIndex)")
                                    markAnswer(correct: false)
                                }) {
                                    Label("Incorrect", systemImage: "xmark")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(Color.red)
                                        .cornerRadius(12)
                                }

                                Button(action: {
                                    print("[StudyView] Mark correct tapped at index \(currentCardIndex)")
                                    markAnswer(correct: true)
                                }) {
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
                        StudyCompletionView(onDismiss: { forceDismiss(reason: "completion_back_to_deck") })
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .navigationTitle(currentDeck.title)
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    print("[StudyView] onAppear. deck title=\(deck?.title ?? "nil")")
                    if let currentDeck = deck {
                        let dueCards = currentDeck.cards.filter { $0.nextReview == nil || ($0.nextReview ?? .distantPast) <= Date() }
                        cardsToStudy = (dueCards.isEmpty ? currentDeck.cards : dueCards).shuffled()
                        print("[StudyView] Loaded \(cardsToStudy.count) cards to study")
                    }
                }
                .onDisappear { print("[StudyView] onDisappear") }
            } else {
                // Beautiful Empty State
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.accentColor.opacity(0.25), Color.accentColor.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 140, height: 140)
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 54, weight: .semibold))
                            .foregroundStyle(.primary)
                            .opacity(0.9)
                    }
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)

                    VStack(spacing: 6) {
                        Text("Ready to Study")
                            .font(.title2).bold()
                            .foregroundStyle(.primary)
                        Text("Pick a deck and we’ll get you started.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)

                    Button {
                        showDeckPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.stack")
                            Text("Choose a Deck")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .padding(.horizontal, 32)

                    if allDecks.isEmpty {
                        Text("No decks yet. Create one in the Decks tab to begin.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
                .ignoresSafeArea()
                .navigationTitle("Study")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showDeckPicker) {
                    NavigationStack {
                        List {
                            if allDecks.isEmpty {
                                Section {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("No Decks Available")
                                            .font(.headline)
                                        Text("Create a deck in the Decks tab, then come back to start studying.")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 8)
                                }
                            } else {
                                ForEach(allDecks) { availableDeck in
                                    Button(action: {
                                        print("[StudyView] Deck selected from picker: \(availableDeck.title)")
                                        deck = availableDeck
                                        showDeckPicker = false
                                    }) {
                                        HStack {
                                            Image(systemName: "rectangle.stack.fill")
                                            .foregroundStyle(.secondary)
                                            Text(availableDeck.title)
                                            .foregroundStyle(.primary)
                                        }
                                    }
                                }
                            }
                        }
                        .navigationTitle("Choose Deck")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") { showDeckPicker = false; print("[StudyView] Dismissed deck picker") }
                            }
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { forceDismiss(reason: "toolbar_close") }) {
                    Image(systemName: "xmark")
                }
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
            print("[StudyView] Advanced to next card. index=\(currentCardIndex)")
        }
    }

    private func forceDismiss(reason: String) {
        print("[StudyView] forceDismiss called. reason=\(reason)")
        dismiss()
        DispatchQueue.main.async {
            if onClose != nil { print("[StudyView] invoking onClose callback") }
            onClose?()
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
                .foregroundStyle(.secondary)
            Button(action: onDismiss) {
                Text("Back to Deck")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.top)
        }
    }
}
