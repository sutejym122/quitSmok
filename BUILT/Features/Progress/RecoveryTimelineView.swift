import SwiftUI

struct RecoveryTimelineView: View {
    let profile: QuitProfile

    @State private var celebration: CelebrationMoment?

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
                    let snapshot = RecoveryTimelineService.snapshot(
                        quitDate: profile.quitDate,
                        now: context.date
                    )

                    ScrollView {
                        VStack(
                            alignment: .leading,
                            spacing: 24
                        ) {
                            SectionHeader(
                                eyebrow: "Body recovery",
                                title: "Your body is rebuilding."
                            )

                            recoveryHero(snapshot)
                            timeline(snapshot)
                            disclaimer
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .padding(.bottom, 38)
                    }
                }
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .task(id: profile.quitDate) {
            guard celebration == nil,
                  let milestone = RecoveryCelebrationStore.consumeNewestUnseen(
                    quitDate: profile.quitDate
                  ) else {
                return
            }

            celebration = .recovery(milestone)
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
        _ snapshot: RecoveryTimelineSnapshot
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 22
        ) {
            HStack(spacing: 20) {
                RecoveryProgressRing(
                    progress: snapshot.progressToNext,
                    completedCount: snapshot.completedCount
                )

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {
                    Text("RECOVERY STATUS")
                        .font(
                            .system(
                                size: 10,
                                weight: .bold
                            )
                        )
                        .tracking(1.6)
                        .foregroundStyle(BuiltTheme.accent)

                    if let next = snapshot.nextMilestone {
                        Text(next.title)
                            .font(
                                .system(
                                    size: 23,
                                    weight: .semibold
                                )
                            )
                            .tracking(-0.5)
                            .foregroundStyle(BuiltTheme.textPrimary)
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )

                        Text(snapshot.remainingText)
                            .font(
                                .system(
                                    size: 13,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(BuiltTheme.textSecondary)
                    } else {
                        Text("Every listed milestone reached")
                            .font(
                                .system(
                                    size: 23,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(BuiltTheme.textPrimary)

                        Text("The long-term benefits continue beyond this timeline.")
                            .font(.system(size: 13))
                            .foregroundStyle(BuiltTheme.textSecondary)
                    }
                }
            }

            if let latest = snapshot.latestCompleted {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(BuiltTheme.accent)

                    Text("Latest: \(latest.timeLabel) · \(latest.title)")
                        .font(
                            .system(
                                size: 13,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(BuiltTheme.textPrimary.opacity(0.88))
                        .lineLimit(2)
                }
                .padding(14)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    BuiltTheme.accent.opacity(0.08),
                    in: RoundedRectangle(
                        cornerRadius: 16,
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
    }

    private func timeline(
        _ snapshot: RecoveryTimelineSnapshot
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            SectionHeader(
                eyebrow: "The long game",
                title: "Recovery milestones",
                trailingText: "\(snapshot.completedCount)/\(RecoveryTimelineService.milestones.count)"
            )

            ForEach(
                RecoveryTimelineService.milestones
            ) { milestone in
                let isCompleted = snapshot.elapsed >= milestone.threshold
                let isNext = snapshot.nextMilestone?.id == milestone.id

                RecoveryMilestoneCard(
                    milestone: milestone,
                    isCompleted: isCompleted,
                    isNext: isNext,
                    progress: isNext ? snapshot.progressToNext : nil
                )
            }
        }
    }

    private var disclaimer: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Label(
                "Health information",
                systemImage: "cross.case.fill"
            )
            .font(
                .system(
                    size: 14,
                    weight: .semibold
                )
            )
            .foregroundStyle(BuiltTheme.textPrimary)

            Text(
                "These are population-level estimates from public-health sources. Recovery varies by person, smoking history, and health conditions. BUILT does not measure these changes and is not a substitute for medical care."
            )
            .font(.system(size: 12))
            .foregroundStyle(BuiltTheme.textSecondary)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .builtCard(padding: 18)
    }
}

private struct RecoveryProgressRing: View {
    let progress: Double
    let completedCount: Int

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
                    to: min(max(progress, 0), 1)
                )
                .stroke(
                    BuiltTheme.accent,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(completedCount)")
                    .font(
                        .system(
                            size: 30,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(BuiltTheme.textPrimary)

                Text("REACHED")
                    .font(
                        .system(
                            size: 8,
                            weight: .bold
                        )
                    )
                    .tracking(1)
                    .foregroundStyle(BuiltTheme.textSecondary)
            }
        }
        .frame(width: 118, height: 118)
    }
}
