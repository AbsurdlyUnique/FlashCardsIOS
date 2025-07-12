import SwiftUI
import SwiftData

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var deck: Deck
    
    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var hint: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Card Details")
                        .font(.title2).bold()
                        .foregroundColor(ColorPalette.blackOlive)
                    
                    TextField("Question", text: $question)
                        .padding()
                        .background(ColorPalette.floralWhite)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(ColorPalette.timberwolf.opacity(0.3), lineWidth: 1))
                    
                    TextField("Answer", text: $answer)
                        .padding()
                        .background(ColorPalette.floralWhite)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(ColorPalette.timberwolf.opacity(0.3), lineWidth: 1))
                    
                    TextField("Hint (optional)", text: $hint)
                        .padding()
                        .background(ColorPalette.floralWhite)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(ColorPalette.timberwolf.opacity(0.3), lineWidth: 1))
                }
                .padding()
                
                Spacer()
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationTitle("New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newCard = Card(question: question, answer: answer, hint: hint.isEmpty ? nil : hint)
                        deck.cards.append(newCard)
                        modelContext.insert(newCard)
                        dismiss()
                    }
                    .bold()
                    .disabled(question.trimmingCharacters(in: .whitespaces).isEmpty || answer.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Deck.self, configurations: config)
    let sampleDeck = Deck(title: "Sample Deck")
    
    return AddCardView(deck: sampleDeck)
        .modelContainer(container)
}
