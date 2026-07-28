import SwiftUI
import Charts
import UIKit

struct FitnessView: View {
    let profile: QuitProfile

    @State private var healthKit =
        HealthKitManager()

    @Environment(\.scenePhase)
    private var scenePhase

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @Environment(\.openURL)
    private var openURL

    private var metrics:
        WorkoutMetrics {
        WorkoutMetrics(
            workouts: healthKit.workouts
        )
    }

    private var metricColumns:
        [GridItem] {
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
                        spacing:
                            BuiltTheme.Spacing
                                .xLarge
                    ) {
                        header

                        if !healthKit
                            .hasRequestedAuthorization {
                            HealthKitPermissionView(
                                isAvailable:
                                    healthKit
                                        .isAvailable,
                                isWorking:
                                    healthKit
                                        .isLoading,
                                errorMessage:
                                    healthKit
                                        .errorMessage
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
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await healthKit.refresh(
                        since:
                            profile.quitDate
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
        .onChange(
            of: profile.quitDate
        ) { _, newDate in
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
                    since:
                        profile.quitDate
                )
            }
        }
    }

    private var header: some View {
        HStack(
            alignment: .center,
            spacing: BuiltTheme.Spacing.medium
        ) {
            SectionHeader(
                eyebrow:
                    "Fitness identity",
                title:
                    "Protect what you built."
            )

            Spacer()

            BuiltIconButton(
                systemName:
                    "arrow.clockwise",
                accessibilityLabel:
                    "Refresh fitness data",
                isEnabled:
                    !healthKit.isLoading
            ) {
                Task {
                    await healthKit.refresh(
                        since:
                            profile.quitDate
                    )
                }
            }
        }
    }

    private var connectedContent:
        some View {
        VStack(
            alignment: .leading,
            spacing:
                BuiltTheme.Spacing.xLarge
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
            } else if healthKit
                .workouts.isEmpty {
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

            metricsGrid
            weeklyChart
            trainingOverview
            recentWorkouts
        }
    }

    private var identityHero: some View {
        BuiltHeroPanel(
            eyebrow:
                "Smoke-free training",
            title:
                metrics.totalWorkouts == 1
                ? "1 workout completed by the version of you that does not smoke."
                : "\(metrics.totalWorkouts) workouts completed by the version of you that does not smoke.",
            message:
                "\(metrics.workoutsThisWeek) this week · \(metrics.mostFrequentWorkout)",
            systemName:
                "figure.strengthtraining.traditional",
            trailingValue:
                "\(metrics.currentStreak)",
            trailingLabel:
                "Day streak"
        )
    }

    private var metricsGrid: some View {
        LazyVGrid(
            columns: metricColumns,
            spacing: 12
        ) {
            FitnessMetricCard(
                icon:
                    "figure.strengthtraining.traditional",
                value:
                    "\(metrics.totalWorkouts)",
                title: "Workouts",
                footnote:
                    "Completed since quitting"
            )

            FitnessMetricCard(
                icon: "clock.fill",
                value:
                    "\(metrics.totalWorkoutMinutes)",
                title:
                    "Workout minutes",
                footnote:
                    "Total recorded training"
            )

            FitnessMetricCard(
                icon: "flame.fill",
                value:
                    "\(Int(healthKit.totalActiveKilocalories.rounded()))",
                title:
                    "Active kcal",
                footnote:
                    "Apple Health total"
            )

            FitnessMetricCard(
                icon:
                    "calendar.badge.checkmark",
                value:
                    "\(metrics.workoutsThisWeek)",
                title: "This week",
                footnote:
                    "Current training rhythm"
            )

            FitnessMetricCard(
                icon:
                    "arrow.triangle.2.circlepath",
                value:
                    "\(metrics.currentStreak)",
                title:
                    "Current streak",
                footnote:
                    "Consecutive training days"
            )

            FitnessMetricCard(
                icon: "trophy.fill",
                value:
                    "\(metrics.longestStreak)",
                title:
                    "Longest streak",
                footnote:
                    "Your best rhythm"
            )
        }
    }

    private var weeklyChart: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.large
        ) {
            SectionHeader(
                eyebrow:
                    "Last seven days",
                title:
                    "Training volume",
                trailingText:
                    "\(metrics.lastSevenDays.reduce(0) { $0 + $1.workoutMinutes }) min"
            )

            Chart(
                metrics.lastSevenDays
            ) { summary in
                BarMark(
                    x: .value(
                        "Day",
                        summary.date,
                        unit: .day
                    ),
                    y: .value(
                        "Minutes",
                        summary.workoutMinutes
                    )
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            BuiltTheme.accent,
                            BuiltTheme
                                .accentSoft
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(6)
                .accessibilityLabel(
                    summary.date.formatted(
                        .dateTime
                        .weekday(.wide)
                    )
                )
                .accessibilityValue(
                    "\(summary.workoutMinutes) workout minutes"
                )
            }
            .frame(height: 220)
            .chartYAxis {
                AxisMarks(
                    position: .leading
                ) { _ in
                    AxisGridLine()
                        .foregroundStyle(
                            Color.white
                                .opacity(0.08)
                        )

                    AxisValueLabel()
                        .foregroundStyle(
                            BuiltTheme
                                .textSecondary
                        )
                }
            }
            .chartXAxis {
                AxisMarks(
                    values:
                        .stride(by: .day)
                ) { _ in
                    AxisValueLabel(
                        format:
                            .dateTime
                            .weekday(.narrow)
                    )
                    .foregroundStyle(
                        BuiltTheme
                            .textSecondary
                    )
                }
            }
        }
        .builtCard(padding: 20)
    }

    private var trainingOverview:
        some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            SectionHeader(
                eyebrow:
                    "Training overview",
                title:
                    "The pattern behind the work"
            )

            overviewRow(
                icon: "trophy.fill",
                title:
                    "Most frequent workout",
                value:
                    metrics
                        .mostFrequentWorkout
            )

            Divider()
                .overlay(
                    BuiltTheme.hairline
                )

            overviewRow(
                icon: "figure.run",
                title:
                    "Apple Exercise Time",
                value:
                    "\(Int(healthKit.totalExerciseMinutes.rounded())) min"
            )

            if let lastUpdated =
                healthKit.lastUpdated {
                Divider()
                    .overlay(
                        BuiltTheme.hairline
                    )

                overviewRow(
                    icon:
                        "arrow.clockwise",
                    title:
                        "Last refreshed",
                    value:
                        lastUpdated.formatted(
                            date: .omitted,
                            time: .shortened
                        )
                )
            }
        }
        .builtCard(padding: 20)
    }

    private var recentWorkouts:
        some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            SectionHeader(
                eyebrow: "History",
                title:
                    "Recent workouts",
                trailingText:
                    healthKit.workouts.isEmpty
                    ? nil
                    : "\(healthKit.workouts.count) total"
            )

            if healthKit.workouts.isEmpty {
                BuiltEmptyState(
                    systemName:
                        "figure.run.circle",
                    title:
                        "Your next workout starts the record",
                    message:
                        "Record a workout in Apple Fitness or another Health-compatible app, then pull down to refresh.",
                    actionTitle:
                        "Refresh",
                    action: refresh
                )
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(
                        healthKit.workouts
                            .prefix(10)
                    ) { workout in
                        WorkoutRow(
                            workout: workout
                        )
                    }
                }
            }
        }
    }

    private var loadingOverlay:
        some View {
        ZStack {
            Color.black.opacity(0.24)
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
            value:
                healthKit.isLoading
        )
    }

    private func overviewRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        Group {
            if dynamicTypeSize
                .isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing:
                        BuiltTheme.Spacing.small
                ) {
                    Label(
                        title,
                        systemImage: icon
                    )
                    .font(
                        .subheadline
                        .weight(.medium)
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                            .opacity(0.90)
                    )

                    Text(value)
                        .font(
                            .headline
                            .weight(.semibold)
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )
                }
            } else {
                HStack(
                    spacing:
                        BuiltTheme.Spacing.medium
                ) {
                    Image(systemName: icon)
                        .foregroundStyle(
                            BuiltTheme.accent
                        )
                        .frame(width: 28)
                        .accessibilityHidden(
                            true
                        )

                    Text(title)
                        .font(
                            .subheadline
                            .weight(.medium)
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                                .opacity(0.90)
                        )

                    Spacer()

                    Text(value)
                        .font(
                            .subheadline
                            .weight(.semibold)
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )
                        .multilineTextAlignment(
                            .trailing
                        )
                }
            }
        }
        .accessibilityElement(
            children: .combine
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
                UIApplication
                    .openSettingsURLString
        ) else {
            return
        }

        openURL(settingsURL)
    }
}
