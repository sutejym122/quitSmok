import Foundation
import WidgetKit
import OSLog

@MainActor
enum WidgetSyncService {
    static func makeSnapshot(
        profile: QuitProfile,
        cravings: [CravingEntry],
        rewardGoals: [RewardGoal],
        now: Date = .now
    ) -> WidgetSnapshot {
        let defeatedCount =
            cravings.reduce(
                into: 0
            ) {
                count,
                craving in

                if craving.outcome
                    == .defeated {
                    count += 1
                }
            }

        let activeGoal =
            RewardMetrics.activeGoal(
                in: rewardGoals
            )

        return WidgetSnapshot(
            quitDate:
                profile.quitDate,
            cigarettesPerDay:
                profile
                    .cigarettesPerDay,
            cigarettesPerPack:
                profile
                    .cigarettesPerPack,
            packPrice:
                profile.packPrice,
            currencyCode:
                profile.currencyCode,
            cravingsDefeated:
                defeatedCount,
            identityStatement:
                profile
                    .identityStatement,
            lastUpdated: now,
            isConfigured: true,
            activeRewardTitle:
                activeGoal?.title,
            activeRewardIconName:
                activeGoal?.iconName,
            activeRewardBankedAmount:
                activeGoal?
                    .bankedAmount,
            activeRewardAutomaticSavingsBaseline:
                activeGoal?
                    .automaticSavingsBaseline,
            activeRewardUsesAutomaticSavings:
                activeGoal?
                    .usesAutomaticSavings,
            activeRewardTargetAmount:
                activeGoal?
                    .targetAmount
        )
    }

    static func sync(
        profile: QuitProfile,
        cravings: [CravingEntry],
        rewardGoals: [RewardGoal]
    ) {
        let snapshot =
            makeSnapshot(
                profile: profile,
                cravings: cravings,
                rewardGoals:
                    rewardGoals
            )

        let saved =
            WidgetSnapshotStore.save(
                snapshot
            )

        if !saved {
            BuiltLog.widgets.error(
                "The widget snapshot could not be saved to the app group."
            )
        }

        WidgetCenter.shared
            .reloadTimelines(
                ofKind:
                    BuiltSharedConstants
                        .smokeFreeWidgetKind
            )
    }

    static func clear() {
        WidgetSnapshotStore.clear()

        WidgetCenter.shared
            .reloadTimelines(
                ofKind:
                    BuiltSharedConstants
                        .smokeFreeWidgetKind
            )
    }
}
