import Foundation
import WidgetKit

@MainActor
enum WidgetSyncService {
    static func sync(
        profile: QuitProfile,
        cravings: [CravingEntry],
        rewardGoals: [RewardGoal]
    ) {
        let defeatedCount = cravings.reduce(into: 0) { count, craving in
            if craving.outcome == .defeated {
                count += 1
            }
        }

        let now = Date.now
        let activeGoal = RewardMetrics.activeGoal(in: rewardGoals)
        let snapshot = WidgetSnapshot(
            quitDate: profile.quitDate,
            cigarettesPerDay: profile.cigarettesPerDay,
            cigarettesPerPack: profile.cigarettesPerPack,
            packPrice: profile.packPrice,
            currencyCode: profile.currencyCode,
            cravingsDefeated: defeatedCount,
            identityStatement: profile.identityStatement,
            lastUpdated: now,
            isConfigured: true,
            activeRewardTitle: activeGoal?.title,
            activeRewardIconName: activeGoal?.iconName,
            activeRewardBankedAmount: activeGoal?.bankedAmount,
            activeRewardAutomaticSavingsBaseline: activeGoal?.automaticSavingsBaseline,
            activeRewardUsesAutomaticSavings: activeGoal?.usesAutomaticSavings,
            activeRewardTargetAmount: activeGoal?.targetAmount
        )

        WidgetSnapshotStore.save(snapshot)
        WidgetCenter.shared.reloadTimelines(
            ofKind: BuiltSharedConstants.smokeFreeWidgetKind
        )
    }

    static func clear() {
        WidgetSnapshotStore.clear()
        WidgetCenter.shared.reloadTimelines(
            ofKind: BuiltSharedConstants.smokeFreeWidgetKind
        )
    }
}
