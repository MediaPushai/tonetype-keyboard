import SwiftUI

/// Main entry point for the ToneType app
@main
struct ToneTypeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

/// Root view that handles navigation between onboarding and main app
struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: appState.hasCompletedOnboarding)
    }
}

/// Main tab view for the app after onboarding
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DemoView()
                .tabItem {
                    Label("Try It", systemImage: "sparkles")
                }
                .tag(0)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
        .tint(Color.accentColor)
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
