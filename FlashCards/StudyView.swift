import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct StudyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allDecks: [Deck]
    @Query private var users: [User]

    @State var deck: Deck?
    var onClose: (() -> Void)? = nil
    @State private var cardsToStudy: [Card] = []
    @State private var currentCardIndex = 0
    @State private var isFlipped = false
    @State private var showHint = false
    @State private var showDeckPicker = false
    private let engine = MasteryEngine()
    // Track how long the learner takes to answer
    @State private var answerStartAt: Date? = nil
    // Session-level RT smoothing and timeout handling
    @State private var sessionRtEMA: Double = 0.0
    @State private var answerTimer: Timer? = nil
    @AppStorage("timeoutSeconds") private var timeoutSeconds: Double = 30.0
    @State private var hintUsed: Bool = false
    @State private var showEndSessionDialog: Bool = false

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
                                    let wasFlipped = isFlipped
                                    isFlipped.toggle()
                                    showHint = false
                                    if !wasFlipped && isFlipped {
                                        // Start timing when the answer side is revealed
                                        answerStartAt = Date()
                                        startAnswerTimer()
                                    }
                                    print("[StudyView] Tapped card. isFlipped=\(isFlipped)")
                                }
                            }

                        if let hint = card.hint, !hint.isEmpty, !isFlipped {
                            Button(action: {
                                showHint.toggle()
                                if showHint { hintUsed = true }
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
                        // Do not start timing yet; start when the card is flipped to see the answer
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
                Button(action: {
                    // If there are remaining cards, ask how to end session
                    if currentCard != nil {
                        showEndSessionDialog = true
                    } else {
                        forceDismiss(reason: "toolbar_close_no_remaining")
                    }
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
        .confirmationDialog(
            "End Session?",
            isPresented: $showEndSessionDialog,
            titleVisibility: .visible
        ) {
            Button("End & Postpone Remaining to Tomorrow") {
                postponeRemainingToTomorrow()
                forceDismiss(reason: "end_session_postpone_remaining")
            }
            Button("End Session Now") {
                forceDismiss(reason: "end_session_now")
            }
            Button("Cancel", role: .cancel) { showEndSessionDialog = false }
        } message: {
            Text("You have more cards left in this session. You can end now, or postpone the remaining cards until tomorrow.")
        }
        
    }

    private func markAnswer(correct: Bool) {
        guard let card = currentCard else {
            goToNextCard()
            return
        }
        let now = Date()
        // Compute elapsed response time
        let elapsed = max(0, now.timeIntervalSince(answerStartAt ?? now))
        // Update response-time stats before mapping the grade so thresholds adapt
        updateResponseStats(for: card, elapsed: elapsed)
        let grade = gradeFor(correct: correct, elapsed: elapsed, card: card, hintUsed: hintUsed)
        let state = SRSMapper.state(from: card)
        // Compute adaptive baseline (same as in grade mapping)
        let bootstrap: TimeInterval = 5.0
        let rc = card.responseCount ?? 0
        let ema = card.responseTimeEMA ?? 0
        let cardBaseline = (rc > 3 && ema > 0) ? ema : bootstrap
        let sessionBaseline = sessionRtEMA > 0 ? sessionRtEMA : bootstrap
        let baseline = max(1.0, 0.5 * cardBaseline + 0.5 * sessionBaseline)
        // Observed retrievability estimate from response time
        let rHat = max(0.001, min(0.999, exp(-elapsed / baseline)))
        let next = engine.nextState(from: state, grade: grade, now: now, observedRetrievability: rHat)
        SRSMapper.apply(next, to: card)
        print("[StudyView] Graded card id=\(card.id) correct=\(correct) elapsed=\(String(format: "%.2fs", elapsed)) mappedGrade=\(grade) -> intervalDays=\(next.intervalDays), ease=\(next.ease), stability=\(next.stability), nextReview=\(next.nextReview?.description ?? "nil")")
        stopAnswerTimer()
        goToNextCard()
    }

    private func goToNextCard() {
        withAnimation {
            currentCardIndex += 1
            isFlipped = false
            showHint = false
            hintUsed = false
            print("[StudyView] Advanced to next card. index=\(currentCardIndex)")
            answerStartAt = nil
            stopAnswerTimer()
        }
    }

    // Postpone all remaining cards until tomorrow (bury)
    private func postponeRemainingToTomorrow() {
        guard currentCardIndex < cardsToStudy.count else { return }
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: Date()).addingTimeInterval(86400)
        for idx in currentCardIndex..<cardsToStudy.count {
            let card = cardsToStudy[idx]
            card.buriedUntil = tomorrow
            card.updatedAt = Date()
        }
        print("[StudyView] Postponed \(cardsToStudy.count - currentCardIndex) remaining cards to tomorrow")
    }

    // Map binary + response time to a CardGrade using adaptive thresholds per card
    private func gradeFor(correct: Bool, elapsed: TimeInterval, card: Card, hintUsed: Bool) -> CardGrade {
        guard correct else { return .again }
        // Establish a baseline using EMA or a bootstrap default
        let bootstrap: TimeInterval = 5.0 // seconds, initial expected recall time
        let rc = card.responseCount ?? 0
        let ema = card.responseTimeEMA ?? 0
        let cardBaseline = (rc > 3 && ema > 0)
            ? ema
            : bootstrap
        let sessionBaseline = sessionRtEMA > 0 ? sessionRtEMA : bootstrap
        let baseline = max(1.0, 0.5 * cardBaseline + 0.5 * sessionBaseline)
        // Adaptive thresholds relative to baseline
        let easyFactor = max(0.2, min(1.0, readDoubleDefault("easyFactor", fallback: 0.5)))
        let goodFactor = max(0.6, min(3.0, readDoubleDefault("goodFactor", fallback: 1.25)))
        let easyThreshold = max(1.0, baseline * easyFactor)
        let goodThreshold = max(2.0, baseline * goodFactor)
        if elapsed <= easyThreshold { return hintUsed ? .good : .easy }
        if elapsed <= goodThreshold { return .good }
        return .hard
    }

    // Update response-time statistics on the card (running totals and EMA)
    private func updateResponseStats(for card: Card, elapsed: TimeInterval) {
        let alpha = max(0.01, min(0.99, readDoubleDefault("rtAlpha", fallback: 0.2))) // EMA smoothing
        card.lastResponseTime = elapsed
        let total = (card.totalResponseTime ?? 0) + elapsed
        card.totalResponseTime = total
        let count = (card.responseCount ?? 0) + 1
        card.responseCount = count
        let prevEMA = card.responseTimeEMA ?? 0
        card.responseTimeEMA = (count == 1) ? elapsed : (alpha * elapsed + (1 - alpha) * prevEMA)
        // Session-level EMA
        if sessionRtEMA == 0 {
            sessionRtEMA = elapsed
        } else {
            sessionRtEMA = alpha * elapsed + (1 - alpha) * sessionRtEMA
        }
        card.updatedAt = Date()

        // Update global user-level EMA if available
        if let user = users.first {
            let a = max(0.01, min(0.99, (user.rtAlpha ?? 0.2)))
            if (user.rtGlobalEMA ?? 0) == 0 {
                user.rtGlobalEMA = elapsed
            } else {
                let prev = user.rtGlobalEMA ?? elapsed
                user.rtGlobalEMA = a * elapsed + (1 - a) * prev
            }
            user.updatedAt = Date()
        }
    }

    // Timer management for timeout auto-incorrect
    private func startAnswerTimer() {
        stopAnswerTimer()
        guard isFlipped else { return }
        answerTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard isFlipped, let started = answerStartAt else { return }
            let elapsed = Date().timeIntervalSince(started)
            if elapsed >= timeoutSeconds {
                print("[StudyView] Timeout reached (\(timeoutSeconds)s). Auto-mark Incorrect.")
                markAnswer(correct: false)
            }
        }
        RunLoop.main.add(answerTimer!, forMode: .common)
    }

    private func stopAnswerTimer() {
        answerTimer?.invalidate()
        answerTimer = nil
    }

    // Read a Double from UserDefaults; if missing or zero, use fallback
    private func readDoubleDefault(_ key: String, fallback: Double) -> Double {
        if let val = UserDefaults.standard.object(forKey: key) as? Double, val != 0 {
            return val
        }
        return fallback
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
