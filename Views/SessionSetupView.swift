import SwiftUI

/// Sheet where you name the session and pick a length before starting.
struct SessionSetupView: View {
    @EnvironmentObject var store: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var minutes = 25

    private let options = [15, 25, 45, 60]

    var body: some View {
        NavigationStack {
            Form {
                Section("What are you working on?") {
                    TextField("e.g. Maths Revision", text: $name)
                }

                Section("Session length") {
                    Picker("Minutes", selection: $minutes) {
                        ForEach(options, id: \.self) { Text("\($0) min").tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button {
                        store.start(
                            name: name.isEmpty ? "Focus Session" : name,
                            duration: TimeInterval(minutes * 60)
                        )
                        dismiss()
                    } label: {
                        Text("Start focus session")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("New Session")
            .toolbar {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
