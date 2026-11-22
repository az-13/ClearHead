import SwiftUI

/// Full-screen active session: progress ring with a big countdown,
/// one gentle encouraging line, and a subtle emergency exit.
/// When the timer reaches zero the view swaps to the check-in phase.
struct LockedSessionView: View {
    @EnvironmentObject var store: SessionStore
    @State private var showEmergencyAlert = false
    @State private var phase: Phase = .active

    private enum Phase { case active, checkIn }

    let session: FocusSession
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let quotes = [
        "You started this. See it through.",
        "Small minutes still count.",
        "Your future self is grateful.",
        "Stay with this, one breath at a time.",
        "Distractions wait. This moment doesn't."
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.nightTop, AppTheme.nightBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            switch phase {
            case .active:
                activeBody
            case .checkIn:
                SessionCheckInView(session: session)
            }
        }
        .onReceive(timer) { _ in
            if remaining <= 0, phase == .active {
                withAnimation(.easeInOut) {
                    phase = .checkIn
                }
            } else if phase == .active, #available(iOS 16.1, *) {
                LiveActivityManager.update(remainingSeconds: Int(remaining), name: session.name)
            }
        }
        .alert("Leave this session early?", isPresented: $showEmergencyAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Leave anyway", role: .destructive) {
                store.emergencyExitActive()
            }
        } message: {
            Text("This session won't count toward your streak or stats. Only use this in a real emergency.")
        }
    }

    // MARK: - Active phase

    private var activeBody: some View {
        VStack(spacing: 22) {
            Text("FOCUS SESSION")
                .font(.caption.weight(.semibold))
                .tracking(3)
                .foregroundColor(.white.opacity(0.75))
                .padding(.top, 24)

            Text(session.name)
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ring

            Text(quote)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            Spacer()

            Button {
                showEmergencyAlert = true
            } label: {
                Label("Emergency exit", systemImage: "exclamationmark.triangle")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.bottom, 28)
        }
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.15),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round))
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color.white, Color(red: 0.82, green: 0.78, blue: 1.0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            VStack(spacing: 6) {
                Text(session.formattedRemaining)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)
                Text("remaining")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: 240, height: 240)
    }

    // MARK: - Computed timing

    private var remaining: TimeInterval {
        guard let start = session.startTime else { return session.duration }
        return max(0, session.duration - Date().timeIntervalSince(start))
    }

    private var progress: Double {
        guard session.duration > 0 else { return 0 }
        return min(1, max(0, 1 - remaining / session.duration))
    }

    private var quote: String {
        let minuteIndex = Int(remaining / 60)
        return quotes[minuteIndex % quotes.count]
    }
}
