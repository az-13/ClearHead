import SwiftUI

/// Home screen: welcome, quick stats, start button, recent sessions.
struct HomeView: View {
    @EnvironmentObject var store: SessionStore
    @State private var showingSetup = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Welcome back")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("ClearHead")
                            .font(.largeTitle.bold())
                    }
                    .padding(.top)

                    HStack(spacing: 16) {
                        StatCard(title: "Sessions done", value: "\(store.completedCount)")
                        StatCard(title: "Focus minutes", value: "\(store.totalFocusMinutes)")
                    }
                    .padding(.horizontal)

                    Button {
                        showingSetup = true
                    } label: {
                        Label("Start a focus session", systemImage: "play.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)

                    if store.sessions.isEmpty {
                        Text("No sessions yet. Start one when you're ready.")
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent sessions")
                                .font(.headline)
                            ForEach(store.sessions.prefix(5)) { session in
                                SessionRow(session: session)
                            }
                        }
                        .padding(.horizontal)
                    }
                    Spacer(minLength: 20)
                }
            }
            .sheet(isPresented: $showingSetup) {
                SessionSetupView()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct SessionRow: View {
    let session: FocusSession

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.name)
                    .font(.headline)
                Text(session.isCompleted
                     ? "Completed · \(Int(session.duration / 60)) min"
                     : "Left early")
                .font(.caption)
                .foregroundColor(session.isCompleted ? .green : .orange)
            }
            Spacer()
            if let note = session.whatAccomplished, !note.isEmpty {
                Text(note)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: 140, alignment: .trailing)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
