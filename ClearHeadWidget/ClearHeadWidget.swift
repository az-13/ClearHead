import WidgetKit
import SwiftUI
import ActivityKit

struct ClearHeadWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusSessionAttributes.self) { context in
            // MARK: - LOCK SCREEN VIEW
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: context.state.isBreak ? "cup.and.saucer.fill" : "timer")
                        .foregroundColor(.indigo)
                    Text(context.state.isBreak ? "Break Time ☕" : "Focus Session")
                        .font(.headline)
                    Spacer()
                }
                
                Text(context.state.subject)
                    .font(.title2.bold())
                
                let minutes = context.state.timeRemaining / 60
                let seconds = context.state.timeRemaining % 60
                Text(String(format: "%d:%02d remaining", minutes, seconds))
                    .font(.system(size: 44, weight: .medium, design: .rounded))
                    .monospacedDigit()
                
                ProgressView(value: Double(context.state.timeRemaining) / 1500)
                    .tint(.indigo)
            }
            .padding()
            .activityBackgroundTint(.indigo.opacity(0.15))
            .widgetURL(URL(string: "clearhead://session"))
            
        } dynamicIsland: { context in
            // MARK: - DYNAMIC ISLAND
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .foregroundColor(.indigo)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    let m = context.state.timeRemaining / 60
                    let s = context.state.timeRemaining % 60
                    Text("\(m):\(String(format: "%02d", s))")
                        .font(.title2).monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.subject)
                        .font(.caption)
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                let m = context.state.timeRemaining / 60
                Text("\(m)m").monospacedDigit()
            } minimal: {
                Image(systemName: "timer")
            }
            .widgetURL(URL(string: "clearhead://session"))
            .keylineTint(.indigo)
        }
    }
}
