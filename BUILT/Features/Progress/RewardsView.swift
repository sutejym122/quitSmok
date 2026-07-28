import SwiftUI
import SwiftData

struct RewardsView: View {
    let profile: QuitProfile

    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \RewardGoal.createdAt,
        order: .reverse
    )
    private var goals: [RewardGoal]

    @Query
    private var cravings: [CravingEntry]

    @State private var showingAddGoal =
        false

    @State private var contributionGoal:
        RewardGoal?

    @State private var goalPendingDeletion:
        RewardGoal?

    @State private var celebration:
        CelebrationMoment?

    @State private var persistenceError:
        String?

    private var goalSignature: String {
        goals.map { goal in
            [
                String(
                    describing:
                        goal.persistentModelID
                ),
                goal.title,
                String(goal.targetAmount),
                String(goal.bankedAmount),
                String(
                    goal
                        .automaticSavingsBaseline
                ),
                String(
                    goal.usesAutomaticSavings
                ),
                String(goal.isActive),
                String(
                    goal.completedAt?
                        .timeIntervalSince1970
                    ?? 0
                ),
                String(
                    goal.claimedAt?
                        .timeIntervalSince1970
                    ?? 0
                )
            ]
            .joined(separator: "-")
        }
        .joined(separator: "|")
    }

    private var normalizedCurrencyCode:
        String {
        let cleaned =
            profile.currencyCode
                .uppercased()
                .filter(\.isLetter)

        return cleaned.count == 3
            ? cleaned
            : "USD"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                TimelineView(
                    .periodic(
                        from: .now,
                        by: 30
                    )
                ) { context in
                    let totalSaved =
                        RewardMetrics.totalSaved(
                            profile: profile,
                            now: context.date
                        )

                    ScrollView {
                        VStack(
                            alignment: .leading,
                            spacing:
                                BuiltTheme.Spacing
                                    .xLarge
                        ) {
                            header

                            savingsHero(totalSaved)

                            if let persistenceError {
                                BuiltStatusCard(
                                    kind: .error,
                                    title:
                                        "Reward changes could not be saved",
                                    message:
                                        persistenceError,
                                    primaryActionTitle:
                                        "Dismiss",
                                    primaryAction: {
                                        self.persistenceError =
                                            nil
                                    }
                                )
                            }

                            if goals.isEmpty {
                                emptyState
                            } else {
                                activeGoalSection(
                                    totalSaved
                                )
                                allGoalsSection(
                                    totalSaved
                                )
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
                    .onAppear {
                        reconcileGoals(
                            totalSaved:
                                totalSaved
                        )
                    }
                    .onChange(
                        of:
                            Int(
                                (
                                    totalSaved
                                    * 100
                                )
                                .rounded()
                            )
                    ) { _, _ in
                        reconcileGoals(
                            totalSaved:
                                totalSaved
                        )
                    }
                }
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .sheet(
            isPresented:
                $showingAddGoal
        ) {
            AddRewardGoalView(
                profile: profile,
                totalSaved:
                    RewardMetrics.totalSaved(
                        profile: profile
                    ),
                hasActiveGoal:
                    RewardMetrics.activeGoal(
                        in: goals
                    ) != nil
            )
        }
        .sheet(
            item:
                $contributionGoal
        ) { goal in
            ContributionSheet(
                goal: goal,
                currencyCode:
                    profile.currencyCode
            ) { amount in
                let totalSaved =
                    RewardMetrics.totalSaved(
                        profile: profile
                    )

                RewardGoalCoordinator
                    .addContribution(
                        amount,
                        to: goal,
                        totalSaved:
                            totalSaved
                    )

                let becameComplete =
                    RewardGoalCoordinator
                        .reconcileCompletion(
                            for: goal,
                            totalSaved:
                                totalSaved
                        )

                saveChanges()

                if becameComplete {
                    celebration =
                        .reward(goal)
                    Haptics.success()
                }
            }
        }
        .alert(
            "Delete this reward goal?",
            isPresented: Binding(
                get: {
                    goalPendingDeletion
                    != nil
                },
                set: { presented in
                    if !presented {
                        goalPendingDeletion =
                            nil
                    }
                }
            )
        ) {
            Button(
                "Delete",
                role: .destructive
            ) {
                deletePendingGoal()
            }

            Button(
                "Cancel",
                role: .cancel
            ) {
                goalPendingDeletion = nil
            }
        } message: {
            Text(
                "The goal and its tracked progress will be permanently removed."
            )
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
        .onChange(
            of: goalSignature
        ) { _, _ in
            reconcileGoals(
                totalSaved:
                    RewardMetrics.totalSaved(
                        profile: profile
                    )
            )
        }
    }

    private var header: some View {
        HStack(
            alignment: .center,
            spacing: BuiltTheme.Spacing.medium
        ) {
            SectionHeader(
                eyebrow:
                    "Reward system",
                title:
                    "Make quitting pay you."
            )

            Spacer()

            Button {
                showingAddGoal = true
            } label: {
                Image(systemName: "plus")
                    .font(
                        .body
                        .weight(.bold)
                    )
                    .foregroundStyle(.black)
                    .frame(
                        width:
                            BuiltTheme
                                .minimumTapTarget,
                        height:
                            BuiltTheme
                                .minimumTapTarget
                    )
                    .background(
                        BuiltTheme.accent,
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                "Add reward goal"
            )
        }
    }

    private func savingsHero(
        _ totalSaved: Double
    ) -> some View {
        BuiltHeroPanel(
            eyebrow:
                "Money protected",
            title:
                totalSaved.formatted(
                    .currency(
                        code:
                            normalizedCurrencyCode
                    )
                    .precision(
                        .fractionLength(0...2)
                    )
                ),
            message:
                "That money used to disappear in smoke. Now it can become something you can see, use, and remember.",
            systemName:
                "banknote.fill",
            trailingValue:
                "\(goals.filter { $0.completedAt != nil }.count)",
            trailingLabel:
                "Unlocked"
        )
    }

    private var emptyState: some View {
        BuiltEmptyState(
            systemName: "giftcard.fill",
            title:
                "Create your first reward",
            message:
                "Choose something worth earning. BUILT can automatically move your calculated cigarette savings toward it.",
            actionTitle:
                "Set a reward goal",
            action: {
                showingAddGoal = true
            }
        )
    }

    @ViewBuilder
    private func activeGoalSection(
        _ totalSaved: Double
    ) -> some View {
        if let activeGoal =
            RewardMetrics.activeGoal(
                in: goals
            ) {
            VStack(
                alignment: .leading,
                spacing:
                    BuiltTheme.Spacing.medium
            ) {
                SectionHeader(
                    eyebrow:
                        "Current target",
                    title:
                        "What you’re earning"
                )

                goalCard(
                    activeGoal,
                    totalSaved:
                        totalSaved
                )
            }
        } else {
            VStack(
                alignment: .leading,
                spacing:
                    BuiltTheme.Spacing.medium
            ) {
                SectionHeader(
                    eyebrow:
                        "Current target",
                    title:
                        "Choose what comes next"
                )

                BuiltStatusCard(
                    kind: .neutral,
                    title:
                        "No active reward",
                    message:
                        "Activate any unfinished goal below, or create a new one. Only one goal automatically receives future savings at a time.",
                    primaryActionTitle:
                        "Add another goal",
                    primaryAction: {
                        showingAddGoal = true
                    }
                )
            }
        }
    }

    private func allGoalsSection(
        _ totalSaved: Double
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing:
                BuiltTheme.Spacing.medium
        ) {
            SectionHeader(
                eyebrow: "Your goals",
                title: "Everything you’re building",
                trailingText:
                    "\(goals.count)"
            )

            LazyVStack(spacing: 12) {
                ForEach(goals) { goal in
                    goalCard(
                        goal,
                        totalSaved:
                            totalSaved
                    )
                }
            }
        }
    }

    private func goalCard(
        _ goal: RewardGoal,
        totalSaved: Double
    ) -> some View {
        RewardGoalCard(
            goal: goal,
            totalSaved: totalSaved,
            currencyCode:
                profile.currencyCode,
            onAddContribution: {
                contributionGoal = goal
            },
            onActivate: {
                RewardGoalCoordinator
                    .activate(
                        goal,
                        among: goals,
                        totalSaved:
                            totalSaved
                    )
                saveChanges()
            },
            onPause: {
                RewardGoalCoordinator
                    .pause(
                        goal,
                        totalSaved:
                            totalSaved
                    )
                saveChanges()
            },
            onClaim: {
                RewardGoalCoordinator
                    .markClaimed(goal)
                saveChanges()
            },
            onDelete: {
                goalPendingDeletion = goal
            }
        )
    }

    private func reconcileGoals(
        totalSaved: Double
    ) {
        var newCelebration:
            CelebrationMoment?

        for goal in goals {
            let becameComplete =
                RewardGoalCoordinator
                    .reconcileCompletion(
                        for: goal,
                        totalSaved:
                            totalSaved
                    )

            if becameComplete
                && newCelebration == nil {
                newCelebration =
                    .reward(goal)
            }
        }

        saveChanges()

        if let newCelebration,
           celebration == nil {
            celebration =
                newCelebration
        }
    }

    private func deletePendingGoal() {
        guard
            let goal =
                goalPendingDeletion
        else {
            return
        }

        let wasActive = goal.isActive

        modelContext.delete(goal)
        goalPendingDeletion = nil

        if wasActive,
           let replacement =
            goals.first(
                where: {
                    $0 !== goal
                    && $0.completedAt
                        == nil
                }
            ) {
            RewardGoalCoordinator
                .activate(
                    replacement,
                    among: goals.filter {
                        $0 !== goal
                    },
                    totalSaved:
                        RewardMetrics
                            .totalSaved(
                                profile:
                                    profile
                            )
                )
        }

        saveChanges()
    }

    private func saveChanges() {
        do {
            try modelContext.save()
            persistenceError = nil
            WidgetSyncService
                .sync(
                    profile: profile,
                    cravings: cravings,
                    rewardGoals: goals
                )
        } catch {
            persistenceError =
                "BUILT could not update the local reward database. Your previous saved state remains available."
            Haptics.warning()
        }
    }
}

private struct ContributionSheet:
    View {
    let goal: RewardGoal
    let currencyCode: String
    let onSave: (Double) -> Void

    @Environment(\.dismiss)
    private var dismiss

    @State private var amount =
        10.0

    private var normalizedCurrencyCode:
        String {
        let cleaned =
            currencyCode
                .uppercased()
                .filter(\.isLetter)

        return cleaned.count == 3
            ? cleaned
            : "USD"
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
                        BuiltHeroPanel(
                            eyebrow:
                                "Manual contribution",
                            title: goal.title,
                            message:
                                "Add money you deliberately redirected toward this reward.",
                            systemName:
                                goal.iconName
                        )

                        HStack(
                            alignment:
                                .firstTextBaseline,
                            spacing:
                                BuiltTheme.Spacing
                                    .small
                        ) {
                            Text(
                                normalizedCurrencyCode
                            )
                            .font(
                                .subheadline
                                .weight(.bold)
                                .monospaced()
                            )
                            .foregroundStyle(
                                BuiltTheme
                                    .textSecondary
                            )

                            TextField(
                                "10",
                                value: $amount,
                                format:
                                    .number.precision(
                                        .fractionLength(
                                            0...2
                                        )
                                    )
                            )
                            .keyboardType(
                                .decimalPad
                            )
                            .font(
                                .largeTitle
                                .weight(.bold)
                                .monospacedDigit()
                            )
                            .foregroundStyle(
                                BuiltTheme
                                    .textPrimary
                            )
                        }
                        .builtCard(padding: 22)

                        Button {
                            guard amount > 0 else {
                                Haptics.warning()
                                return
                            }

                            onSave(amount)
                            dismiss()
                        } label: {
                            HStack {
                                Text(
                                    "Add contribution"
                                )
                                Spacer()
                                Image(
                                    systemName:
                                        "arrow.right"
                                )
                                .accessibilityHidden(
                                    true
                                )
                            }
                        }
                        .buttonStyle(
                            BuiltPrimaryButtonStyle()
                        )
                        .disabled(amount <= 0)
                    }
                    .padding(
                        .horizontal,
                        BuiltTheme.Spacing
                            .screenHorizontal
                    )
                    .padding(.top, 18)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(
                    .interactively
                )
            }
            .navigationTitle(
                "Contribution"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
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
                    placement:
                        .topBarLeading
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(
                        BuiltTheme
                            .textSecondary
                    )
                }
            }
        }
    }
}
