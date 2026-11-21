import SwiftUI

/// Full-screen active session: big countdown, subject name,
/// one emergency-exit button. When the timer ends, the check-in sheet opens.
struct LockedSessionView: View {
    @EnvironmentObject var store: SessionStore
    @State private var showEmergencyAlert = false
    @State private var finished = false

    let session: FocusSession
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.indigo.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("FOCUS ACTIVE")
                    .font(.headline)
                    .tracking(3)
                    .foregroundColor(.white.opacity(0.8))

                Text(session.name)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                Text(timeString)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Stay with this. You've got this.")
                    .foregroundColor(.white.opacity(0.85))

                Spacer()

                Button(role: .destructive) {
                    showEmergencyAlert = true
                } label: {
                    Label("Emergency exit", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.bottom)
            }
            .padding()
        }
        .onReceive(timer) { _ in
            if remaining <= 0, !finished {
                finished = true
            }
        }
        .alert("Leave this session early?", isPresented: $showEmergencyAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Leave anyway", role: .destructive) {
                store.emergencyExitActive()
            }
        } message: {
            Text("This session won't count toward your focus history. Only use this in a real emergency.")
        }
        .sheet(isPresented: $finished) {
            CheckInView()
        }
    }

    private var remaining: TimeInterval {
        guard let start = session.startTime else { return session.duration }
        return max(0, session.duration - Date().timeIntervalSince(start))
    }

    private var timeString: String {
        let total = Int(remaining)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
