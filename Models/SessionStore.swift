import Foundation
import SwiftUI

/// Stores every session and keeps the current active one.
/// Saves everything locally in UserDefaults — no account, no internet.
final class SessionStore: ObservableObject {
    @Published var sessions: [FocusSession] = []
    @Published var activeSession: FocusSession?

    private let storageKey = "ClearHead.sessions"

    init() {
        load()
    }

    // MARK: - Actions

    func start(name: String, duration: TimeInterval) {
        var session = FocusSession(name: name, duration: duration)
        session.start()
        activeSession = session
    }

    func completeActive(what: String) {
        guard var active = activeSession else { return }
        active.complete(what: what)
        sessions.insert(active, at: 0)
        activeSession = nil
        save()
    }

    func emergencyExitActive() {
        guard var active = activeSession else { return }
        active.emergencyExit()
        sessions.insert(active, at: 0)
        activeSession = nil
        save()
    }

    func resetAll() {
        sessions.removeAll()
        activeSession = nil
        save()
    }

    // MARK: - Stats

    var completedSessions: [FocusSession] {
        sessions.filter { $0.isCompleted }
    }

    var completedCount: Int {
        completedSessions.count
    }

    /// Total planned focus time across completed sessions, in minutes.
    var totalFocusMinutes: Int {
        let total = completedSessions.reduce(0.0) { $0 + $1.duration }
        return Int(total / 60)
    }

    /// Completed sessions from the last rolling 7 days.
    var weekCompleted: [FocusSession] {
        guard let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return []
        }
        return completedSessions.filter { ($0.endTime ?? .distantPast) >= cutoff }
    }

    var weekFocusMinutes: Int {
        Int(weekCompleted.reduce(0.0) { $0 + $1.duration } / 60)
    }

    var weekCompletedCount: Int {
        weekCompleted.count
    }

    /// Consecutive days (ending today, or yesterday if today has none yet)
    /// on which at least one session was completed.
    var currentStreak: Int {
        let cal = Calendar.current
        let completedDays = Set<Date>(
            completedSessions.compactMap { session in
                guard let end = session.endTime else { return nil }
                return cal.startOfDay(for: end)
            }
        )

        var day = cal.startOfDay(for: Date())
        if !completedDays.contains(day) {
            guard let previous = cal.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = previous
        }

        var streak = 0
        while completedDays.contains(day) {
            streak += 1
            guard let previous = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    /// Newest-first slice for the Home recent list.
    var recentSessions: [FocusSession] {
        Array(sessions.prefix(4))
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([FocusSession].self, from: data)
        else { return }
        sessions = decoded
    }
}
