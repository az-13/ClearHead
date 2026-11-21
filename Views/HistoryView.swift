import SwiftUI

/// Progress dashboard: totals, last-7-days strip, and every past session
/// with honest labels (completed vs exited early).
struct HistoryView: View {
    @EnvironmentObject var store: SessionStore

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private var weekDays: [Date] {
        (0..<7).reversed().compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: Date())
        }
    }

    private var totalLabel: String {
        let minutes = store.totalFocusMinutes
        return minutes >= 60 ? "\(minutes / 60)h \(minutes % 60)m" : "\(minutes)m"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statsGrid
                    weekStrip
                    sessionList
                }
                .padding(18)
            }
            .background(AppTheme.cream.ignoresSafeArea())
            .navigationTitle("History")
        }
    }

    // MARK: - Stats

    private var statsGrid: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                StatCard(icon: "flame.fill", title: "Day streak", value: "\(store.currentStreak)", tint: .orange)
                StatCard(icon: "clock.fill", title: "All focus time", value: totalLabel, tint: .indigo)
            }
            HStack(spacing: 14) {
                StatCard(icon: "checkmark.circle.fill", title: "Completed", value: "\(store.completedCount)", tint: .green)
                StatCard(icon: "calendar", title: "Last 7 days", value: "\(store.weekCompletedCount)", tint: .purple)
            }
        }
    }

    // MARK: - Week strip

    private var weekStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 days")
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    VStack(spacing: 6) {
                        Text(dayFormatter.string(from: day))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Circle()
                            .fill(hasCompleted(on: day) ? Color.indigo : Color.secondary.opacity(0.15))
                            .frame(width: 12, height: 12)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .glassCard()
    }

    private func hasCompleted(on day: Date) -> Bool {
        store.completedSessions.contains { session in
            guard let end = session.endTime else { return false }
            return Calendar.current.isDate(end, inSameDayAs: day)
        }
    }

    // MARK: - Sessions

    @ViewBuilder
    private var sessionList: some View {
        if store.sessions.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "tray")
                    .font(.largeTitle)
                    .foregroundColor(.secondary.opacity(0.6))
                Text("Nothing recorded yet")
                    .font(.headline)
                Text("Finished sessions will appear here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .glassCard()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("All sessions")
                    .font(.headline)
                ForEach(store.sessions) { session in
                    HomeSessionRow(session: session)
                }
            }
        }
    }
}
