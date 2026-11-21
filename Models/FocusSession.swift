import Foundation

/// One single focus session: what you worked on, how long, and how it ended.
struct FocusSession: Identifiable, Codable {
    let id: UUID
    var name: String
    var duration: TimeInterval
    var startTime: Date?
    var endTime: Date?
    var isCompleted: Bool
    var emergencyExited: Bool
    var whatAccomplished: String?

    init(name: String, duration: TimeInterval) {
        self.id = UUID()
        self.name = name
        self.duration = duration
        self.startTime = nil
        self.endTime = nil
        self.isCompleted = false
        self.emergencyExited = false
        self.whatAccomplished = nil
    }

    /// Time left based on when the session started.
    var timeRemaining: TimeInterval {
        guard let start = startTime, !isCompleted, !emergencyExited else {
            return duration
        }
        let elapsed = Date().timeIntervalSince(start)
        return max(0, duration - elapsed)
    }

    var isActive: Bool {
        startTime != nil && !isCompleted && !emergencyExited && timeRemaining > 0
    }

    /// "MM:SS" style countdown for the big timer display.
    var formattedRemaining: String {
        let total = Int(timeRemaining)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    mutating func start() {
        startTime = Date()
    }

    mutating func complete(what: String) {
        endTime = Date()
        isCompleted = true
        whatAccomplished = what
    }

    mutating func emergencyExit() {
        endTime = Date()
        emergencyExited = true
    }
}
