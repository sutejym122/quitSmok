import Foundation
import Testing

@testable import BUILT

@Suite("Widget Synchronization")
@MainActor
struct WidgetSyncServiceTests {
    @Test(
        "Snapshot construction counts wins and carries the active reward"
    )
    func buildsExpectedSnapshot() {
        let profile =
            BuiltTestFixtures
                .makeProfile(
                    identityStatement:
                        "Widget identity."
                )

        let cravings = [
            CravingEntry(
                intensity: 4,   
                trigger: "Stress",
                replacementAction:
                    "Walk",
                outcome: .defeated
            ),
            CravingEntry(
                intensity: 8,
                trigger: "Coffee",
                replacementAction:
                    "Water",
                outcome: .smoked
            ),
            CravingEntry(
                intensity: 5,
                trigger: "Driving",
                replacementAction:
                    "Breathe",
                outcome: .defeated
            )
        ]

        let activeReward =
            RewardGoal(
                title:
                    "Training shoes",
                targetAmount: 150,
                iconName:
                    "figure.run",
                bankedAmount: 25,
                automaticSavingsBaseline:
                    10,
                usesAutomaticSavings:
                    true,
                isActive: true
            )

        let pausedReward =
            RewardGoal(
                title: "Paused",
                targetAmount: 50,
                isActive: false
            )

        let snapshot =
            WidgetSyncService
                .makeSnapshot(
                    profile: profile,
                    cravings: cravings,
                    rewardGoals: [
                        pausedReward,
                        activeReward
                    ],
                    now:
                        BuiltTestFixtures
                            .referenceDate
                )

        #expect(
            snapshot.cravingsDefeated
            == 2
        )

        #expect(
            snapshot.identityStatement
            == "Widget identity."
        )

        #expect(
            snapshot.activeRewardTitle
            == "Training shoes"
        )

        #expect(
            snapshot
                .activeRewardTargetAmount
            == 150
        )

        #expect(snapshot.isConfigured)
    }
}
