import Foundation
import ActivityKit
import SwiftUI

// MARK: - Live Activity Attributes
@available(iOS 16.2, *)
struct FocusActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
        var sessionName: String
    }

    public var sessionName: String
    public var totalSeconds: Int
}

// MARK: - Live Activity Manager (this stays in your main app)
@available(iOS 16.2, *)
enum LiveActivityManager {
    private static var activity: Activity<FocusActivityAttributes>?

    static func start(name: String, totalSeconds: Int) async {
        let attributes = FocusActivityAttributes(
            sessionName: name,
            totalSeconds: totalSeconds
        )
        let state = FocusActivityAttributes.ContentState(
            remainingSeconds: totalSeconds,
            sessionName: name
        )

        do {
            activity = try await Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: Date().addingTimeInterval(30))
            )
            print("✅ ClearHead: Live Activity started — \(name), \(totalSeconds)s")
        } catch {
            print("❌ ClearHead: Failed to start: \(error.localizedDescription)")
        }
    }

    static func update(remainingSeconds: Int, name: String) async {
        guard let activity = activity else { return }
        let state = FocusActivityAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            sessionName: name
        )
        await activity.update(.init(state: state, staleDate: Date().addingTimeInterval(5)))
    }

    static func stop() async {
        if let activity = activity {
            await activity.end(
                using: FocusActivityAttributes.ContentState(
                    remainingSeconds: 0,
                    sessionName: ""
                ),
                dismissalPolicy: .immediate
            )
        }
        activity = nil
    }
}

// MARK: - Helper functions (used by both app and widget)
@available(iOS 16.2, *)
struct FocusActivityHelpers {
    static func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    static func timeStringShort(from seconds: Int) -> String {
        if seconds >= 60 {
            return "\(seconds / 60)m"
        } else {
            return "\(seconds)s"
        }
    }
}
