import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct AccountView: View {
    @Environment(\.modelContext) private var context
    @Query private var users: [User]
    @AppStorage("theme") private var theme = "light"
    @AppStorage("notifications") private var notificationsEnabled = true
    @AppStorage("isOnboarding") private var isOnboarding: Bool = false
    
    @State private var name: String = ""
    @State private var showDeleteConfirm = false
    @State private var deleteInProgress = false
    
    var body: some View {
        Form {
            // Profile section
            Section(header: Text("Profile")) {
                TextField("First Name", text: $name)
                    .onChange(of: name) { _, newValue in
                        saveName(newValue)
                    }
            }
            
            // Danger zone
            Section(header: Text("Danger Zone")) {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("Delete All Data", systemImage: "trash")
                }
                .disabled(deleteInProgress)
            }
        }
        .navigationTitle("Account")
        .onAppear(perform: loadUser)
        .alert("Delete all data?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { deleteAllData() }
        } message: {
            Text("This will permanently delete your decks, cards and profile.")
        }
    }
    
    private func loadUser() {
        if let existing = users.first {
            name = existing.firstName
        } else {
            // Create a default user if none exists
            let newUser = User(firstName: "")
            context.insert(newUser)
            do { try context.save() } catch { }
            name = newUser.firstName
        }
    }
    
    private func saveName(_ newName: String) {
        guard let user = users.first else { return }
        user.firstName = newName
        do { try context.save() } catch { }
    }
    
    private func deleteAllData() {
        deleteInProgress = true
        defer { deleteInProgress = false }
        do {
            try deleteAll(of: Card.self)
            try deleteAll(of: Deck.self)
            // Removed deletion of debug-only Item model to avoid type ambiguity
            try deleteAll(of: User.self)
            try context.save()
            // Reset local preferences
            theme = "light"
            notificationsEnabled = true
            // Force onboarding flow
            isOnboarding = true
        } catch {
            // handle silently for now; could add error UI
        }
    }
    
    private func deleteAll<T: PersistentModel>(of type: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let items = try context.fetch(descriptor)
        for item in items {
            context.delete(item)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack { AccountView() }
}
#endif
