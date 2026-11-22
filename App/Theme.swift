import SwiftUI

/// # ClearHead design system
/// Modern, rounded, calm styling built only with iOS 16-safe APIs.
/// Big continuous corners, soft material cards, gentle gradients,
/// and a satisfying press-scale on every primary button.
enum AppTheme {

    // MARK: - Colours

    /// Adaptive background: light warm off-white in light mode,
    /// automatic dark charcoal in dark mode (no forced light style).
    static let background = Color(.systemBackground)

    /// Secondary adaptive fill behind cards and text fields.
    static let secondaryBackground = Color(.secondarySystemBackground)

    /// Deep indigo used on the active (full-screen) session.
    static let nightTop = Color(red: 0.18, green: 0.16, blue: 0.42)
    static let nightBottom = Color(red: 0.36, green: 0.28, blue: 0.66)

    /// Friendly accent gradient for buttons and highlights.
    static let brandGradient = LinearGradient(
        colors: [Color.indigo, Color.purple.opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGreen = Color(red: 0.20, green: 0.66, blue: 0.42)
    static let warningAmber = Color(red: 0.92, green: 0.55, blue: 0.16)

    // MARK: - Metrics

    static let cardRadius: CGFloat = 22
    static let controlRadius: CGFloat = 18

    static let softShadow = Color.black.opacity(0.07)
}

// MARK: - Card modifier

/// Soft material card with large rounded corners and a gentle shadow.
struct GlassCardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .shadow(color: AppTheme.softShadow, radius: 10, x: 0, y: 4)
    }
}

extension View {
    func glassCard(padding: CGFloat = 16) -> some View {
        modifier(GlassCardModifier(padding: padding))
    }
}

// MARK: - Primary button

/// Full-width indigo capsule that gently shrinks when pressed.
struct PrimaryButtonStyle: ButtonStyle {
    var disabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                Group {
                    if disabled {
                        Color.gray.opacity(0.35)
                    } else {
                        AppTheme.brandGradient
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.controlRadius, style: .continuous))
            .scaleEffect(configuration.isPressed && !disabled ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Small stat card

/// Reusable rounded stat block used on Home and History.
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var tint: Color = .indigo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(tint)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}
