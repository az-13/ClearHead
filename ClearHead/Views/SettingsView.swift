import SwiftUI

/// Settings: trusted contacts, about note, reset history.
struct SettingsView: View {
    @EnvironmentObject var store: SessionStore
    @AppStorage("emergencyContacts") private var contactsRaw = ""
    @State private var newContact = ""

    private var contacts: [String] {
        contactsRaw
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Trusted contacts during focus") {
                    Text("Only these people should interrupt you while a session runs.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(contacts, id: \.self) { contact in
                        Text(contact)
                    }

                    HStack {
                        TextField("Add a name, e.g. Mum", text: $newContact)
                        Button("Add") {
                            let trimmed = newContact.trimmingCharacters(in: .whitespaces)
                            guard !trimmed.isEmpty else { return }
                            if contactsRaw.isEmpty {
                                contactsRaw = trimmed
                            } else {
                                contactsRaw += ", \(trimmed)"
                            }
                            newContact = ""
                        }
                    }
                }

                Section("About ClearHead") {
                    Text("ClearHead keeps you present during study sessions. It doesn't lock your phone — it reminds you why you started. A session only counts when you finish what you began.")
                }

                Section {
                    Button(role: .destructive) {
                        store.resetAll()
                    } label: {
                        Text("Reset all history")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
