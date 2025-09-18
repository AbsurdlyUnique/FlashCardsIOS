import SwiftUI

struct FlashcardView: View {
    let card: Card
    @Binding var isFlipped: Bool

    var body: some View {
        ZStack {
            CardSideView(text: card.question, title: "Question")
                .opacity(isFlipped ? 0 : 1)
            
            CardSideView(text: card.answer, title: "Answer")
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
        .background(ColorPalette.floralWhite)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardSideView: View {
    let text: String
    let title: String

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .foregroundColor(ColorPalette.timberwolf)
            
            ScrollView {
                Text(text)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(ColorPalette.blackOlive)
            }
        }
        .padding(30)
    }
}
