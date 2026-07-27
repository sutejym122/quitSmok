import SwiftUI

struct RecoveryAccessView: View {
    let profile: QuitProfile

    @EnvironmentObject
    private var storeManager: StoreManager

    var body: some View {
        if storeManager.hasPro {
            RecoveryTimelineView(
                profile: profile
            )
        } else {
            FreeRecoveryView(
                profile: profile
            )
        }
    }
}

private struct FreeRecoveryView: View {
    let profile: QuitProfile

    @EnvironmentObject
    private var storeManager: StoreManager

    @State private var showingPaywall = false

    private var freeMilestones:
        [RecoveryMilestone] {
        Array(
            RecoveryTimelineService
                .milestones
                .prefix(
                    ProAccessPolicy
                        .freeRecoveryMilestoneLimit
                )
        )
    }

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
                            spacing: 24
                        ) {
                            SectionHeader(
                                eyebrow:
                                    "Body recovery",
                                title:
                                    "Your body is rebuilding."
                            )

                            freeOverview(snapshot)
                            freeTimeline(snapshot)

                            UpgradeCard(
                                title:
                                    "Continue the complete recovery journey",
                                message:
                                    "Unlock every milestone from 72 hours through 15 years, with evidence-based explanations and long-term celebrations.",
                                action: {
                                    showingPaywall = true
                                }
                            )

                            disclaimer
                        }
                        .padding(
                            .horizontal,
                            20
                        )
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
        .sheet(isPresented: $showingPaywall) {
            PaywallView(context: .recovery)
                .environmentObject(storeManager)
        }
    }

    private func freeOverview(
        _ snapshot: RecoveryTimelineSnapshot
    ) -> some View {
        let completedFree =
            freeMilestones.filter {
                snapshot.elapsed >= $0.threshold
            }

        let nextFree =
            freeMilestones.first {
                snapshot.elapsed < $0.threshold
            }

        return VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Text("CORE RECOVERY")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .tracking(1.5)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(
                nextFree?.title
                ?? "Every core milestone reached"
            )
            .font(
                .system(
                    size: 28,
                    weight: .bold
                )
            )
            .tracking(-0.8)
            .foregroundStyle(
                BuiltTheme.textPrimary
            )

            Text(
                nextFree.map {
                    RecoveryTimelineService
                        .formattedDuration(
                            max(
                                0,
                                $0.threshold
                                    - snapshot.elapsed
                            )
                        )
                }
                ?? "Your long-term recovery continues."
            )
            .font(
                .system(
                    size: 14,
                    weight: .medium
                )
            )
            .foregroundStyle(
                BuiltTheme.textSecondary
            )

            HStack {
                Label(
                    "\(completedFree.count) of \(freeMilestones.count) core milestones",
                    systemImage:
                        "checkmark.seal.fill"
                )
                .font(
                    .system(
                        size: 12,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )

                Spacer()

                Text("FREE")
                    .font(
                        .system(
                            size: 9,
                            weight: .bold
                        )
                    )
                    .tracking(1)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(
                        BuiltTheme.accent,
                        in: Capsule()
                    )
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 22)
    }

    private func freeTimeline(
        _ snapshot: RecoveryTimelineSnapshot
    ) -> some View {
        VStack(spacing: 12) {
            ForEach(freeMilestones) {
                milestone in

                let isCompleted =
                    snapshot.elapsed
                    >= milestone.threshold

                let nextMilestone =
                    freeMilestones.first {
                        snapshot.elapsed
                        < $0.threshold
                    }

                let isNext =
                    nextMilestone?.id
                    == milestone.id

                let previousThreshold =
                    freeMilestones
                        .filter {
                            $0.threshold
                            < milestone.threshold
                        }
                        .last?
                        .threshold
                    ?? 0

                let progress: Double? =
                    isNext
                    ? min(
                        max(
                            (
                                snapshot.elapsed
                                - previousThreshold
                            )
                            / max(
                                1,
                                milestone.threshold
                                - previousThreshold
                            ),
                            0
                        ),
                        1
                    )
                    : nil

                RecoveryMilestoneCard(
                    milestone: milestone,
                    isCompleted: isCompleted,
                    isNext: isNext,
                    progress: progress
                )
            }
        }
    }

    private var disclaimer: some View {
        Text(
            "Recovery timelines describe population-level changes and are not personal medical measurements. Individual recovery varies."
        )
        .font(.system(size: 11))
        .foregroundStyle(
            BuiltTheme.textSecondary
        )
        .multilineTextAlignment(.center)
        .frame(
            maxWidth: .infinity
        )
        .padding(.horizontal, 8)
    }
}
