import SwiftUI
import SwiftData

struct TodayView: View {
    let profile: QuitProfile

    @EnvironmentObject
    private var storeManager:
        StoreManager

    @Query(
        sort: \MotivationPhoto.createdAt,
        order: .reverse
    )
    private var photos: [MotivationPhoto]

    @Query(
        sort: \CravingEntry.createdAt,
        order: .reverse
    )
    private var cravings: [CravingEntry]

    @State private var showingRescue =
        false

    @State private var showingSettings =
        false

    @State private var showingPlan =
        false

    @State private var planProgress =
        BuiltPlanProgressStore
            .loadOrCreate(
                preferences:
                    OnboardingPreferencesStore
                        .load()
            )

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    private var heroPhoto: MotivationPhoto? {
        photos.first(
            where: { $0.isHero }
        ) ?? photos.first
    }

    private var defeatedCount: Int {
        cravings.filter {
            $0.outcome == .defeated
        }
        .count
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

                TimelineView(
                    .periodic(
                        from: .now,
                        by: 1
                    )
                ) { context in
                    let metrics = QuitMetrics(
                        profile: profile,
                        now: context.date
                    )

                    ScrollView {
                        VStack(
                            spacing:
                                BuiltTheme.Spacing
                                    .xLarge
                        ) {
                            header

                            hero(
                                metrics: metrics
                            )

                            cravingButton

                            planCard

                            metricsGrid(
                                metrics: metrics
                            )

                            identityCard
                        }
                        .padding(
                            .horizontal,
                            BuiltTheme.Spacing
                                .screenHorizontal
                        )
                        .padding(.top, 12)
                        .padding(.bottom, 38)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .fullScreenCover(
            isPresented: $showingRescue
        ) {
            CravingSessionView(
                profile: profile
            )
        }
        .sheet(
            isPresented: $showingSettings
        ) {
            SettingsView(
                profile: profile
            )
        }
        .sheet(
            isPresented: $showingPlan,
            onDismiss: {
                refreshPlanProgress()
            }
        ) {
            BuiltPlanView()
                .environmentObject(
                    storeManager
                )
        }
    }

    private var header: some View {
        HStack(
            alignment: .center,
            spacing: BuiltTheme.Spacing.medium
        ) {
            BuiltBrandLockup()
            Spacer()

            BuiltIconButton(
                systemName:
                    "slider.horizontal.3",
                accessibilityLabel:
                    "Open settings",
                accessibilityHint:
                    "Shows quit settings, notifications, privacy, and BUILT Pro"
            ) {
                showingSettings = true
            }
        }
    }

    private func hero(
        metrics: QuitMetrics
    ) -> some View {
        HeroPhotoView(
            photo: heroPhoto
        )
        .overlay(
            alignment: .bottomLeading
        ) {
            VStack(
                alignment: .leading,
                spacing: BuiltTheme.Spacing.medium
            ) {
                Text("SMOKE-FREE")
                    .font(
                        .caption
                        .weight(.bold)
                    )
                    .tracking(
                        dynamicTypeSize.isAccessibilitySize
                        ? 0.8
                        : 1.8
                    )
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(
                        alignment: .leading,
                        spacing: BuiltTheme.Spacing.xSmall
                    ) {
                        dayCount(metrics)
                        dayLabel(metrics)
                    }
                } else {
                    HStack(
                        alignment: .firstTextBaseline,
                        spacing: 10
                    ) {
                        dayCount(metrics)
                        dayLabel(metrics)
                    }
                }

                Text(metrics.timerText)
                    .font(
                        .title2
                        .weight(.semibold)
                        .monospacedDigit()
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                            .opacity(0.94)
                    )

                Text(
                    heroPhoto?.caption
                    ?? "Add a gym photo in Proof and make your progress impossible to ignore."
                )
                .font(
                    .subheadline
                    .weight(.medium)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                        .opacity(0.84)
                )
                .lineLimit(
                    dynamicTypeSize.isAccessibilitySize
                    ? nil
                    : 3
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }
            .padding(
                dynamicTypeSize.isAccessibilitySize
                ? 20
                : 24
            )
        }
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            "\(metrics.days) \(metrics.dayLabel.lowercased()) smoke-free"
        )
        .accessibilityValue(
            "\(metrics.hours) hours, \(metrics.minutes) minutes, \(metrics.seconds) seconds into the current day. \(heroPhoto?.caption ?? profile.identityStatement)"
        )
    }

    private func dayCount(
        _ metrics: QuitMetrics
    ) -> some View {
        Text("\(metrics.days)")
            .font(
                dynamicTypeSize.isAccessibilitySize
                ? .largeTitle
                    .weight(.bold)
                    .monospacedDigit()
                : .system(
                    size: 78,
                    weight: .bold,
                    design: .rounded
                )
            )
            .tracking(
                dynamicTypeSize.isAccessibilitySize
                ? 0
                : -4
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
    }

    private func dayLabel(
        _ metrics: QuitMetrics
    ) -> some View {
        Text(metrics.dayLabel)
            .font(
                .headline
                .weight(.bold)
            )
            .tracking(1.0)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
    }

    private var cravingButton: some View {
        Button {
            showingRescue = true
        } label: {
            HStack(spacing: 12) {
                Image(
                    systemName:
                        "bolt.heart.fill"
                )
                .accessibilityHidden(true)

                Text("I’m craving")

                Spacer()

                Image(
                    systemName:
                        "arrow.up.right"
                )
                .accessibilityHidden(true)
            }
        }
        .buttonStyle(
            BuiltPrimaryButtonStyle()
        )
        .accessibilityHint(
            "Immediately starts the free Craving Rescue flow"
        )
    }

    private func metricsGrid(
        metrics: QuitMetrics
    ) -> some View {
        LazyVGrid(
            columns: metricColumns,
            spacing: 12
        ) {
            MetricCard(
                icon: "nosign",
                title:
                    "Cigarettes rejected",
                value:
                    "\(metrics.cigarettesAvoided)",
                footnote:
                    "Based on your old daily average"
            )

            MetricCard(
                icon: "banknote.fill",
                title:
                    "Money protected",
                value:
                    metrics.moneySaved
                        .formatted(
                            .currency(
                                code:
                                    profile
                                        .currencyCode
                                        .uppercased()
                            )
                            .precision(
                                .fractionLength(
                                    0...2
                                )
                            )
                        ),
                footnote:
                    "Redirect it toward something you value"
            )

            MetricCard(
                icon:
                    "checkmark.shield.fill",
                title:
                    "Cravings defeated",
                value:
                    "\(defeatedCount)",
                footnote:
                    "Every logged win is proof"
            )

            MetricCard(
                icon: "flame.fill",
                title:
                    "Current identity",
                value:
                    profile.slipCount == 0
                    ? "Locked in"
                    : "Still building",
                footnote:
                    profile.slipCount == 0
                    ? "No recorded slips"
                    : "\(profile.slipCount) recorded slip\(profile.slipCount == 1 ? "" : "s")"
            )
        }
    }

    private var planCard: some View {
        BuiltPlanTodayCard(
            progress: planProgress,
            hasPro: storeManager.hasPro
        ) {
            showingPlan = true
        }
    }

    private func refreshPlanProgress() {
        planProgress =
            BuiltPlanProgressStore
                .loadOrCreate(
                    preferences:
                        OnboardingPreferencesStore
                            .load()
                )
    }

    private var identityCard: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            Text("YOUR REASON")
                .font(
                    .caption
                    .weight(.bold)
                )
                .tracking(1.5)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(
                "“\(profile.identityStatement)”"
            )
            .font(
                .title2
                .weight(.semibold)
            )
            .tracking(
                dynamicTypeSize.isAccessibilitySize
                ? 0
                : -0.4
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            Text(
                "You are not waiting to become a non-smoker. You are practicing that identity now."
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
}
