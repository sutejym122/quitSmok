import SwiftData
import SwiftUI

struct RewardsAccessView: View {
    let profile: QuitProfile

    @EnvironmentObject
    private var storeManager: StoreManager

    var body: some View {
        if storeManager.hasPro {
            RewardsView(profile: profile)
        } else {
            FreeRewardsView(profile: profile)
        }
    }
}

private struct FreeRewardsView: View {
    let profile: QuitProfile

    @Environment(\.modelContext)
    private var modelContext

    @EnvironmentObject
    private var storeManager: StoreManager

    @Query(
        sort: \RewardGoal.createdAt,
        order: .reverse
    )
    private var goals: [RewardGoal]

    @State private var showingAddGoal = false
    @State private var showingPaywall = false
    @State private var contributionGoal:
        RewardGoal?
    @State private var goalPendingDeletion:
        RewardGoal?
    @State private var celebration:
        CelebrationMoment?

    private var canCreateGoal: Bool {
        ProAccessPolicy.canCreateRewardGoal(
            hasPro: storeManager.hasPro,
            goalCount: goals.count
        )
    }

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
                            spacing: 24
                        ) {
                            header
                            savingsHero(totalSaved)

                            if goals.isEmpty {
                                emptyState
                            } else {
                                goalList(totalSaved)
                                UpgradeCard(
                                    title:
                                        "Create unlimited reward goals",
                                    message:
                                        "Keep several targets moving at once and turn protected cigarette spending into gym gear, travel, experiences, and anything else you are building toward.",
                                    action: {
                                        showingPaywall = true
                                    }
                                )
                            }
                        }
                        .padding(
                            .horizontal,
                            20
                        )
                        .padding(.top, 18)
                        .padding(.bottom, 38)
                    }
                    .onAppear {
                        reconcileGoals(
                            totalSaved: totalSaved
                        )
                    }
                    .onChange(
                        of: Int(
                            (
                                totalSaved
                                * 100
                            )
                            .rounded()
                        )
                    ) { _, _ in
                        reconcileGoals(
                            totalSaved: totalSaved
                        )
                    }
                }
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .sheet(isPresented: $showingAddGoal) {
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
        .sheet(isPresented: $showingPaywall) {
            PaywallView(
                context: .rewardGoals
            )
            .environmentObject(storeManager)
        }
        .sheet(item: $contributionGoal) {
            goal in

            FreeContributionSheet(
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
                        totalSaved: totalSaved
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
                set: { isPresented in
                    if !isPresented {
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
        .onChange(of: goalSignature) {
            _, _ in

            reconcileGoals(
                totalSaved:
                    RewardMetrics.totalSaved(
                        profile: profile
                    )
            )
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            SectionHeader(
                eyebrow: "Reward system",
                title: "Make quitting pay you."
            )

            Spacer()

            Button {
                if canCreateGoal {
                    showingAddGoal = true
                } else {
                    showingPaywall = true
                }
            } label: {
                Image(
                    systemName:
                        canCreateGoal
                        ? "plus"
                        : "lock.fill"
                )
                .font(
                    .system(
                        size: 16,
                        weight: .bold
                    )
                )
                .foregroundStyle(.black)
                .frame(
                    width: 46,
                    height: 46
                )
                .background(
                    BuiltTheme.accent,
                    in: Circle()
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                canCreateGoal
                ? "Create reward goal"
                : "Unlock unlimited reward goals"
            )
        }
    }

    private func savingsHero(
        _ totalSaved: Double
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text("MONEY PROTECTED")
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
                totalSaved.formatted(
                    .currency(
                        code:
                            normalizedCurrencyCode
                    )
                    .precision(
                        .fractionLength(0...2)
                    )
                )
            )
            .font(
                .system(
                    size: 42,
                    weight: .bold,
                    design: .rounded
                )
            )
            .tracking(-1.2)
            .foregroundStyle(
                BuiltTheme.textPrimary
            )

            Text(
                goals.isEmpty
                ? "Give that money its first destination."
                : "Your first reward goal is included free."
            )
            .font(.system(size: 14))
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 22)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "gift.fill")
                .font(
                    .system(
                        size: 40,
                        weight: .light
                    )
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text("Create your first reward")
                .font(
                    .system(
                        size: 23,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            Text(
                "One goal is included free. Let every cigarette you reject move you toward something real."
            )
            .font(.system(size: 14))
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .multilineTextAlignment(.center)

            Button {
                showingAddGoal = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Create free reward goal")
                    Spacer()
                    Image(
                        systemName:
                            "arrow.right"
                    )
                }
            }
            .buttonStyle(
                BuiltPrimaryButtonStyle()
            )
        }
        .frame(
            maxWidth: .infinity
        )
        .builtCard(padding: 26)
    }

    private func goalList(
        _ totalSaved: Double
    ) -> some View {
        VStack(spacing: 12) {
            ForEach(goals) { goal in
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
                        goalPendingDeletion =
                            goal
                    }
                )
            }
        }
    }

    private var normalizedCurrencyCode: String {
        let cleaned =
            profile.currencyCode
                .uppercased()
                .filter(\.isLetter)

        return cleaned.count == 3
            ? cleaned
            : "USD"
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

        let wasActive =
            goal.isActive

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
        } catch {
            Haptics.warning()
        }
    }
}

private struct FreeContributionSheet: View {
    let goal: RewardGoal
    let currencyCode: String
    let onSave: (Double) -> Void

    @Environment(\.dismiss)
    private var dismiss

    @State private var amount = 10.0

    private var normalizedCurrencyCode: String {
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

                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {
                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {
                        Text("MANUAL CONTRIBUTION")
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

                        Text(goal.title)
                            .font(
                                .system(
                                    size: 30,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(
                                BuiltTheme.textPrimary
                            )

                        Text(
                            "Add money you deliberately redirected toward this reward."
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                    }

                    HStack(
                        alignment:
                            .firstTextBaseline
                    ) {
                        Text(
                            normalizedCurrencyCode
                        )
                        .font(
                            .system(
                                size: 14,
                                weight: .bold,
                                design: .monospaced
                            )
                        )
                        .foregroundStyle(
                            BuiltTheme.textSecondary
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
                            .system(
                                size: 44,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary
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
                            Text("Add contribution")
                            Spacer()
                            Image(
                                systemName:
                                    "arrow.right"
                            )
                        }
                    }
                    .buttonStyle(
                        BuiltPrimaryButtonStyle()
                    )

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
            .navigationTitle("Add money")
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
