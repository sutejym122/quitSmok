import Foundation
import WidgetKit

@MainActor
enum WidgetSyncService {
    static func sync(
        profile: QuitProfile,
        cravings: [CravingEntry]
    ) {
        let defeatedCount = cravings.reduce(into: 0) { count, craving in
            if craving.outcome == .defeated {
                count += 1
            }
        }

        let snapshot = WidgetSnapshot(
            quitDate: profile.quitDate,
            cigarettesPerDay: profile.cigarettesPerDay,
            cigarettesPerPack: profile.cigarettesPerPack,
            packPrice: profile.packPrice,
            currencyCode: profile.currencyCode,
            cravingsDefeated: defeatedCount,
            identityStatement: profile.identityStatement,
            lastUpdated: .now,
            isConfigured: true
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
