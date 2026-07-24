import SwiftUI
import SwiftData

struct RootView: View {
    @Query(sort: \QuitProfile.createdAt)
    private var profiles: [QuitProfile]

    var body: some View {
        Group {
            if let profile = profiles.first {
                MainTabView(profile: profile)
                    .transition(
                        .opacity.combined(
                            with: .scale(scale: 0.985)
                        )
                    )
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(
            .easeInOut(duration: 0.35),
            value: profiles.isEmpty
        )
    }
}

private struct MainTabView: View {
    let profile: QuitProfile

    var body: some View {
        TabView {
            TodayView(profile: profile)
                .tabItem {
                    Label(
                        "Today",
                        systemImage: "circle.inset.filled"
                    )
                }

            RescueView(profile: profile)
                .tabItem {
                    Label(
                        "Rescue",
                        systemImage: "waveform.path.ecg"
                    )
                }

            ProofView()
                .tabItem {
                    Label(
                        "Proof",
                        systemImage: "photo.stack"
                    )
                }

            InsightsView()
                .tabItem {
                    Label(
                        "Insights",
                        systemImage: "chart.xyaxis.line"
                    )
                }
        }
        .tint(BuiltTheme.accent)
        .toolbarBackground(
            .ultraThinMaterial,
            for: .tabBar
        )
        .toolbarBackground(
            .visible,
            for: .tabBar
        )
    }
}
