import SwiftUI
import Charts
import SwiftData

@available(iOS 17.0, *)
public struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var decks: [Deck]
    
    // Helper model for chart data
    struct ChartData: Identifiable {
        let id = UUID()
        let dayLabel: String
        let cards: Double
    }

    // Static mock data for now; you can replace it with real progress data later
    private var chartData: [ChartData] {
        (0..<7).map { index in
            ChartData(dayLabel: "Day \(index + 1)", cards: Double.random(in: 0...20))
        }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Daily Progress Chart
                    Section {
                        Chart(chartData) { data in
                            BarMark(
                                x: .value("Day", data.dayLabel),
                                y: .value("Cards", data.cards)
                            )
                            .foregroundStyle(ColorPalette.flame)
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    }
                    .padding()
                    
                    // Deck Performance
                    Section {
                        VStack(spacing: 16) {
                            Text("Deck Performance")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(ColorPalette.blackOlive)
                            
                            ForEach(decks.prefix(3)) { deck in
                                HStack {
                                    Text(deck.title)
                                        .font(.headline)
                                    Spacer()
                                    Text("\(Int(deck.progress * 100))%")
                                        .font(.headline)
                                        .foregroundColor(ColorPalette.flame)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .background(ColorPalette.timberwolf.opacity(0.1))
                        .cornerRadius(12)
                        .shadow(color: ColorPalette.eerieBlack.opacity(0.1), radius: 4)
                    }
                    .padding()
                    
                    // Study Streak
                    Section {
                        VStack(spacing: 16) {
                            Text("Study Streak")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(ColorPalette.blackOlive)
                            
                            Text("15 days")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(ColorPalette.flame)
                            
                            Text("Keep it going!")
                                .font(.subheadline)
                                .foregroundColor(ColorPalette.timberwolf)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorPalette.timberwolf.opacity(0.1))
                        .cornerRadius(12)
                        .shadow(color: ColorPalette.eerieBlack.opacity(0.1), radius: 4)
                    }
                    .padding()
                }
            }
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    StatsView()
}
