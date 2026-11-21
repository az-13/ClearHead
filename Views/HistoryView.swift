import SwiftUI

/// All past sessions with simple totals at the top.
struct HistoryView: View {
    @EnvironmentObject var store: SessionStore

    var body: some View {
        NavigationStack {
            List {
                Section("Totals") {
                    LabeledContent("Completed sessions", value: "\(store.completedCount)")
                    LabeledContent("Total focus time", value: "\(store.totalFocusMinutes) minutes")
                }

                Section("All sessions") {
                    if store.sessions.isEmpty {
                        Text("Nothing here yet.")
                            .foregroundColor(.secondary)
                    }
                    ForEach(store.sessions) { session in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.name)
                                .font(.headline)
                            Text(session.isCompleted ? "Completed" : "Exited early")
                                .font(.caption)
                                .foregroundColor(session.isCompleted ? .green : .orange)
                            if let note = session.whatAccomplished, !note.isEmpty {
                                Text(note)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}
