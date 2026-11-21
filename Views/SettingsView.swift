import SwiftUI

/// Settings: trusted contacts, an honest about note, and a guarded reset.
struct SettingsView: View {
    @EnvironmentObject var store: SessionStore
    @AppStorage("emergencyContacts") private var contactsRaw = ""
    @State private var newContact = ""
    @State private var showResetAlert = false

    private var contacts: [String] {
        contactsRaw
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.cream.ignoresSafeArea()
                Form {
                Section {
                    Text("Who should always be able to reach you during a session? These are your trusted people when things get noisy.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("About")
                }

                Section("Trusted contacts") {
                    ForEach(contacts, id: \.self) { contact in
                        Label(contact, systemImage: "person.fill")
                    }
                    .onDelete(perform: deleteContacts)

                    HStack {
                        TextField("Add a name, e.g. Mum", text: $newContact)
                        Button("Add") {
                            addContact()
                        }
                        .disabled(newContact.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section("About ClearHead") {
                    Text("ClearHead doesn't lock your phone. It reminds you why you started. A session only counts when you finish what you began — and if you leave early, history says so honestly.")
                }

                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Text("Reset all history")
                    }
                } footer: {
                    Text("Deletes every saved session and your stats. Your trusted contacts are kept.")
                }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .alert("Reset everything?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    store.resetAll()
                }
            } message: {
                Text("All saved sessions and stats will be deleted. This cannot be undone.")
            }
        }
    }

    private func addContact() {
        let trimmed = newContact.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if contactsRaw.isEmpty {
            contactsRaw = trimmed
        } else {
            contactsRaw += ", \(trimmed)"
        }
        newContact = ""
    }

    private func deleteContacts(_ offsets: IndexSet) {
        var items = contacts
        items.remove(atOffsets: offsets)
        contactsRaw = items.joined(separator: ", ")
    }
}
