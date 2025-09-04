import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct StudyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allDecks: [Deck]

    @State var deck: Deck?
    var onClose: (() -> Void)? = nil
    @State private var cardsToStudy: [Card] = []
    @State private var currentCardIndex = 0
    @State private var isFlipped = false
    @State private var showHint = false
    @State private var showDeckPicker = false
    private let engine = MasteryEngine()

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
                            .progressViewStyle(LinearProgressViewStyle(tint: ColorPalette.flame))
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
                            .foregroundColor(ColorPalette.flame)

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
                        let now = Date()
                        let dueCards = currentDeck.cards.filter { card in
                            let state = SRSMapper.state(from: card)
                            return engine.isDue(state, at: now)
                        }
                        cardsToStudy = (dueCards.isEmpty ? currentDeck.cards : dueCards).shuffled()
                        print("[StudyView] Loaded \(cardsToStudy.count) cards to study")
                    } else if allDecks.isEmpty {
                        // No decks exist, route user to Decks tab via AppView onClose callback
                        print("[StudyView] No decks exist; dismissing to Decks tab")
                        forceDismiss(reason: "no_decks")
                    }
                }
                .onDisappear { print("[StudyView] onDisappear") }
            } else {
                // Beautiful Empty State
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [ColorPalette.flame.opacity(0.25), ColorPalette.flame.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing))
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
                        if allDecks.isEmpty {
                            // Route to Decks tab
                            forceDismiss(reason: "empty_decks_create")
                        } else {
                            showDeckPicker = true
                        }
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
                    .tint(ColorPalette.flame)
                    .padding(.horizontal, 32)

                    if allDecks.isEmpty {
                        VStack(spacing: 10) {
                            Text("No decks yet. Create one in the Decks tab to begin.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Button {
                                forceDismiss(reason: "cta_create_deck")
                            } label: {
                                Text("Create a Deck")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(ColorPalette.flame)
                            .padding(.horizontal, 32)
                        }
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
        let grade: CardGrade = correct ? .good : .again
        let state = SRSMapper.state(from: card)
        let next = engine.nextState(from: state, grade: grade, now: now)
        SRSMapper.apply(next, to: card)
        print("[StudyView] Graded card id=\(card.id) grade=\(grade.rawValue) -> intervalDays=\(next.intervalDays), ease=\(next.ease), stability=\(next.stability), nextReview=\(next.nextReview?.description ?? "nil")")
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
                    .background(ColorPalette.flame)
                    .cornerRadius(12)
            }
            .padding(.top)
        }
    }
}
