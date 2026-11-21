import SwiftUI

/// Shown when a session finishes: you write one thing you accomplished,
/// then the session is saved and counted.
struct CheckInView: View {
    @EnvironmentObject var store: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var what = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Well done — you stayed focused!")
                    .font(.title2.bold())

                Text("One thing you accomplished or learned:")
                    .foregroundColor(.secondary)

                TextEditor(text: $what)
                    .frame(minHeight: 120)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.3))
                    )

                Button {
                    store.completeActive(what: what.isEmpty ? "Focus session completed" : what)
                    dismiss()
                } label: {
                    Text("Save session")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Session Complete")
        }
    }
}
