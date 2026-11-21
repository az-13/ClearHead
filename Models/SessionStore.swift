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

    var completedCount: Int {
        sessions.filter { $0.isCompleted }.count
    }

    var totalFocusMinutes: Int {
        let total = sessions.filter { $0.isCompleted }.reduce(0.0) { $0 + $1.duration }
        return Int(total / 60)
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
