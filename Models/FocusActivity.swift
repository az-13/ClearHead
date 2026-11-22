import Foundation
import ActivityKit
import SwiftUI

@available(iOS 16.2, *)
struct FocusActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
        var sessionName: String
    }

    public var sessionName: String
    public var totalSeconds: Int
}

// MARK: - Dynamic Island & Lock Screen Views
@available(iOS 16.2, *)
extension FocusActivityAttributes {
    
    struct DynamicIsland: Widget {
        var body: some WidgetConfiguration {
            ActivityConfiguration(for: FocusActivityAttributes.self) { context in
                // Lock Screen banner view
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.indigo)
                        Text(context.attributes.sessionName)
                            .font(.headline)
                        Spacer()
                    }
                    HStack {
                        Text(timeString(from: context.state.remainingSeconds))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Spacer()
                    }
                }
                .padding()
                .background(.indigo.opacity(0.1).gradient)
            } dynamicIsland: { context in
                DynamicIsland {
                    // Expanded Dynamic Island — left side
                    DynamicIslandLeading {
                        Image(systemName: "timer")
                            .foregroundColor(.white)
                    }
                    // Expanded Dynamic Island — right side
                    DynamicIslandTrailing {
                        Text(timeString(from: context.state.remainingSeconds))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.white)
                    }
                } compactLeading: {
                    // Compact (small) Dynamic Island — left
                    Image(systemName: "timer")
                        .foregroundColor(.white)
                } compactTrailing: {
                    // Compact (small) Dynamic Island — right
                    Text(timeStringShort(from: context.state.remainingSeconds))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.white)
                } minimal: {
                    // Minimal (even smaller) view
                    Image(systemName: "timer")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // Helper: Format MM:SS
    private static func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    // Helper: Short format for compact island (e.g. "5m" or "30s")
    private static func timeStringShort(from seconds: Int) -> String {
        if seconds >= 60 {
            return "\(seconds / 60)m"
        } else {
            return "\(seconds)s"
        }
    }
}

@available(iOS 16.2, *)
enum LiveActivityManager {
    private static var activity: Activity<FocusActivityAttributes>?

    static func start(name: String, totalSeconds: Int) {
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
            print("✅ ClearHead: Live Activity started — \(name), \(totalSeconds)s")
        } catch {
            print("❌ ClearHead: Failed to start Live Activity: \(error.localizedDescription)")
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
