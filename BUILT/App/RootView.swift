import SwiftUI
import SwiftData

struct RootView: View {
    @Query(sort: \QuitProfile.createdAt)
    private var profiles: [QuitProfile]

    @Environment(\.scenePhase)
    private var scenePhase

    @State private var router = AppRouter()

    var body: some View {
        Group {
            if let profile = profiles.first {
                MainTabView(
                    profile: profile,
                    router: router
                )
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
        .onOpenURL { url in
            router.handle(url)
        }
        .task {
            consumePendingNotificationRoute()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .builtNotificationRouteDidChange
            )
        ) { _ in
            consumePendingNotificationRoute()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                consumePendingNotificationRoute()
            }
        }
    }

    private func consumePendingNotificationRoute() {
        guard let url = NotificationRouteStore.consume() else {
            return
        }

        router.handle(url)
    }
}

private struct MainTabView: View {
    let profile: QuitProfile

    @Bindable var router: AppRouter

    @Query(sort: \CravingEntry.createdAt)
    private var cravings: [CravingEntry]

    @Query(sort: \RewardGoal.createdAt)
    private var rewardGoals: [RewardGoal]

    @Environment(\.scenePhase)
    private var scenePhase

    private var widgetSyncSignature: String {
        let cravingSignature = cravings.map { craving in
            "\(craving.persistentModelID)-\(craving.outcomeRawValue)-\(craving.createdAt.timeIntervalSince1970)"
        }
        .joined(separator: "|")

        let rewardSignature = rewardGoals.map { goal in
            [
                String(describing: goal.persistentModelID),
                goal.title,
                String(goal.targetAmount),
                String(goal.bankedAmount),
                String(goal.automaticSavingsBaseline),
                String(goal.usesAutomaticSavings),
                String(goal.isActive),
                String(goal.completedAt?.timeIntervalSince1970 ?? 0),
                String(goal.claimedAt?.timeIntervalSince1970 ?? 0)
            ]
            .joined(separator: "-")
        }
        .joined(separator: "|")

        return [
            String(profile.quitDate.timeIntervalSince1970),
            String(profile.cigarettesPerDay),
            String(profile.cigarettesPerPack),
            String(profile.packPrice),
            profile.currencyCode,
            profile.identityStatement,
            cravingSignature,
            rewardSignature
        ]
        .joined(separator: "#")
    }

    private var notificationSignature: String {
        [
            String(profile.quitDate.timeIntervalSince1970),
            profile.identityStatement
        ]
        .joined(separator: "#")
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            TodayView(profile: profile)
                .tag(AppTab.today)
                .tabItem {
                    Label(
                        "Today",
                        systemImage: "circle.inset.filled"
                    )
                }

            RescueView(profile: profile)
                .tag(AppTab.rescue)
                .tabItem {
                    Label(
                        "Rescue",
                        systemImage: "waveform.path.ecg"
                    )
                }

            ProofAccessView()
                .tag(AppTab.proof)
                .tabItem {
                    Label(
                        "Proof",
                        systemImage: "photo.stack"
                    )
                }

            FitnessAccessView(profile: profile)
                .tag(AppTab.fitness)
                .tabItem {
                    Label(
                        "Fitness",
                        systemImage: "figure.strengthtraining.traditional"
                    )
                }

            ProgressHubView(
                profile: profile,
                selectedSection: $router.selectedGrowthSection
            )
            .tag(AppTab.growth)
            .tabItem {
                Label(
                    "Growth",
                    systemImage: "chart.line.uptrend.xyaxis"
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
        .fullScreenCover(
            isPresented: $router.presentsRescue
        ) {
            CravingSessionView(profile: profile)
        }
        .task {
            syncWidget()
            await rescheduleNotifications()
        }
        .onChange(of: widgetSyncSignature) { _, _ in
            syncWidget()
        }
        .onChange(of: notificationSignature) { _, _ in
            Task {
                await rescheduleNotifications()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                syncWidget()
            }
        }
    }

    private func syncWidget() {
        WidgetSyncService.sync(
            profile: profile,
            cravings: cravings,
            rewardGoals: rewardGoals
        )
    }

    private func rescheduleNotifications() async {
        let preferences = NotificationPreferencesStore.load()
        let scheduleProfile = NotificationScheduleProfile(
            quitDate: profile.quitDate,
            identityStatement: profile.identityStatement
        )

        await NotificationManager.shared.schedule(
            preferences: preferences,
            profile: scheduleProfile
        )
    }
}
