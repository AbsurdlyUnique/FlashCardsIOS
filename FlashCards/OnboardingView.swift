import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isOnboarding: Bool
    @State private var currentTab = 0
    @State private var firstName: String = ""
    @FocusState private var isNameFocused: Bool

    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $currentTab) {
                    OnboardingPageView(
                        imageName: "brain.head.profile",
                        title: "Welcome to FlashCards",
                        description: "The smartest way to master any subject. Let's begin your learning journey."
                    ).tag(0)

                    OnboardingPageView(
                        imageName: "sparkles",
                        title: "Effortless Studying",
                        description: "Our system adapts to you, making learning faster and more effective than ever before."
                    ).tag(1)

                    VStack(spacing: 30) {
                        Image(systemName: "person.fill.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(ColorPalette.flame)
                        Text("Make It Yours")
                            .font(.largeTitle).bold()
                            .foregroundStyle(.primary)
                        Text("A personal touch makes all the difference. What should we call you?")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 40)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "person")
                                .foregroundStyle(.secondary)
                            TextField("Enter your first name", text: $firstName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled(true)
                                .submitLabel(.done)
                                .focused($isNameFocused)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(minHeight: 56)
                        .background(Color.secondary.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                        .onTapGesture { isNameFocused = true }
                        .padding(.horizontal, 40)
                        
                    }.tag(2)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .never))

                HStack {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(currentTab == index ? ColorPalette.flame : Color.secondary.opacity(0.5))
                            .frame(width: currentTab == index ? 20 : 8, height: 8)
                            .animation(.spring(), value: currentTab)
                    }
                }
                .padding(.bottom, 20)

                Button(action: handleButtonTap) {
                    Text(currentTab == 2 ? "Let's Get Started!" : "Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ColorPalette.flame)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
                .disabled(currentTab == 2 && firstName.isEmpty)
            }
        }
    }
    
    private func handleButtonTap() {
        if currentTab == 2 {
            if !firstName.isEmpty {
                let newUser = User(firstName: firstName)
                modelContext.insert(newUser)
                withAnimation {
                    isOnboarding = false
                }
            }
        } else {
            withAnimation {
                currentTab += 1
            }
        }
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: imageName)
                .font(.system(size: 80))
                .foregroundColor(ColorPalette.flame)
            
            Text(title)
                .font(.largeTitle).bold()
                .foregroundStyle(.primary)
            
            Text(description)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
        }
    }
}
