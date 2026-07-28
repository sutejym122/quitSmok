import SwiftUI

struct RecoveryTimelineView: View {
    let profile: QuitProfile

    @State private var celebration:
        CelebrationMoment?

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                TimelineView(
                    .periodic(
                        from: .now,
                        by: 60
                    )
                ) { context in
                    let snapshot =
                        RecoveryTimelineService
                            .snapshot(
                                quitDate:
                                    profile.quitDate,
                                now: context.date
                            )

                    ScrollView {
                        VStack(
                            alignment: .leading,
                            spacing:
                                BuiltTheme.Spacing
                                    .xLarge
                        ) {
                            SectionHeader(
                                eyebrow:
                                    "Body recovery",
                                title:
                                    "Your body is rebuilding."
                            )

                            recoveryHero(snapshot)
                            timeline(snapshot)
                            disclaimer
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
                }
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .task(id: profile.quitDate) {
            guard
                celebration == nil,
                let milestone =
                    RecoveryCelebrationStore
                        .consumeNewestUnseen(
                            quitDate:
                                profile.quitDate
                        )
            else {
                return
            }

            celebration =
                .recovery(milestone)
        }
        .overlay {
            if let celebration {
                CelebrationOverlay(
                    moment: celebration
                ) {
                    self.celebration = nil
                }
                .zIndex(10)
            }
        }
    }

    private func recoveryHero(
        _ snapshot:
            RecoveryTimelineSnapshot
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.large
        ) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing:
                        BuiltTheme.Spacing.large
                ) {
                    RecoveryProgressRing(
                        progress:
                            snapshot
                                .progressToNext,
                        completedCount:
                            snapshot
                                .completedCount
                    )

                    recoveryCopy(snapshot)
                }
            } else {
                HStack(
                    alignment: .center,
                    spacing:
                        BuiltTheme.Spacing.large
                ) {
                    RecoveryProgressRing(
                        progress:
                            snapshot
                                .progressToNext,
                        completedCount:
                            snapshot
                                .completedCount
                    )

                    recoveryCopy(snapshot)
                }
            }

            if let latest =
                snapshot.latestCompleted {
                Label(
                    "Latest: \(latest.timeLabel) · \(latest.title)",
                    systemImage:
                        "checkmark.seal.fill"
                )
                .font(
                    .subheadline
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                        .opacity(0.90)
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .padding(15)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    BuiltTheme.accent
                        .opacity(0.08),
                    in: RoundedRectangle(
                        cornerRadius:
                            BuiltTheme
                                .smallRadius,
                        style: .continuous
                    )
                )
            }
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

    private func recoveryCopy(
        _ snapshot:
            RecoveryTimelineSnapshot
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.small
        ) {
            Text("RECOVERY STATUS")
                .font(
                    .caption
                    .weight(.bold)
                )
                .tracking(1.3)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            if let next =
                snapshot.nextMilestone {
                Text(next.title)
                    .font(
                        .title2
                        .weight(.semibold)
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(
                    snapshot.remainingText
                )
                .font(
                    .subheadline
                    .weight(.medium)
                )
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
            } else {
                Text(
                    "Every listed milestone reached"
                )
                .font(
                    .title2
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

                Text(
                    "The long-term benefits continue beyond this timeline."
                )
                .font(.subheadline)
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
            }
        }
    }

    private func timeline(
        _ snapshot:
            RecoveryTimelineSnapshot
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            SectionHeader(
                eyebrow: "The long game",
                title:
                    "Recovery milestones",
                trailingText:
                    "\(snapshot.completedCount)/\(RecoveryTimelineService.milestones.count)"
            )

            LazyVStack(
                spacing: BuiltTheme.Spacing.medium
            ) {
                ForEach(
                    RecoveryTimelineService
                        .milestones
                ) { milestone in
                    let isCompleted =
                        snapshot.elapsed
                        >= milestone.threshold

                    let isNext =
                        snapshot.nextMilestone?
                            .id
                        == milestone.id

                    RecoveryMilestoneCard(
                        milestone: milestone,
                        isCompleted:
                            isCompleted,
                        isNext: isNext,
                        progress:
                            isNext
                            ? snapshot
                                .progressToNext
                            : nil
                    )
                }
            }
        }
    }

    private var disclaimer: some View {
        BuiltStatusCard(
            kind: .neutral,
            title:
                "Health information",
            message:
                "These are population-level estimates from public-health sources. Recovery varies by person, smoking history, and health conditions. BUILT does not measure these changes and is not a substitute for medical care."
        )
    }
}

private struct RecoveryProgressRing:
    View {
    let progress: Double
    let completedCount: Int

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @ScaledMetric(relativeTo: .title)
    private var ringSize: CGFloat = 120

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.white.opacity(0.08),
                    lineWidth: 10
                )

            Circle()
                .trim(
                    from: 0,
                    to:
                        min(
                            max(progress, 0),
                            1
                        )
                )
                .stroke(
                    BuiltTheme.accent,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                .rotationEffect(
                    .degrees(-90)
                )
                .animation(
                    reduceMotion
                    ? nil
                    : BuiltTheme
                        .Motion.standard,
                    value: progress
                )

            VStack(
                spacing:
                    BuiltTheme.Spacing.xSmall
            ) {
                Text("\(completedCount)")
                    .font(
                        .title
                        .weight(.bold)
                        .monospacedDigit()
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                Text("REACHED")
                    .font(
                        .caption2
                        .weight(.bold)
                    )
                    .tracking(0.8)
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
            }
        }
        .frame(
            width: ringSize,
            height: ringSize
        )
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            "Recovery milestones reached"
        )
        .accessibilityValue(
            "\(completedCount)"
        )
    }
}
