import SwiftUI
import SwiftData

struct AddDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var description: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Deck Details")
                        .font(.title2).bold()
                        .foregroundColor(ColorPalette.blackOlive)
                    
                    TextField("Deck Title (e.g., 'Spanish Verbs')", text: $title)
                        .padding()
                        .background(ColorPalette.floralWhite)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(ColorPalette.timberwolf.opacity(0.3), lineWidth: 1))
                    
                    TextField("Description (optional)", text: $description)
                        .padding()
                        .background(ColorPalette.floralWhite)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(ColorPalette.timberwolf.opacity(0.3), lineWidth: 1))
                }
                .padding()
                
                Spacer()
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationTitle("New Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newDeck = Deck(title: title, deckDescription: description.isEmpty ? nil : description)
                        modelContext.insert(newDeck)
                        dismiss()
                    }
                    .bold()
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddDeckView()
        .modelContainer(for: Deck.self, inMemory: true)
}
