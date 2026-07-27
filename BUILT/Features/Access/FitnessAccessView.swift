import SwiftUI

struct FitnessAccessView: View {
    let profile: QuitProfile

    @EnvironmentObject
    private var storeManager: StoreManager

    var body: some View {
        if storeManager.hasPro {
            FitnessView(profile: profile)
        } else {
            FreeFitnessView(profile: profile)
        }
    }
}

private struct FreeFitnessView: View {
    let profile: QuitProfile

    @State private var healthKit =
        HealthKitManager()

    @State private var showingPaywall = false

    @Environment(\.scenePhase)
    private var scenePhase

    @EnvironmentObject
    private var storeManager: StoreManager

    private var metrics: WorkoutMetrics {
        WorkoutMetrics(
            workouts: healthKit.workouts
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 26
                    ) {
                        SectionHeader(
                            eyebrow: "Fitness identity",
                            title: "Protect what you built."
                        )

                        if !healthKit.hasRequestedAuthorization {
                            HealthKitPermissionView(
                                isAvailable:
                                    healthKit.isAvailable,
                                isWorking:
                                    healthKit.isLoading,
                                errorMessage:
                                    healthKit.errorMessage
                            ) {
                                Task {
                                    await healthKit
                                        .requestAuthorization(
                                            since:
                                                profile.quitDate
                                        )
                                }
                            }
                        } else {
                            connectedContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 38)
                }
                .refreshable {
                    await healthKit.refresh(
                        since: profile.quitDate
                    )
                }

                if healthKit.isLoading
                    && healthKit.hasRequestedAuthorization {
                    ProgressView("Refreshing training…")
                        .padding(18)
                        .builtCard()
                }
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .task {
            await healthKit.prepare(
                since: profile.quitDate
            )
        }
        .onChange(of: profile.quitDate) {
            _, newDate in

            Task {
                await healthKit.prepare(
                    since: newDate
                )
            }
        }
        .onChange(of: scenePhase) {
            _, newPhase in

            guard
                newPhase == .active,
                healthKit.hasRequestedAuthorization
            else {
                return
            }

            Task {
                await healthKit.refresh(
                    since: profile.quitDate
                )
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(context: .fitness)
                .environmentObject(storeManager)
        }
    }

    private var connectedContent: some View {
        VStack(
            alignment: .leading,
            spacing: 24
        ) {
            identityHero

            if let errorMessage =
                healthKit.errorMessage {
                Text(errorMessage)
                    .font(
                        .system(
                            size: 13,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.danger
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .builtCard()
            }

            LazyVGrid(
                columns: [
                    GridItem(
                        .flexible(),
                        spacing: 12
                    ),
                    GridItem(
                        .flexible(),
                        spacing: 12
                    )
                ],
                spacing: 12
            ) {
                FitnessMetricCard(
                    icon:
                        "figure.strengthtraining.traditional",
                    value:
                        "\(metrics.totalWorkouts)",
                    title:
                        "Workouts",
                    footnote:
                        "Recorded since your quit date"
                )

                FitnessMetricCard(
                    icon:
                        "calendar.badge.checkmark",
                    value:
                        "\(metrics.workoutsThisWeek)",
                    title:
                        "This week",
                    footnote:
                        "Your current training rhythm"
                )
            }

            UpgradeCard(
                title:
                    "Unlock complete fitness intelligence",
                message:
                    "See active energy, training streaks, workout minutes, seven-day volume, favorite workout type, and recent workout history.",
                action: {
                    showingPaywall = true
                }
            )

            Text(
                "Connecting Apple Health is optional. Your smoke-free counter and Rescue remain available without it."
            )
            .font(.system(size: 12))
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .multilineTextAlignment(.center)
            .frame(
                maxWidth: .infinity
            )
        }
    }

    private var identityHero: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Text("SMOKE-FREE TRAINING")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1.9)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(
                metrics.totalWorkouts == 1
                ? "1 workout completed by the version of you that does not smoke."
                : "\(metrics.totalWorkouts) workouts completed by the version of you that does not smoke."
            )
            .font(
                .system(
                    size: 32,
                    weight: .bold
                )
            )
            .tracking(-1)
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            Text(
                "Your basic workout count stays free. Pro reveals the deeper pattern behind your training."
            )
            .font(.system(size: 14))
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 22)
    }
}
