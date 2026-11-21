import SwiftUI

/// Bottom tab bar: Focus, History, Settings.
/// While a session runs it opens full screen on top.
struct RootView: View {
    @EnvironmentObject var store: SessionStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Focus", systemImage: "timer") }
            HistoryView()
                .tabItem { Label("History", systemImage: "chart.bar") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(.indigo)
        .fullScreenCover(item: $store.activeSession) { session in
            LockedSessionView(session: session)
        }
    }
}
