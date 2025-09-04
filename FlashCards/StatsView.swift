import SwiftUI
import Charts
import SwiftData

@available(iOS 17.0, *)
public struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var decks: [Deck]
    @Query private var cards: [Card]

    // Date label formatter (e.g., Thu 5)
    private static let weekdayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("EEE d")
        return df
    }()

    // MARK: - Helper model for chart data
    struct ForecastData: Identifiable {
        let id = UUID()
        let date: Date
        let label: String
        let dueCount: Int
    }

    // MARK: - Derived metrics
    private var today: Date { Calendar.current.startOfDay(for: Date()) }

    private var dueTodayCount: Int {
        let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return cards.filter { card in
            guard !card.suspended else { return false }
            if let buried = card.buriedUntil, buried > Date() { return false }
            guard let due = card.nextReview else { return true }
            return due < endOfToday
        }.count
    }

    private var newCount: Int {
        cards.filter { $0.reviewCount == 0 }.count
    }

    private var matureCount: Int {
        cards.filter { $0.interval >= 21 }.count
    }

    private var lapsesTotal: Int {
        cards.map { $0.lapses }.reduce(0, +)
    }

    private var avgEase: Double? {
        guard !cards.isEmpty else { return nil }
        return cards.map { $0.easeFactor }.reduce(0, +) / Double(cards.count)
    }

    private var avgStability: Double? {
        guard !cards.isEmpty else { return nil }
        return cards.map { $0.stability }.reduce(0, +) / Double(cards.count)
    }

    private var avgDifficulty: Double? {
        guard !cards.isEmpty else { return nil }
        return cards.map { $0.difficulty }.reduce(0, +) / Double(cards.count)
    }

    // Next 7-day due forecast based on nextReview
    private var forecast7Days: [ForecastData] {
        let cal = Calendar.current
        return (0..<7).map { offset in
            let d = cal.date(byAdding: .day, value: offset, to: today)!
            let start = d
            let end = cal.date(byAdding: .day, value: 1, to: d)!
            let count = cards.filter { c in
                guard !c.suspended else { return false }
                if let buried = c.buriedUntil, buried > end { return false }
                guard let due = c.nextReview else { return offset == 0 } // treat no nextReview as due today
                return (start...end).contains(due)
            }.count
            let label = Self.weekdayFormatter.string(from: d)
            return ForecastData(date: d, label: label, dueCount: count)
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if cards.isEmpty {
                        emptyState
                    } else {
                        dueForecastSection
                        overviewTiles
                        perDeckBreakdown
                        algorithmExplainer
                    }
                }
                .padding()
            }
            .navigationTitle("Stats")
        }
    }

    // MARK: - Sections
    private var dueForecastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundColor(ColorPalette.flame)
                    .font(.title2)
                    .frame(width: 24, alignment: .leading)
                Text("7‑Day Due Forecast")
                    .font(.title2).bold()
            }
            Chart(forecast7Days) { item in
                BarMark(
                    x: .value("Day", item.label),
                    y: .value("Due", item.dueCount)
                )
                .foregroundStyle(ColorPalette.flame)
            }
            .chartYAxis { AxisMarks(position: .leading) }
            .frame(height: 220)
        }
        .background(ColorPalette.timberwolf.opacity(0.08))
        .cornerRadius(12)
        .shadow(color: ColorPalette.eerieBlack.opacity(0.08), radius: 4)
    }

    private var overviewTiles: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.grid.2x2")
                    .foregroundColor(ColorPalette.flame)
                    .frame(width: 24, alignment: .leading)
                Text("Overview")
                    .font(.title2).bold()
            }
            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    statTile(title: "Due Today", value: "\(dueTodayCount)", symbol: "calendar.badge.clock")
                    statTile(title: "New", value: "\(newCount)", symbol: "sparkles")
                }
                GridRow {
                    statTile(title: "Mature", value: "\(matureCount)", symbol: "leaf")
                    statTile(title: "Lapses", value: "\(lapsesTotal)", symbol: "arrow.uturn.backward")
                }
                GridRow {
                    statTile(title: "Avg Ease", value: formatted(avgEase, suffix: "x"), symbol: "speedometer")
                    statTile(title: "Avg Stability", value: formatted(avgStability), symbol: "shield")
                }
                GridRow {
                    statTile(title: "Avg Difficulty", value: formatted(avgDifficulty), symbol: "brain.head.profile")
                }
            }
        }
    }

    private var perDeckBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "square.stack.3d.up")
                    .foregroundColor(ColorPalette.flame)
                    .frame(width: 24, alignment: .leading)
                Text("By Deck")
                    .font(.title2).bold()
            }
            VStack(spacing: 10) {
                ForEach(decks) { deck in
                    let deckCards = deck.cards
                    let due = deckCards.filter { c in
                        guard !c.suspended else { return false }
                        guard let due = c.nextReview else { return true }
                        return due <= Calendar.current.date(byAdding: .day, value: 1, to: today)!
                    }.count
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(deck.title).font(.headline)
                            Text("\(deckCards.count) cards · \(due) due")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        ProgressView(value: progressForDeck(deckCards))
                            .tint(ColorPalette.flame)
                            .frame(width: 120)
                    }
                    .padding(12)
                    .background(ColorPalette.timberwolf.opacity(0.08))
                    .cornerRadius(10)
                }
            }
        }
    }

    private var algorithmExplainer: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 8) {
                Text("Our scheduler blends proven ideas (SM‑2/FSRS‑inspired) to space reviews effectively. At a glance:")
                    .foregroundStyle(.secondary)
                bullet("You grade each review as Again, Hard, Good, or Easy.")
                bullet("Ease adjusts up/down based on your grade, within safe bounds.")
                bullet("Difficulty (0..1) shifts: lower means easier for you.")
                bullet("Stability grows with success — larger stability yields longer intervals.")
                bullet("Next interval uses both current interval and stability × ease, clamped to reasonable limits.")
                bullet("Lapses increment on 'Again' and shorten the next interval.")
            }
            .padding(.top, 8)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(ColorPalette.flame)
                    .frame(width: 24, alignment: .leading)
                Text("How the algorithm works")
                    .font(.title2).bold()
            }
        }
        .padding()
        .background(ColorPalette.timberwolf.opacity(0.08))
        .cornerRadius(12)
        .shadow(color: ColorPalette.eerieBlack.opacity(0.08), radius: 4)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 56, weight: .semibold))
                .foregroundColor(ColorPalette.flame)
            Text("No stats yet")
                .font(.title2).bold()
            Text("Create a deck and start reviewing. Your progress, due forecast, and learning insights will appear here.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ColorPalette.timberwolf.opacity(0.08))
        .cornerRadius(12)
        .shadow(color: ColorPalette.eerieBlack.opacity(0.08), radius: 4)
    }

    // MARK: - Helpers
    private func statTile(title: String, value: String?, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .foregroundColor(ColorPalette.flame)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(value ?? "—")
                .font(.title2).bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(ColorPalette.timberwolf.opacity(0.08))
        .cornerRadius(12)
    }

    private func formatted(_ value: Double?, suffix: String = "") -> String? {
        guard let v = value else { return nil }
        if suffix == "x" {
            return String(format: "%.2f%@", v, suffix)
        } else {
            return String(format: "%.2f%@", v, suffix)
        }
    }

    private func progressForDeck(_ cards: [Card]) -> Double {
        guard !cards.isEmpty else { return 0 }
        let learned = cards.filter { $0.reviewCount > 0 }.count
        return Double(learned) / Double(cards.count)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
            Text(text)
        }
        .foregroundStyle(.secondary)
    }
}

#if DEBUG
#Preview {
    StatsView()
}
#endif
