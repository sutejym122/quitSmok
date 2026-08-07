import SwiftUI

struct BuiltPlanTodayCard: View {
    let progress: BuiltPlanProgress
    let hasPro: Bool
    let action: () -> Void

    private var eyebrow: String {
        if progress.isFinished {
            return "7-DAY PLAN COMPLETE"
        }

        if !hasPro,
           progress.completedCount >= 1 {
            return "YOUR NEXT STEP"
        }

        return "YOUR BUILT PLAN"
    }

    private var title: String {
        if progress.isFinished {
            return "Seven decisions. Real proof."
        }

        if !hasPro,
           progress.completedCount >= 1 {
            return "Your personalized plan continues."
        }

        return progress.nextMission?.title
            ?? progress.plan.title
    }

    private var subtitle: String {
        if progress.isFinished {
            return "You finished the first seven missions. Keep the behaviors that worked."
        }

        if !hasPro,
           progress.completedCount >= 1 {
            return "Day 1 is yours. Unlock Days 2–7 with BUILT Pro."
        }

        return "\(progress.completedCount) of \(progress.plan.durationDays) missions complete"
    }

    var body: some View {
        Button(action: action) {
            if progress.isFinished {
                completedTodayCard
            } else {
                VStack(
                alignment: .leading,
                spacing: BuiltTheme.Spacing.medium
            ) {
                HStack {
                    Label(
                        eyebrow,
                        systemImage: "checklist.checked"
                    )
                    .font(
                        .caption
                        .weight(.bold)
                    )
                    .tracking(1.2)
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                    Spacer()

                    if !hasPro,
                       progress.completedCount >= 1,
                       !progress.isFinished {
                        ProBadge(compact: true)
                    }
                }

                Text(title)
                    .font(
                        .title3
                        .weight(.bold)
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .multilineTextAlignment(.leading)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(subtitle)
                    .font(
                        .subheadline
                        .weight(.medium)
                    )
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )

                ProgressView(
                    value:
                        Double(
                            progress.completedCount
                        ),
                    total:
                        Double(
                            progress.plan.durationDays
                        )
                )
                .tint(BuiltTheme.accent)

                HStack {
                    Text(
                        progress.isFinished
                        ? "Review the plan"
                        : "Open plan"
                    )
                    .font(
                        .subheadline
                        .weight(.semibold)
                    )

                    Spacer()

                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(
                    BuiltTheme.accent
                )
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .builtCard(padding: 20)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(
            "built.today.plan"
        )
        .accessibilityHint(
            progress.isFinished
            ? "Reviews your completed personalized plan"
            : "Opens your personalized seven-day quit plan"
        )
    }

    private var completedTodayCard: some View {
        HStack(
            alignment: .center,
            spacing: BuiltTheme.Spacing.medium
        ) {
            ZStack {
                Circle()
                    .fill(
                        BuiltTheme.accent
                            .opacity(0.14)
                    )
                    .frame(
                        width: 44,
                        height: 44
                    )

                Image(
                    systemName:
                        "checkmark.seal.fill"
                )
                .font(
                    .system(
                        size: 19,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )
            }
            .accessibilityHidden(true)

            VStack(
                alignment: .leading,
                spacing: BuiltTheme.Spacing.xSmall
            ) {
                Text("FIRST WEEK BUILT")
                    .font(
                        .caption
                        .weight(.bold)
                    )
                    .tracking(1.2)
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                Text(
                    "\(progress.completedCount) of \(progress.plan.durationDays) missions complete"
                )
                .font(
                    .subheadline
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

                Text("Review what worked")
                    .font(.footnote)
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
            }

            Spacer(minLength: 8)

            Image(
                systemName: "chevron.right"
            )
            .font(
                .footnote
                .weight(.bold)
            )
            .foregroundStyle(
                BuiltTheme.accent
            )
            .accessibilityHidden(true)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 18)
    }
}

struct BuiltPlanView: View {
    @EnvironmentObject
    private var storeManager: StoreManager

    @Environment(\.dismiss)
    private var dismiss

    @State private var progress:
        BuiltPlanProgress

    @State private var paywallContext:
        PaywallContext?

    @State private var celebrationMoment:
        CelebrationMoment?

    init() {
        let preferences =
            OnboardingPreferencesStore.load()

        _progress =
            State(
                initialValue:
                    BuiltPlanProgressStore
                        .loadOrCreate(
                            preferences: preferences
                        )
            )
    }

    private var currentDayNumber: Int? {
        progress.nextDayNumber
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(
                        alignment: .leading,
                        spacing:
                            BuiltTheme.Spacing.xLarge
                    ) {
                        hero

                        ForEach(
                            progress.plan.missions
                        ) { mission in
                            missionCard(mission)
                                .id(
                                    mission.dayNumber
                                )
                        }

                        if !storeManager.hasPro,
                           !progress.isFinished {
                            proCallout
                        }

                        if progress.isFinished {
                            completionCard
                        }
                    }
                    .padding(
                        .horizontal,
                        BuiltTheme.Spacing
                            .screenHorizontal
                    )
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(
                        of:
                            progress.completedCount
                    ) {
                        oldCount,
                        newCount in

                        guard
                            newCount > oldCount,
                            let nextDayNumber =
                                progress
                                    .nextDayNumber
                        else {
                            return
                        }

                        withAnimation(
                            BuiltTheme
                                .Motion
                                .standard
                        ) {
                            proxy.scrollTo(
                                nextDayNumber,
                                anchor: .center
                            )
                        }
                    }
                }

                if let celebrationMoment {
                    CelebrationOverlay(
                        moment: celebrationMoment
                    ) {
                        self.celebrationMoment =
                            nil
                    }
                    .zIndex(30)
                }
            }
            .navigationTitle("Your BUILT Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(
                .ultraThinMaterial,
                for: .navigationBar
            )
            .toolbarBackground(
                .visible,
                for: .navigationBar
            )
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                }
            }
        }
        .accessibilityIdentifier(
            "built.screen.plan"
        )
        .sheet(
            item: $paywallContext
        ) { context in
            PaywallView(
                context: context
            )
            .environmentObject(
                storeManager
            )
        }
    }

    private var hero: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            HStack {
                Text("YOUR FIRST 7 DAYS")
                    .font(
                        .caption
                        .weight(.bold)
                    )
                    .tracking(1.8)
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                Spacer()

                Text(
                    "\(progress.completedCount)/\(progress.plan.durationDays)"
                )
                .font(
                    .subheadline
                    .weight(.bold)
                    .monospacedDigit()
                )
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
            }

            Text(progress.plan.title)
                .font(
                    .system(
                        size: 34,
                        weight: .bold
                    )
                )
                .tracking(-1.0)
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text(progress.plan.subtitle)
                .font(
                    .body
                    .weight(.medium)
                )
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            ProgressView(
                value:
                    Double(
                        progress.completedCount
                    ),
                total:
                    Double(
                        progress.plan.durationDays
                    )
            )
            .tint(BuiltTheme.accent)
            .scaleEffect(
                x: 1,
                y: 1.7,
                anchor: .center
            )

            Text(
                storeManager.hasPro
                ? "Complete one mission at a time. The next day unlocks when the previous one is done."
                : "Day 1 is free. Complete it before deciding whether the full plan is worth unlocking."
            )
            .font(.footnote)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .builtCard(padding: 22)
    }

    @ViewBuilder
    private func missionCard(
        _ mission: BuiltPlanMission
    ) -> some View {
        let completed =
            progress.isCompleted(
                dayNumber: mission.dayNumber
            )

        let accessible =
            progress.canAccess(
                dayNumber: mission.dayNumber,
                hasPro: storeManager.hasPro
            )

        let isCurrent =
            currentDayNumber ==
                mission.dayNumber

        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            missionHeader(
                mission: mission,
                completed: completed,
                accessible: accessible
            )

            if completed {
                Label(
                    "Mission complete",
                    systemImage:
                        "checkmark.seal.fill"
                )
                .font(
                    .subheadline
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )
            } else if accessible &&
                        isCurrent {
                activeMissionContent(
                    mission
                )
            } else if !accessible {
                lockedMissionContent(
                    mission
                )
            } else {
                Text(
                    "Finish the previous mission to make this one active."
                )
                .font(.subheadline)
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 20)
        .opacity(
            completed || accessible
            ? 1
            : 0.72
        )
    }

    private func missionHeader(
        mission: BuiltPlanMission,
        completed: Bool,
        accessible: Bool
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: BuiltTheme.Spacing.medium
        ) {
            ZStack {
                Circle()
                    .fill(
                        completed
                        ? BuiltTheme.accent
                        : BuiltTheme.elevated
                    )
                    .frame(
                        width: 48,
                        height: 48
                    )

                Image(
                    systemName:
                        completed
                        ? "checkmark"
                        : mission.symbolName
                )
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    completed
                    ? Color.black
                    : BuiltTheme.accent
                )
            }
            .accessibilityHidden(true)

            VStack(
                alignment: .leading,
                spacing: BuiltTheme.Spacing.xSmall
            ) {
                HStack(spacing: 8) {
                    Text(
                        "DAY \(mission.dayNumber)"
                    )
                    .font(
                        .caption
                        .weight(.bold)
                    )
                    .tracking(1.3)
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                    if mission.dayNumber == 1,
                       !storeManager.hasPro {
                        Text("FREE")
                            .font(
                                .caption2
                                .weight(.black)
                            )
                            .foregroundStyle(
                                Color.black
                            )
                            .padding(
                                .horizontal,
                                7
                            )
                            .padding(
                                .vertical,
                                4
                            )
                            .background(
                                BuiltTheme.accent,
                                in: Capsule()
                            )
                    } else if !accessible,
                              !storeManager.hasPro {
                        ProBadge(
                            compact: true
                        )
                    }
                }

                Text(mission.title)
                    .font(
                        .headline
                        .weight(.bold)
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            Spacer(minLength: 0)
        }
    }

    private func activeMissionContent(
        _ mission: BuiltPlanMission
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            Text(mission.detail)
                .font(.subheadline)
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            missionBlock(
                label: "TODAY'S ACTION",
                text: mission.action,
                systemName:
                    "arrow.right.circle.fill"
            )

            missionBlock(
                label: "WHY THIS MATTERS",
                text: mission.reason,
                systemName: "heart.fill"
            )

            Button {
                complete(mission)
            } label: {
                HStack {
                    Image(
                        systemName:
                            "checkmark.circle.fill"
                    )

                    Text(
                        "Complete Day \(mission.dayNumber)"
                    )

                    Spacer()
                }
            }
            .buttonStyle(
                BuiltPrimaryButtonStyle()
            )
            .accessibilityIdentifier(
                "built.plan.complete.current"
            )
        }
    }

    @ViewBuilder
    private func lockedMissionContent(
        _ mission: BuiltPlanMission
    ) -> some View {
        if !storeManager.hasPro,
           mission.dayNumber == 2 {
            VStack(
                alignment: .leading,
                spacing: BuiltTheme.Spacing.medium
            ) {
                Text(
                    "Day 2 starts the complete personalized plan."
                )
                .font(.subheadline)
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )

                Button {
                    paywallContext =
                        .plan
                } label: {
                    HStack {
                        Image(
                            systemName:
                                "lock.open.fill"
                        )

                        Text(
                            "Unlock Days 2–7"
                        )

                        Spacer()
                    }
                }
                .buttonStyle(
                    BuiltPrimaryButtonStyle()
                )
                .accessibilityIdentifier(
                    "built.plan.unlock"
                )
            }
        } else if !storeManager.hasPro {
            Text(
                "Included with the complete BUILT Plan."
            )
            .font(.subheadline)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        } else {
            Text(
                "Finish the previous mission to unlock this day."
            )
            .font(.subheadline)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
    }

    private func missionBlock(
        label: String,
        text: String,
        systemName: String
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: BuiltTheme.Spacing.medium
        ) {
            Image(systemName: systemName)
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(width: 24)
                .accessibilityHidden(true)

            VStack(
                alignment: .leading,
                spacing: BuiltTheme.Spacing.xSmall
            ) {
                Text(label)
                    .font(
                        .caption2
                        .weight(.bold)
                    )
                    .tracking(1.0)
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )

                Text(text)
                    .font(
                        .subheadline
                        .weight(.medium)
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
        .padding(16)
        .background(
            BuiltTheme.elevated,
            in:
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
        )
    }

    private var proCallout: some View {
        UpgradeCard(
            title:
                "Keep the plan moving.",
            message:
                "Day 1 is free. BUILT Pro unlocks the remaining six personalized missions with one lifetime purchase.",
            feature:
                .personalizedPlan
        ) {
            paywallContext =
                .plan
        }
    }

    private var completionCard: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            Label(
                "FIRST WEEK BUILT",
                systemImage:
                    "checkmark.seal.fill"
            )
            .font(
                .caption
                .weight(.bold)
            )
            .tracking(1.5)
            .foregroundStyle(
                BuiltTheme.accent
            )

            Text(
                "The plan is complete. Keep the behaviors that earned this proof."
            )
            .font(
                .title3
                .weight(.bold)
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )

            Text(
                "Your next job is not to chase a perfect streak. It is to keep making the decisions that protect the person you are building."
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
        .builtCard(padding: 20)
    }

    private func complete(
        _ mission: BuiltPlanMission
    ) {
        guard
            progress.canAccess(
                dayNumber: mission.dayNumber,
                hasPro: storeManager.hasPro
            )
        else {
            return
        }

        let wasFinished =
            progress.isFinished

        progress.complete(
            dayNumber: mission.dayNumber
        )

        BuiltPlanProgressStore.save(
            progress
        )

        if !wasFinished,
           progress.isFinished,
           mission.dayNumber ==
                progress.plan.durationDays {
            celebrationMoment =
                .planCompletion()
        }
    }
}
