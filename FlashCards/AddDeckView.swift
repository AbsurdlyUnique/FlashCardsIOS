import SwiftUI
import SwiftData

struct AddDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var description: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Illustration
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(ColorPalette.flame.opacity(0.12))
                                .frame(width: 96, height: 96)
                            Image(systemName: "rectangle.stack.fill")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(ColorPalette.flame)
                        }
                        Text("New Deck")
                            .font(.title2).bold()
                            .foregroundStyle(.primary)
                        Text("Give your deck a clear name and an optional description.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Form
                    VStack(alignment: .leading, spacing: 14) {
                        // Title field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Title")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 8) {
                                Image(systemName: "text.insert")
                                    .foregroundStyle(.secondary)
                                TextField("e.g English Verbs", text: $title)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled(true)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .frame(minHeight: 52)
                            .background(Color.secondary.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }

                        // Description field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description (optional)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 8) {
                                Image(systemName: "text.alignleft")
                                    .foregroundStyle(.secondary)
                                TextField("e.g. Common irregular verbs", text: $description)
                                    .textInputAutocapitalization(.sentences)
                                    .autocorrectionDisabled(true)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .frame(minHeight: 52)
                            .background(Color.secondary.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    // Primary action button (mirrors toolbar action)
                    Button {
                        saveDeck()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Deck")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ColorPalette.flame)
                    .padding(.horizontal)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)

                    Spacer(minLength: 8)
                }
                .padding(.top, 24)
            }
            .background(.background)
            .navigationTitle("New Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") { saveDeck() }
                    .bold()
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveDeck() {
        let newDeck = Deck(title: title, deckDescription: description.isEmpty ? nil : description)
        modelContext.insert(newDeck)
        dismiss()
    }
}

