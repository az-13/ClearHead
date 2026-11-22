import Foundation
import ActivityKit

@MainActor
class LiveActivityManager {
    static let shared = LiveActivityManager()
    private init() {}
    
    var currentActivity: Activity<FocusSessionAttributes>?
    
    func startActivity(subject: String, duration: Int = 1500) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities not enabled")
            return
        }
        
        let attributes = FocusSessionAttributes(sessionName: "Study Session")
        let initialState = FocusSessionAttributes.ContentState(
            timeRemaining: duration,
            subject: subject,
            isBreak: false
        )
        
        do {
            currentActivity = try await Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            print("✅ Live Activity started")
        } catch {
            print("❌ Failed: \(error.localizedDescription)")
        }
    }
    
    func updateTimeRemaining(_ remaining: Int, subject: String, isBreak: Bool = false) async {
        guard let activity = currentActivity else { return }
        
        let newState = FocusSessionAttributes.ContentState(
            timeRemaining: remaining,
            subject: subject,
            isBreak: isBreak
        )
        
        await activity.update(.init(state: newState, staleDate: nil))
    }
    
    func endActivity() async {
        guard let activity = currentActivity else { return }
        
        let finalState = FocusSessionAttributes.ContentState(
            timeRemaining: 0,
            subject: "Session Complete ✅",
            isBreak: false
        )
        
        await activity.end(
            .init(state: finalState, staleDate: nil),
            dismissalPolicy: .immediate
        )
        currentActivity = nil
    }
}
