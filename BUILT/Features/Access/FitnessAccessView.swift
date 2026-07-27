import SwiftUI
import UIKit

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

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @Environment(\.openURL)
    private var openURL

    @EnvironmentObject
    private var storeManager: StoreManager

    private var metrics: WorkoutMetrics {
        WorkoutMetrics(
            workouts: healthKit.workouts
        )
    }

    private var metricColumns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [
                GridItem(
                    .flexible(),
                    spacing: 12
                )
            ]
        }

        return [
            GridItem(
                .flexible(),
                spacing: 12
            ),
            GridItem(
                .flexible(),
                spacing: 12
            )
        ]
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
                            eyebrow:
                                "Fitness identity",
                            title:
                                "Protect what you built."
                        )

                        if !healthKit
                            .hasRequestedAuthorization {
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
                                                profile
                                                    .quitDate
                                        )
                                }
                            }
                        } else {
                            connectedContent
                        }
                    }
                    .padding(
                        .horizontal,
                        BuiltTheme.Spacing
                            .screenHorizontal
                    )
                    .padding(.top, 18)
                    .padding(.bottom, 38)
                }
                .refreshable {
                    await healthKit.refresh(
                        since: profile.quitDate
                    )
                }

                if healthKit.isLoading
                    && healthKit
                        .hasRequestedAuthorization {
                    loadingOverlay
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
                healthKit
                    .hasRequestedAuthorization
            else {
                return
            }

            Task {
                await healthKit.refresh(
                    since: profile.quitDate
                )
            }
        }
        .sheet(
            isPresented: $showingPaywall
        ) {
            PaywallView(context: .fitness)
                .environmentObject(
                    storeManager
                )
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
                BuiltStatusCard(
                    kind: .error,
                    title:
                        "Training data could not refresh",
                    message: errorMessage,
                    primaryActionTitle:
                        "Try again",
                    primaryAction: refresh,
                    secondaryActionTitle:
                        "Open Settings",
                    secondaryAction:
                        openAppSettings
                )
            } else if healthKit.workouts.isEmpty {
                BuiltStatusCard(
                    kind: .neutral,
                    title:
                        "No Apple Health workouts found",
                    message:
                        "Workouts recorded after your quit date will appear here. Apple protects read-permission privacy, so an empty result can also mean access is limited.",
                    primaryActionTitle:
                        "Refresh",
                    primaryAction: refresh,
                    secondaryActionTitle:
                        "Review Settings",
                    secondaryAction:
                        openAppSettings
                )
            }

            LazyVGrid(
                columns: metricColumns,
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
                feature: .fitnessIntelligence,
                action: {
                    showingPaywall = true
                }
            )

            Text(
                "Connecting Apple Health is optional. Your smoke-free counter and Rescue remain available without it."
            )
            .font(.footnote)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .multilineTextAlignment(.center)
            .frame(
                maxWidth: .infinity
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
    }

    private var identityHero: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            Text("SMOKE-FREE TRAINING")
                .font(
                    .caption
                    .weight(.bold)
                )
                .tracking(1.5)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(
                metrics.totalWorkouts == 1
                ? "1 workout completed by the version of you that does not smoke."
                : "\(metrics.totalWorkouts) workouts completed by the version of you that does not smoke."
            )
            .font(
                dynamicTypeSize.isAccessibilitySize
                ? .title2.weight(.bold)
                : .title.weight(.bold)
            )
            .tracking(
                dynamicTypeSize.isAccessibilitySize
                ? 0
                : -0.8
            )
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
            .font(.subheadline)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 22)
        .accessibilityElement(
            children: .combine
        )
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.20)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            BuiltLoadingCard(
                title:
                    "Refreshing Apple Health",
                message:
                    "Updating your smoke-free training totals."
            )
            .padding(.horizontal, 28)
        }
        .transition(.opacity)
        .builtAnimation(
            value: healthKit.isLoading
        )
    }

    private func refresh() {
        Task {
            await healthKit.refresh(
                since: profile.quitDate
            )
        }
    }

    private func openAppSettings() {
        guard let settingsURL = URL(
            string:
                UIApplication.openSettingsURLString
        ) else {
            return
        }

        openURL(settingsURL)
    }
}
