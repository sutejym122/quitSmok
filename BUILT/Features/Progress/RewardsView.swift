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

    @State private var showingAddGoal = false
    @State private var contributionGoal: RewardGoal?
    @State private var goalPendingDeletion: RewardGoal?
    @State private var celebration: CelebrationMoment?

    private var goalSignature: String {
        goals.map { goal in
            [
                String(describing: goal.persistentModelID),
                goal.title,
                String(goal.targetAmount),
                String(goal.bankedAmount),
                String(goal.automaticSavingsBaseline),
                String(goal.usesAutomaticSavings),
                String(goal.isActive),
                String(goal.completedAt?.timeIntervalSince1970 ?? 0),
                String(goal.claimedAt?.timeIntervalSince1970 ?? 0)
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
                    let totalSaved = RewardMetrics.totalSaved(
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
                                emptyState(totalSaved)
                            } else {
                                activeGoalSection(totalSaved)
                                allGoalsSection(totalSaved)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .padding(.bottom, 38)
                    }
                    .onAppear {
                        reconcileGoals(totalSaved: totalSaved)
                    }
                    .onChange(
                        of: Int((totalSaved * 100).rounded())
                    ) { _, _ in
                        reconcileGoals(totalSaved: totalSaved)
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
                totalSaved: RewardMetrics.totalSaved(profile: profile),
                hasActiveGoal: RewardMetrics.activeGoal(in: goals) != nil
            )
        }
        .sheet(item: $contributionGoal) { goal in
            ContributionSheet(
                goal: goal,
                currencyCode: profile.currencyCode
            ) { amount in
                let totalSaved = RewardMetrics.totalSaved(profile: profile)
                RewardGoalCoordinator.addContribution(
                    amount,
                    to: goal,
                    totalSaved: totalSaved
                )

                let becameComplete = RewardGoalCoordinator.reconcileCompletion(
                    for: goal,
                    totalSaved: totalSaved
                )

                try? modelContext.save()

                if becameComplete {
                    celebration = .reward(goal)
                    Haptics.success()
                }
            }
        }
        .alert(
            "Delete this reward goal?",
            isPresented: Binding(
                get: { goalPendingDeletion != nil },
                set: { newValue in
                    if !newValue {
                        goalPendingDeletion = nil
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
        .onChange(of: goalSignature) { _, _ in
            reconcileGoals(
                totalSaved: RewardMetrics.totalSaved(
                    profile: profile
                )
            )
        }
    }

    private var header: some View {
        HStack(
            alignment: .bottom
        ) {
            SectionHeader(
                eyebrow: "Reward system",
                title: "Make quitting pay you."
            )

            Spacer()

            Button {
                showingAddGoal = true
            } label: {
                Image(systemName: "plus")
                    .font(
                        .system(
                            size: 17,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.black)
                    .frame(width: 46, height: 46)
                    .background(
                        BuiltTheme.accent,
                        in: Circle()
                    )
            }
            .accessibilityLabel("Add reward goal")
        }
    }

    private func savingsHero(
        _ totalSaved: Double
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            HStack {
                Image(systemName: "banknote.fill")
                    .font(
                        .system(
                            size: 22,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(BuiltTheme.accent)
                    .frame(width: 52, height: 52)
                    .background(
                        BuiltTheme.accent.opacity(0.12),
                        in: Circle()
                    )

                Spacer()

                Text("MONEY PROTECTED")
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .tracking(1.5)
                    .foregroundStyle(BuiltTheme.textSecondary)
            }

            Text(
                totalSaved.formatted(
                    .currency(code: normalizedCurrencyCode)
                    .precision(.fractionLength(0...2))
                )
            )
            .font(
                .system(
                    size: 46,
                    weight: .bold,
                    design: .rounded
                )
            )
            .tracking(-1.4)
            .foregroundStyle(BuiltTheme.textPrimary)
            .minimumScaleFactor(0.7)

            Text(
                "That money used to disappear in smoke. Now it can become something you can see, use, and remember."
            )
            .font(
                .system(
                    size: 15,
                    weight: .medium
                )
            )
            .foregroundStyle(BuiltTheme.textSecondary)
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

    private func emptyState(
        _ totalSaved: Double
    ) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "giftcard.fill")
                .font(
                    .system(
                        size: 48,
                        weight: .light
                    )
                )
                .foregroundStyle(BuiltTheme.accent)

            VStack(spacing: 9) {
                Text("Create your first reward")
                    .font(
                        .system(
                            size: 24,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(BuiltTheme.textPrimary)

                Text(
                    "Choose something worth earning. BUILT can automatically move your calculated cigarette savings toward it."
                )
                .font(.system(size: 14))
                .foregroundStyle(BuiltTheme.textSecondary)
                .multilineTextAlignment(.center)
            }

            Button {
                showingAddGoal = true
            } label: {
                HStack {
                    Text("Set a reward goal")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(BuiltPrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .builtCard(padding: 24)
    }

    @ViewBuilder
    private func activeGoalSection(
        _ totalSaved: Double
    ) -> some View {
        if let activeGoal = RewardMetrics.activeGoal(in: goals) {
            VStack(
                alignment: .leading,
                spacing: 14
            ) {
                SectionHeader(
                    eyebrow: "Current target",
                    title: "What you’re earning"
                )

                goalCard(
                    activeGoal,
                    totalSaved: totalSaved
                )
            }
        } else {
            VStack(
                alignment: .leading,
                spacing: 14
            ) {
                SectionHeader(
                    eyebrow: "Current target",
                    title: "Choose what comes next"
                )

                VStack(
                    alignment: .leading,
                    spacing: 14
                ) {
                    Text("No active reward")
                        .font(
                            .system(
                                size: 20,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(BuiltTheme.textPrimary)

                    Text(
                        "Activate any unfinished goal below, or create a new one. Only one goal automatically receives future savings at a time."
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(BuiltTheme.textSecondary)

                    Button {
                        showingAddGoal = true
                    } label: {
                        Label(
                            "Add another goal",
                            systemImage: "plus"
                        )
                    }
                    .buttonStyle(BuiltSecondaryButtonStyle())
                }
                .builtCard()
            }
        }
    }

    private func allGoalsSection(
        _ totalSaved: Double
    ) -> some View {
        let remainingGoals = goals.filter {
            !$0.isActive || $0.completedAt != nil
        }

        return VStack(
            alignment: .leading,
            spacing: 14
        ) {
            SectionHeader(
                eyebrow: "Reward vault",
                title: "Every goal",
                trailingText: "\(goals.count)"
            )

            if remainingGoals.isEmpty {
                Text(
                    "Your active goal is the only reward here right now."
                )
                .font(.system(size: 14))
                .foregroundStyle(BuiltTheme.textSecondary)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .builtCard()
            } else {
                ForEach(remainingGoals) { goal in
                    goalCard(
                        goal,
                        totalSaved: totalSaved
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
            currencyCode: profile.currencyCode,
            onAddContribution: {
                contributionGoal = goal
            },
            onActivate: {
                RewardGoalCoordinator.activate(
                    goal,
                    among: goals,
                    totalSaved: totalSaved
                )
                try? modelContext.save()
                Haptics.selection()
            },
            onPause: {
                RewardGoalCoordinator.pause(
                    goal,
                    totalSaved: totalSaved
                )
                try? modelContext.save()
                Haptics.selection()
            },
            onClaim: {
                RewardGoalCoordinator.markClaimed(goal)
                try? modelContext.save()
                Haptics.success()
            },
            onDelete: {
                goalPendingDeletion = goal
            }
        )
    }

    private var normalizedCurrencyCode: String {
        let cleaned = profile.currencyCode
            .uppercased()
            .filter(\.isLetter)

        return cleaned.count == 3 ? cleaned : "USD"
    }

    private func reconcileGoals(
        totalSaved: Double
    ) {
        var newlyCompleted: RewardGoal?

        for goal in goals {
            if RewardGoalCoordinator.reconcileCompletion(
                for: goal,
                totalSaved: totalSaved
            ) {
                newlyCompleted = goal
            }
        }

        guard let newlyCompleted else {
            return
        }

        try? modelContext.save()
        celebration = .reward(newlyCompleted)
        Haptics.success()
    }

    private func deletePendingGoal() {
        guard let goal = goalPendingDeletion else {
            return
        }

        modelContext.delete(goal)
        try? modelContext.save()
        goalPendingDeletion = nil
    }
}

private struct ContributionSheet: View {
    let goal: RewardGoal
    let currencyCode: String
    let onSave: (Double) -> Void

    @Environment(\.dismiss)
    private var dismiss

    @State private var amount = 10.0

    private var normalizedCurrencyCode: String {
        let cleaned = currencyCode
            .uppercased()
            .filter(\.isLetter)

        return cleaned.count == 3 ? cleaned : "USD"
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
                                    size: 11,
                                    weight: .bold
                                )
                            )
                            .tracking(1.7)
                            .foregroundStyle(BuiltTheme.accent)

                        Text(goal.title)
                            .font(
                                .system(
                                    size: 32,
                                    weight: .bold
                                )
                            )
                            .tracking(-0.9)
                            .foregroundStyle(BuiltTheme.textPrimary)
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 14
                    ) {
                        Text("Amount")
                            .font(
                                .system(
                                    size: 14,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(BuiltTheme.textSecondary)

                        HStack(
                            alignment: .firstTextBaseline
                        ) {
                            TextField(
                                "10",
                                value: $amount,
                                format: .number.precision(
                                    .fractionLength(0...2)
                                )
                            )
                            .keyboardType(.decimalPad)
                            .font(
                                .system(
                                    size: 44,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(BuiltTheme.textPrimary)

                            Text(normalizedCurrencyCode)
                                .font(
                                    .system(
                                        size: 14,
                                        weight: .bold,
                                        design: .monospaced
                                    )
                                )
                                .foregroundStyle(BuiltTheme.textSecondary)
                        }
                    }
                    .builtCard(padding: 20)

                    HStack(spacing: 10) {
                        ForEach([5.0, 10.0, 25.0, 50.0], id: \.self) { preset in
                            Button {
                                amount = preset
                                Haptics.selection()
                            } label: {
                                Text(
                                    preset.formatted(
                                        .currency(code: normalizedCurrencyCode)
                                        .precision(.fractionLength(0))
                                    )
                                )
                                .font(
                                    .system(
                                        size: 13,
                                        weight: .semibold
                                    )
                                )
                                .foregroundStyle(BuiltTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Color.white.opacity(0.07),
                                    in: Capsule()
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer()

                    Button {
                        guard amount > 0 else {
                            return
                        }

                        onSave(amount)
                        dismiss()
                    } label: {
                        HStack {
                            Text("Add contribution")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(BuiltPrimaryButtonStyle())
                    .disabled(amount <= 0)
                    .opacity(amount > 0 ? 1 : 0.45)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 30)
            }
            .navigationTitle("Add progress")
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(BuiltTheme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
