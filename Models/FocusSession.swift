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

    // MARK: - Timing

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

    // MARK: - Display helpers

    /// Planned length in whole minutes (e.g. 25).
    var minutes: Int {
        max(1, Int((duration / 60).rounded()))
    }

    /// "25 min" style label for rows and cards.
    var shortDuration: String {
        "\(minutes) min"
    }

    /// Friendly date label: Today / Yesterday / weekday date.
    var dateLabel: String {
        guard let end = endTime else { return "In progress" }
        let cal = Calendar.current
        if cal.isDateInToday(end) { return "Today" }
        if cal.isDateInYesterday(end) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: end)
    }

    // MARK: - Transitions

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
