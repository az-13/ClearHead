import SwiftUI

/// Celebration + reflection screen shown inside the session cover when
/// the timer finishes. Saving calls `completeActive`, which clears the
/// active session and lets the cover dismiss automatically.
struct SessionCheckInView: View {
    @EnvironmentObject var store: SessionStore
    let session: FocusSession

    @State private var note = ""
    @State private var pop = false

    private var trimmedNote: String {
        note.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    celebration
                    reflectionCard
                    saveButton
                    Text("Your session is saved to History.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(24)
            }
        }
    }

    // MARK: - Celebration

    private var celebration: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.successGreen.opacity(0.15))
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(AppTheme.successGreen)
            }
            .scaleEffect(pop ? 1 : 0.3)
            .onAppear {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
                    pop = true
                }
            }

            Text("Well done!")
                .font(.largeTitle.bold())
            Text("\(session.minutes) minutes of focused work — that counts.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
    }

    // MARK: - Reflection

    private var reflectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("One thing you accomplished or learned")
                .font(.headline)

            ZStack(alignment: .topLeading) {
                if note.isEmpty {
                    Text("e.g. Solved 3 past paper questions")
                        .foregroundColor(.secondary.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                }
                TextEditor(text: $note)
                    .frame(minHeight: 110)
                    .padding(6)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .glassCard()
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            store.completeActive(
                what: trimmedNote.isEmpty ? "Focus session completed" : trimmedNote
            )
        } label: {
            Label("Save & Finish", systemImage: "checkmark.circle.fill")
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

struct SessionCheckInView_Previews: PreviewProvider {
    static var previews: some View {
        SessionCheckInView(session: FocusSession(name: "Maths", duration: 1500))
            .environmentObject(SessionStore())
    }
}
