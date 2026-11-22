import SwiftUI

/// First-launch welcome screen. Once "Get Started" is tapped the
/// `hasOnboarded` flag is saved and this screen never shows again.
struct OnboardingView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    private let features: [(icon: String, title: String, detail: String)] = [
        ("checkmark.circle.fill", "Set a session", "Name what you're working on and pick a length."),
        ("timer", "Stay present", "A calm full-screen timer keeps you in the zone."),
        ("pencil.and.list.clipboard", "Reflect afterwards", "Write one thing you accomplished — that's the habit."),
        ("hand.raised.fill", "You are in control", "You can leave early, but honest exits are marked as such.")
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 24)

                    // MARK: - Brand badge
                    ZStack {
                        Circle()
                            .fill(AppTheme.brandGradient)
                            .frame(width: 110, height: 110)
                            .shadow(color: .indigo.opacity(0.35), radius: 18, x: 0, y: 8)
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                    }

                    VStack(spacing: 10) {
                        Text("ClearHead")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Your quiet space to focus, not force.")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // MARK: - Feature list
                    VStack(spacing: 14) {
                        ForEach(features, id: \.title) { feature in
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: feature.icon)
                                    .font(.title3)
                                    .foregroundColor(.indigo)
                                    .frame(width: 30)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.title)
                                        .font(.headline)
                                    Text(feature.detail)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .glassCard(padding: 14)
                        }
                    }
                    .padding(.horizontal, 4)

                    // MARK: - CTA
                    Button {
                        withAnimation {
                            hasOnboarded = true
                        }
                    } label: {
                        Text("Get Started")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 8)

                    Text("No account. No ads. Everything stays on your device.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(28)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(SessionStore())
    }
}
