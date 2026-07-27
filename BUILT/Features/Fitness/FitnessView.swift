import SwiftUI
import Charts

struct FitnessView: View {
    let profile: QuitProfile

    @State private var healthKit =
        HealthKitManager()

    @Environment(\.scenePhase)
    private var scenePhase

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
                        header

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
                    .padding(
                        .horizontal,
                        20
                    )
                    .padding(.top, 18)
                    .padding(.bottom, 36)
                }
                .refreshable {
                    await healthKit.refresh(
                        since: profile.quitDate
                    )
                }

                if healthKit.isLoading
                    && healthKit.hasRequestedAuthorization {
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
        .onChange(
            of: scenePhase
        ) { _, newPhase in
            guard newPhase == .active,
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
    }

    private var header: some View {
        HStack(
            alignment: .bottom
        ) {
            SectionHeader(
                eyebrow:
                    "Fitness identity",
                title:
                    "Protect what you built."
            )

            Spacer()

            if healthKit.hasRequestedAuthorization {
                Button {
                    Task {
                        await healthKit.refresh(
                            since: profile.quitDate
                        )
                    }
                } label: {
                    Image(
                        systemName:
                            "arrow.clockwise"
                    )
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .frame(
                        width: 44,
                        height: 44
                    )
                    .background(
                        .ultraThinMaterial,
                        in: Circle()
                    )
                    .overlay {
                        Circle()
                            .stroke(
                                BuiltTheme.hairline,
                                lineWidth: 1
                            )
                    }
                }
                .disabled(healthKit.isLoading)
                .accessibilityLabel(
                    "Refresh fitness data"
                )
            }
        }
    }

    private var connectedContent: some View {
        VStack(
            alignment: .leading,
            spacing: 26
        ) {
            identityHero

            if let errorMessage =
                healthKit.errorMessage {
                errorCard(
                    message: errorMessage
                )
            }

            metricsGrid
            weeklyChart
            trainingOverview
            recentWorkouts
        }
    }

    private var identityHero: some View {
        VStack(
            alignment: .leading,
            spacing: 18
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
                ? """
                1 workout completed by the version of you that does not smoke.
                """
                : """
                \(metrics.totalWorkouts) workouts completed by the version of you that does not smoke.
                """
            )
            .font(
                .system(
                    size: 34,
                    weight: .bold
                )
            )
            .tracking(-1.1)
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            HStack(spacing: 10) {
                Label(
                    "\(metrics.workoutsThisWeek) this week",
                    systemImage: "calendar"
                )

                Text("·")

                Label(
                    metrics.mostFrequentWorkout,
                    systemImage: "trophy.fill"
                )
            }
            .font(
                .system(
                    size: 13,
                    weight: .medium
                )
            )
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .lineLimit(1)
            .minimumScaleFactor(0.75)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 24)
    }

    private var metricsGrid: some View {
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
                icon: "clock.fill",
                value:
                    "\(metrics.totalWorkoutMinutes)",
                title:
                    "Workout minutes",
                footnote:
                    "Time deliberately spent training"
            )

            FitnessMetricCard(
                icon: "flame.fill",
                value:
                    "\(Int(healthKit.totalActiveKilocalories.rounded()))",
                title:
                    "Active kcal",
                footnote:
                    "Apple Health active energy since quitting"
            )

            FitnessMetricCard(
                icon: "calendar.badge.checkmark",
                value:
                    "\(metrics.currentStreak)",
                title:
                    "Training streak",
                footnote:
                    metrics.currentStreak == 1
                    ? "1 consecutive training day"
                    : "\(metrics.currentStreak) consecutive training days"
            )
        }
    }

    private var weeklyChart: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            HStack {
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text("LAST SEVEN DAYS")
                        .font(
                            .system(
                                size: 11,
                                weight: .bold
                            )
                        )
                        .tracking(1.6)
                        .foregroundStyle(
                            BuiltTheme.accent
                        )

                    Text("Training volume")
                        .font(
                            .system(
                                size: 22,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )
                }

                Spacer()

                Text(
                    """
                    \(metrics.lastSevenDays.reduce(0) { $0 + $1.workoutMinutes }) min
                    """
                )
                .font(
                    .system(
                        size: 12,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
            }

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
                            BuiltTheme.accentSoft
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(6)
            }
            .frame(height: 220)
            .chartYAxis {
                AxisMarks(
                    position: .leading
                ) { _ in
                    AxisGridLine()
                        .foregroundStyle(
                            Color.white.opacity(0.08)
                        )

                    AxisValueLabel()
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                }
            }
            .chartXAxis {
                AxisMarks(
                    values: .stride(by: .day)
                ) { _ in
                    AxisValueLabel(
                        format: .dateTime
                            .weekday(.narrow)
                    )
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                }
            }
        }
        .builtCard(padding: 20)
    }

    private var trainingOverview: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            Text("TRAINING OVERVIEW")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1.7)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            overviewRow(
                icon: "calendar",
                title: "Workouts this week",
                value: "\(metrics.workoutsThisWeek)"
            )

            Divider()
                .overlay(
                    BuiltTheme.hairline
                )

            overviewRow(
                icon: "flame",
                title: "Longest training streak",
                value:
                    "\(metrics.longestStreak) day\(metrics.longestStreak == 1 ? "" : "s")"
            )

            Divider()
                .overlay(
                    BuiltTheme.hairline
                )

            overviewRow(
                icon: "figure.run",
                title: "Apple Exercise Time",
                value:
                    "\(Int(healthKit.totalExerciseMinutes.rounded())) min"
            )

            Divider()
                .overlay(
                    BuiltTheme.hairline
                )

            overviewRow(
                icon: "trophy",
                title: "Most frequent workout",
                value:
                    metrics.mostFrequentWorkout
            )
        }
        .builtCard(padding: 20)
    }

    private var recentWorkouts: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            SectionHeader(
                eyebrow: "Evidence",
                title: "Recent workouts",
                trailingText:
                    healthKit.workouts.isEmpty
                    ? nil
                    : "\(healthKit.workouts.count) total"
            )

            if healthKit.workouts.isEmpty {
                emptyWorkoutState
            } else {
                VStack(spacing: 10) {
                    ForEach(
                        healthKit.workouts.prefix(10)
                    ) { workout in
                        WorkoutRow(
                            workout: workout
                        )
                    }
                }
            }
        }
    }

    private var emptyWorkoutState: some View {
        VStack(spacing: 15) {
            Image(
                systemName:
                    "heart.text.clipboard"
            )
            .font(
                .system(
                    size: 36,
                    weight: .light
                )
            )
            .foregroundStyle(
                BuiltTheme.accent
            )

            Text("No workouts found")
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            Text(
                """
                Record a workout in Apple Fitness or another Health-compatible app, then pull down to refresh. Apple protects read-permission privacy, so an empty result can also mean access was not granted.
                """
            )
            .font(.system(size: 14))
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .multilineTextAlignment(
                .center
            )
        }
        .frame(
            maxWidth: .infinity
        )
        .builtCard(padding: 26)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.22)
                .ignoresSafeArea()

            ProgressView()
                .tint(
                    BuiltTheme.accent
                )
                .controlSize(.large)
                .padding(26)
                .background(
                    .ultraThinMaterial,
                    in: Circle()
                )
        }
        .allowsHitTesting(false)
    }

    private func overviewRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(width: 26)

            Text(title)
                .font(
                    .system(
                        size: 14,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary.opacity(0.88)
                )

            Spacer()

            Text(value)
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .multilineTextAlignment(
                    .trailing
                )
        }
    }

    private func errorCard(
        message: String
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: 13
        ) {
            Image(
                systemName:
                    "exclamationmark.triangle.fill"
            )
            .foregroundStyle(
                BuiltTheme.danger
            )

            Text(message)
                .font(
                    .system(
                        size: 13,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            Spacer()
        }
        .builtCard(padding: 16)
    }
}
