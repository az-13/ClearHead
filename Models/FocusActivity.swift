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

// MARK: - Dynamic Island & Lock Screen View
@available(iOS 16.2, *)
struct FocusActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            // Lock Screen banner
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
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .foregroundColor(.white)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timeString(from: context.state.remainingSeconds))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.white)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.white)
            } compactTrailing: {
                Text(timeStringShort(from: context.state.remainingSeconds))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.white)
            }
        }
    }
    
    private static func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private static func timeStringShort(from seconds: Int) -> String {
        if seconds >= 60 {
            return "\(seconds / 60)m"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Live Activity Manager
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
        await activity?.end(dismissalPolicy: .immediate)
        activity = nil
    }
}
