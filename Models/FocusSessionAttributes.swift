import Foundation
import ActivityKit

struct FocusSessionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        let timeRemaining: Int
        let subject: String
        let isBreak: Bool
    }
    
    let sessionName: String
}
