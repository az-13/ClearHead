import SwiftUI

/// Root gate: show the welcome flow on first launch, then the main
/// tab bar. While a session runs it opens full screen on top of either.
struct RootView: View {
    @EnvironmentObject var store: SessionStore
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        Group {
            if hasOnboarded {
                mainTabs
            } else {
                OnboardingView()
            }
        }
        .fullScreenCover(item: $store.activeSession) { session in
            LockedSessionView(session: session)
        }
    }

    private var mainTabs: some View {
        TabView {
            HomeView()
                .tabItem { Label("Focus", systemImage: "timer") }
            HistoryView()
                .tabItem { Label("History", systemImage: "chart.bar") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(.indigo)
    }
}
