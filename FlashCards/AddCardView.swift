import SwiftUI
import SwiftData

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var deck: Deck
    var onClose: (() -> Void)? = nil
    
    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var hint: String = ""
    
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
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundStyle(ColorPalette.flame)
                        }
                        Text("New Card")
                            .font(.title2).bold()
                            .foregroundStyle(.primary)
                        Text("Provide a clear question and answer. Add a hint if helpful.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Form Fields
                    VStack(alignment: .leading, spacing: 14) {
                        // Question
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Question")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 8) {
                                Image(systemName: "text.quote")
                                    .foregroundStyle(.secondary)
                                TextField("e.g. What is a phrasal verb?", text: $question)
                                    .textInputAutocapitalization(.sentences)
                                    .autocorrectionDisabled(false)
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

                        // Answer
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Answer")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(.secondary)
                                TextField("e.g. A verb combined with a particle", text: $answer)
                                    .textInputAutocapitalization(.sentences)
                                    .autocorrectionDisabled(false)
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

                        // Hint (optional)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Hint (optional)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb")
                                    .foregroundStyle(.secondary)
                                TextField("e.g. Think of 'look up' or 'give in'", text: $hint)
                                    .textInputAutocapitalization(.sentences)
                                    .autocorrectionDisabled(false)
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

                    // Primary action button
                    Button {
                        saveCard()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Card")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ColorPalette.flame)
                    .buttonBorderShape(.roundedRectangle(radius: 14))
                    .controlSize(.large)
                    .padding(.horizontal)
                    .disabled(question.trimmingCharacters(in: .whitespaces).isEmpty || answer.trimmingCharacters(in: .whitespaces).isEmpty)

                    Spacer(minLength: 8)
                }
                .padding(.top, 24)
            }
            .background(.background)
            .navigationTitle("New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                        // Fallback force-close
                        DispatchQueue.main.async { onClose?() }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") { saveCard() }
                    .bold()
                    .disabled(question.trimmingCharacters(in: .whitespaces).isEmpty || answer.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveCard() {
        let newCard = Card(question: question, answer: answer, hint: hint.isEmpty ? nil : hint)
        deck.cards.append(newCard)
        modelContext.insert(newCard)
        dismiss()
        // Fallback force-close in case dismiss doesn't propagate
        DispatchQueue.main.async { onClose?() }
    }
}

