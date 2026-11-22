import Foundation
import ActivityKit

/// Live Activity shown on the Lock Screen and in the Dynamic Island
/// on devices running iOS 16.1+. Every symbol here is availability-gated,
/// so the app still compiles against the iOS 16.0 deployment target.

@available(iOS 16.1, *)
struct FocusActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// Seconds left when the activity last refreshed.
        var remainingSeconds: Int
        /// Name of the session (e.g. "Maths Revision").
        var sessionName: String
    }

    public var sessionName: String
    public var totalSeconds: Int
}

/// Thin wrapper around the current Live Activity: start on session begin,
/// refresh the countdown each tick, end when the session finishes or exits.
@available(iOS 16.1, *)
enum LiveActivityManager {
    private static var activity: Activity<FocusActivityAttributes>?

    static func start(name: String, totalSeconds: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = FocusActivityAttributes(
            sessionName: name,
            totalSeconds: totalSeconds
        )
        let state = FocusActivityAttributes.ContentState(
            remainingSeconds: totalSeconds,
            sessionName: name
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil)
            )
        } catch {
            print("ClearHead: could not start Live Activity: \(error.localizedDescription)")
        }
    }

    static func update(remainingSeconds: Int, name: String) {
        let state = FocusActivityAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            sessionName: name
        )
        Task {
            await activity?.update(using: state)
        }
    }

    static func stop() {
        Task {
            await activity?.end(dismissalPolicy: .immediate)
        }
        activity = nil
    }
}
