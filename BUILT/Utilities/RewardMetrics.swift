import Foundation

struct RewardGoalProgress: Equatable, Sendable {
    let currentAmount: Double
    let targetAmount: Double

    var fraction: Double {
        guard targetAmount > 0 else {
            return 0
        }

        return min(max(currentAmount / targetAmount, 0), 1)
    }

    var remainingAmount: Double {
        max(0, targetAmount - currentAmount)
    }

    var isComplete: Bool {
        targetAmount > 0 && currentAmount >= targetAmount
    }
}

enum RewardMetrics {
    static func totalSaved(
        profile: QuitProfile,
        now: Date = .now
    ) -> Double {
        QuitMetrics(
            profile: profile,
            now: now
        )
        .moneySaved
    }

    static func rawCurrentAmount(
        for goal: RewardGoal,
        totalSaved: Double
    ) -> Double {
        let automaticAmount: Double

        if goal.usesAutomaticSavings && goal.isActive && goal.completedAt == nil {
            automaticAmount = max(
                0,
                totalSaved - goal.automaticSavingsBaseline
            )
        } else {
            automaticAmount = 0
        }

        return max(0, goal.bankedAmount + automaticAmount)
    }

    static func progress(
        for goal: RewardGoal,
        totalSaved: Double
    ) -> RewardGoalProgress {
        RewardGoalProgress(
            currentAmount: min(
                rawCurrentAmount(
                    for: goal,
                    totalSaved: totalSaved
                ),
                max(goal.targetAmount, 0)
            ),
            targetAmount: max(goal.targetAmount, 0)
        )
    }

    static func activeGoal(
        in goals: [RewardGoal]
    ) -> RewardGoal? {
        goals.first {
            $0.isActive && $0.completedAt == nil
        }
    }
}

@MainActor
enum RewardGoalCoordinator {
    static func activate(
        _ goal: RewardGoal,
        among goals: [RewardGoal],
        totalSaved: Double
    ) {
        guard goal.completedAt == nil else {
            return
        }

        for candidate in goals where candidate !== goal && candidate.isActive {
            freezeAutomaticProgress(
                candidate,
                totalSaved: totalSaved
            )
            candidate.isActive = false
        }

        goal.isActive = true
        goal.automaticSavingsBaseline = totalSaved
    }

    static func pause(
        _ goal: RewardGoal,
        totalSaved: Double
    ) {
        freezeAutomaticProgress(
            goal,
            totalSaved: totalSaved
        )
        goal.isActive = false
    }

    static func addContribution(
        _ amount: Double,
        to goal: RewardGoal,
        totalSaved: Double
    ) {
        guard amount > 0 else {
            return
        }

        freezeAutomaticProgress(
            goal,
            totalSaved: totalSaved
        )
        goal.bankedAmount += amount

        if goal.isActive && goal.usesAutomaticSavings {
            goal.automaticSavingsBaseline = totalSaved
        }
    }

    @discardableResult
    static func reconcileCompletion(
        for goal: RewardGoal,
        totalSaved: Double,
        now: Date = .now
    ) -> Bool {
        guard goal.completedAt == nil else {
            return false
        }

        let rawAmount = RewardMetrics.rawCurrentAmount(
            for: goal,
            totalSaved: totalSaved
        )

        guard goal.targetAmount > 0,
              rawAmount >= goal.targetAmount else {
            return false
        }

        freezeAutomaticProgress(
            goal,
            totalSaved: totalSaved
        )
        goal.bankedAmount = max(
            goal.bankedAmount,
            goal.targetAmount
        )
        goal.isActive = false
        goal.completedAt = now
        return true
    }

    static func markClaimed(
        _ goal: RewardGoal,
        now: Date = .now
    ) {
        guard goal.completedAt != nil else {
            return
        }

        goal.claimedAt = now
    }

    private static func freezeAutomaticProgress(
        _ goal: RewardGoal,
        totalSaved: Double
    ) {
        guard goal.usesAutomaticSavings,
              goal.isActive,
              goal.completedAt == nil else {
            return
        }

        goal.bankedAmount += max(
            0,
            totalSaved - goal.automaticSavingsBaseline
        )
        goal.automaticSavingsBaseline = totalSaved
    }
}
