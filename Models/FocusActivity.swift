import Foundation
import ActivityKit

@available(iOS 16.2, *)
struct FocusActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
        var sessionName: String
    }

    public var sessionName: String
    public var totalSeconds: Int
}

@available(iOS 16.2, *)
enum LiveActivityManager {
    private static var activity: Activity<FocusActivityAttributes>?

    static func start(name: String, totalSeconds: Int) {
        // Skip the settings check — Troll Store won't show it there
        // Just try to start directly
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
                content: ActivityContent(state: state, staleDate: Date().addingTimeInterval(30))
            )
            print("✅ Live Activity started")
        } catch {
            print("❌ Failed: \(error.localizedDescription)")
        }
    }

    static func update(remainingSeconds: Int, name: String) {
        guard let activity = activity else { return }
        let state = FocusActivityAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            sessionName: name
        )
        Task {
            await activity.update(using: state)
        }
    }

    static func stop() {
        Task {
            await activity?.end(dismissalPolicy: .immediate)
        }
        activity = nil
    }
}
