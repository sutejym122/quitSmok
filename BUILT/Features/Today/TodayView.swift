import SwiftUI
import SwiftData

struct TodayView: View {
    let profile: QuitProfile

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
                        VStack(spacing: 26) {
                            header

                            hero(
                                metrics: metrics
                            )

                            cravingButton

                            metricsGrid(
                                metrics: metrics
                            )

                            identityCard
                        }
                        .padding(
                            .horizontal,
                            20
                        )
                        .padding(.top, 12)
                        .padding(
                            .bottom,
                            34
                        )
                    }
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
    }

    private var header: some View {
        HStack {
            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text("BUILT.")
                    .font(
                        .system(
                            size: 18,
                            weight: .black
                        )
                    )
                    .tracking(2.2)
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                Text(
                    "BUILT, NOT BURNED"
                )
                .font(
                    .system(
                        size: 10,
                        weight: .semibold
                    )
                )
                .tracking(1.5)
                .foregroundStyle(
                    BuiltTheme.accent
                )
            }

            Spacer()

            Button {
                showingSettings = true
            } label: {
                Image(
                    systemName:
                        "slider.horizontal.3"
                )
                .font(
                    .system(
                        size: 16,
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
            .accessibilityLabel(
                "Open settings"
            )
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
                spacing: 14
            ) {
                Text("SMOKE-FREE")
                    .font(
                        .system(
                            size: 11,
                            weight: .bold
                        )
                    )
                    .tracking(2.2)
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                HStack(
                    alignment:
                        .firstTextBaseline,
                    spacing: 10
                ) {
                    Text(
                        "\(metrics.days)"
                    )
                    .font(
                        .system(
                            size: 78,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .tracking(-4)
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                    Text(
                        metrics.dayLabel
                    )
                    .font(
                        .system(
                            size: 16,
                            weight: .bold
                        )
                    )
                    .tracking(1.2)
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                }

                Text(
                    metrics.timerText
                )
                .font(
                    .system(
                        size: 28,
                        weight: .semibold,
                        design: .monospaced
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                        .opacity(0.92)
                )

                Text(
                    heroPhoto?.caption
                    ?? """
                    Add a gym photo in Proof and make your progress impossible to ignore.
                    """
                )
                .font(
                    .system(
                        size: 15,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                        .opacity(0.82)
                )
                .lineLimit(2)
                .padding(.top, 2)
            }
            .padding(24)
        }
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

                Text("I’m craving")

                Spacer()

                Image(
                    systemName:
                        "arrow.up.right"
                )
            }
        }
        .buttonStyle(
            BuiltPrimaryButtonStyle()
        )
    }

    private func metricsGrid(
        metrics: QuitMetrics
    ) -> some View {
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
                    : """
                    \(profile.slipCount) recorded slip\(profile.slipCount == 1 ? "" : "s")
                    """
            )
        }
    }

    private var identityCard: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            Text("YOUR REASON")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1.8)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(
                "“\(profile.identityStatement)”"
            )
            .font(
                .system(
                    size: 26,
                    weight: .semibold
                )
            )
            .tracking(-0.6)
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            Text(
                """
                You are not waiting to become a non-smoker. You are practicing that identity now.
                """
            )
            .font(.system(size: 14))
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
    }
}
