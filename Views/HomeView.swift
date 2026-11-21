import SwiftUI

/// Home dashboard: greeting, streak/stats, inline session setup that
/// actually launches the full-screen timer, and recent sessions.
struct HomeView: View {
    @EnvironmentObject var store: SessionStore

    @State private var title = ""
    @State private var minutes = 25

    private let quickTitles = ["Maths", "English", "History", "Science", "Reading", "Essay plan"]
    private let durations = [15, 25, 45, 60]

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<23: return "Good evening"
        default:      return "Up late, hey"
        }
    }

    private var totalLabel: String {
        let minutes = store.totalFocusMinutes
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        } else {
            return "\(minutes)m"
        }
    }

    private var averageLabel: String {
        guard store.completedCount > 0 else { return "—" }
        return "\(store.totalFocusMinutes / store.completedCount) min"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                statsRow
                setupCard
                recentSection
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(AppTheme.cream.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Ready to focus?")
                    .font(.largeTitle.bold())
            }
            Spacer()

            VStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                Text("\(store.currentStreak) day\(store.currentStreak == 1 ? "" : "s")")
                    .font(.caption2.bold())
                    .foregroundColor(.secondary)
            }
            .frame(width: 58, height: 58)
            .background(Color.orange.opacity(0.14))
            .clipShape(Circle())
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                StatCard(icon: "clock.fill", title: "Focus time", value: totalLabel, tint: .indigo)
                StatCard(icon: "checkmark.circle.fill", title: "Sessions done", value: "\(store.completedCount)", tint: .green)
            }
            HStack(spacing: 14) {
                StatCard(icon: "calendar", title: "Last 7 days", value: "\(store.weekCompletedCount)", tint: .purple)
                StatCard(icon: "chart.bar.fill", title: "Avg length", value: averageLabel, tint: .blue)
            }
        }
    }

    // MARK: - Inline setup

    private var setupCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What are you working on?")
                .font(.headline)

            TextField("e.g. Maths revision", text: $title)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(quickTitles, id: \.self) { quick in
                        Button {
                            title = quick
                        } label: {
                            Text(quick)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.indigo.opacity(0.12))
                                .foregroundColor(.indigo)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Text("How long?")
                .font(.headline)

            HStack(spacing: 10) {
                ForEach(durations, id: \.self) { minutes in
                    ChipView(
                        title: "\(minutes) min",
                        selected: self.minutes == minutes
                    ) {
                        self.minutes = minutes
                    }
                }
            }

            Button {
                store.start(name: trimmedTitle, duration: TimeInterval(minutes * 60))
                title = ""
            } label: {
                Label("Start Focus Session", systemImage: "play.fill")
            }
            .buttonStyle(PrimaryButtonStyle(disabled: trimmedTitle.isEmpty))
            .disabled(trimmedTitle.isEmpty)
        }
        .glassCard()
    }

    // MARK: - Recent sessions

    @ViewBuilder
    private var recentSection: some View {
        if store.recentSessions.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .font(.largeTitle)
                    .foregroundColor(.secondary.opacity(0.6))
                Text("No sessions yet")
                    .font(.headline)
                Text("Set your first session above and build the habit.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .glassCard()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent sessions")
                    .font(.headline)
                ForEach(store.recentSessions) { session in
                    HomeSessionRow(session: session)
                }
            }
        }
    }
}

// MARK: - Reusable bits

struct ChipView: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(selected ? Color.indigo : Color.secondary.opacity(0.12))
                .foregroundColor(selected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct HomeSessionRow: View {
    let session: FocusSession

    private var statusIcon: String {
        session.isCompleted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
    }

    private var statusColor: Color {
        session.isCompleted ? AppTheme.successGreen : AppTheme.warningAmber
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .font(.title3)
                .foregroundColor(statusColor)

            VStack(alignment: .leading, spacing: 3) {
                Text(session.name)
                    .font(.headline)
                    .lineLimit(1)
                Text("\(session.dateLabel) · \(session.shortDuration)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let note = session.whatAccomplished, !note.isEmpty {
                    Text(note)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .glassCard(padding: 14)
    }
}
