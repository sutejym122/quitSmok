import Foundation
import Testing

@testable import BUILT

@Suite("Reward Metrics")
struct RewardMetricsTests {
    @Test(
        "Progress clamps between zero and one"
    )
    func progressClamps() {
        let empty = RewardGoalProgress(
            currentAmount: -10,
            targetAmount: 100
        )

        #expect(empty.fraction == 0)
        #expect(
            empty.remainingAmount
            == 110
        )
        #expect(!empty.isComplete)

        let halfway = RewardGoalProgress(
            currentAmount: 50,
            targetAmount: 100
        )

        #expect(
            halfway.fraction == 0.5
        )
        #expect(
            halfway.remainingAmount
            == 50
        )
        #expect(!halfway.isComplete)

        let complete = RewardGoalProgress(
            currentAmount: 125,
            targetAmount: 100
        )

        #expect(complete.fraction == 1)
        #expect(
            complete.remainingAmount
            == 0
        )
        #expect(complete.isComplete)

        let invalid = RewardGoalProgress(
            currentAmount: 10,
            targetAmount: 0
        )

        #expect(invalid.fraction == 0)
        #expect(!invalid.isComplete)
    }

    @Test(
        "Active automatic rewards include savings since activation"
    )
    func activeAutomaticProgress() {
        let goal = RewardGoal(
            title: "New running shoes",
            targetAmount: 150,
            bankedAmount: 25,
            automaticSavingsBaseline: 100,
            usesAutomaticSavings: true,
            isActive: true
        )

        let raw =
            RewardMetrics.rawCurrentAmount(
                for: goal,
                totalSaved: 140
            )

        #expect(raw == 65)

        let progress =
            RewardMetrics.progress(
                for: goal,
                totalSaved: 140
            )

        #expect(
            progress.currentAmount
            == 65
        )
        #expect(
            progress.targetAmount
            == 150
        )
    }

    @Test(
        "Paused manual and completed rewards exclude future automatic savings"
    )
    func nonActiveRewardsExcludeAutomaticSavings() {
        let paused = RewardGoal(
            title: "Gym bag",
            targetAmount: 80,
            bankedAmount: 20,
            automaticSavingsBaseline: 50,
            usesAutomaticSavings: true,
            isActive: false
        )

        let manual = RewardGoal(
            title: "Protein",
            targetAmount: 60,
            bankedAmount: 12,
            automaticSavingsBaseline: 0,
            usesAutomaticSavings: false,
            isActive: true
        )

        let completed = RewardGoal(
            title: "Massage",
            targetAmount: 100,
            bankedAmount: 100,
            automaticSavingsBaseline: 20,
            usesAutomaticSavings: true,
            isActive: true,
            completedAt:
                BuiltTestFixtures
                    .referenceDate
        )

        #expect(
            RewardMetrics.rawCurrentAmount(
                for: paused,
                totalSaved: 500
            )
            == 20
        )

        #expect(
            RewardMetrics.rawCurrentAmount(
                for: manual,
                totalSaved: 500
            )
            == 12
        )

        #expect(
            RewardMetrics.rawCurrentAmount(
                for: completed,
                totalSaved: 500
            )
            == 100
        )
    }

    @Test(
        "Progress never displays more than the target"
    )
    func displayedProgressCapsAtTarget() {
        let goal = RewardGoal(
            title: "Weekend trip",
            targetAmount: 200,
            bankedAmount: 260,
            usesAutomaticSavings: false
        )

        let progress =
            RewardMetrics.progress(
                for: goal,
                totalSaved: 0
            )

        #expect(
            progress.currentAmount
            == 200
        )
        #expect(progress.fraction == 1)
        #expect(progress.isComplete)
    }

    @Test(
        "Active goal ignores completed goals"
    )
    func activeGoalSelection() {
        let completed = RewardGoal(
            title: "Completed",
            targetAmount: 50,
            isActive: true,
            completedAt:
                BuiltTestFixtures
                    .referenceDate
        )

        let active = RewardGoal(
            title: "Active",
            targetAmount: 100,
            isActive: true
        )

        let paused = RewardGoal(
            title: "Paused",
            targetAmount: 100,
            isActive: false
        )

        #expect(
            RewardMetrics.activeGoal(
                in: [
                    completed,
                    active,
                    paused
                ]
            )
            === active
        )
    }
}

@Suite("Reward Goal Coordinator")
struct RewardGoalCoordinatorTests {
    @Test(
        "Activating a new goal freezes the previous active goal"
    )
    @MainActor
    func activationTransfersAutomaticProgress() {
        let previous = RewardGoal(
            title: "Previous",
            targetAmount: 200,
            bankedAmount: 10,
            automaticSavingsBaseline: 100,
            usesAutomaticSavings: true,
            isActive: true
        )

        let next = RewardGoal(
            title: "Next",
            targetAmount: 300,
            usesAutomaticSavings: true,
            isActive: false
        )

        RewardGoalCoordinator.activate(
            next,
            among: [previous, next],
            totalSaved: 130
        )

        #expect(!previous.isActive)
        #expect(
            previous.bankedAmount == 40
        )
        #expect(
            previous
                .automaticSavingsBaseline
            == 130
        )

        #expect(next.isActive)
        #expect(
            next.automaticSavingsBaseline
            == 130
        )
    }

    @Test(
        "Pausing a goal preserves earned automatic progress"
    )
    @MainActor
    func pausingFreezesProgress() {
        let goal = RewardGoal(
            title: "Headphones",
            targetAmount: 200,
            bankedAmount: 5,
            automaticSavingsBaseline: 50,
            usesAutomaticSavings: true,
            isActive: true
        )

        RewardGoalCoordinator.pause(
            goal,
            totalSaved: 80
        )

        #expect(!goal.isActive)
        #expect(goal.bankedAmount == 35)
        #expect(
            goal.automaticSavingsBaseline
            == 80
        )
    }

    @Test(
        "Manual contributions preserve automatic progress before adding money"
    )
    @MainActor
    func addingContributionFreezesFirst() {
        let goal = RewardGoal(
            title: "Shoes",
            targetAmount: 150,
            bankedAmount: 10,
            automaticSavingsBaseline: 100,
            usesAutomaticSavings: true,
            isActive: true
        )

        RewardGoalCoordinator
            .addContribution(
                5,
                to: goal,
                totalSaved: 125
            )

        #expect(goal.bankedAmount == 40)
        #expect(
            goal.automaticSavingsBaseline
            == 125
        )
        #expect(goal.isActive)
    }

    @Test(
        "Completion happens once and a completed reward can be claimed"
    )
    @MainActor
    func completionAndClaim() {
        let completionDate =
            BuiltTestFixtures.referenceDate

        let claimDate =
            completionDate
                .addingTimeInterval(60)

        let goal = RewardGoal(
            title: "Recovery session",
            targetAmount: 50,
            bankedAmount: 10,
            automaticSavingsBaseline: 100,
            usesAutomaticSavings: true,
            isActive: true
        )

        let firstResult =
            RewardGoalCoordinator
                .reconcileCompletion(
                    for: goal,
                    totalSaved: 145,
                    now: completionDate
                )

        #expect(firstResult)
        #expect(!goal.isActive)
        #expect(goal.bankedAmount == 55)
        #expect(
            goal.completedAt
            == completionDate
        )

        let secondResult =
            RewardGoalCoordinator
                .reconcileCompletion(
                    for: goal,
                    totalSaved: 500,
                    now:
                        completionDate
                            .addingTimeInterval(
                                30
                            )
                )

        #expect(!secondResult)
        #expect(
            goal.completedAt
            == completionDate
        )

        RewardGoalCoordinator
            .markClaimed(
                goal,
                now: claimDate
            )

        #expect(
            goal.claimedAt == claimDate
        )
    }

    @Test(
        "Incomplete rewards cannot be claimed"
    )
    @MainActor
    func incompleteRewardCannotBeClaimed() {
        let goal = RewardGoal(
            title: "Incomplete",
            targetAmount: 100
        )

        RewardGoalCoordinator
            .markClaimed(
                goal,
                now:
                    BuiltTestFixtures
                        .referenceDate
            )

        #expect(goal.claimedAt == nil)
    }
}
