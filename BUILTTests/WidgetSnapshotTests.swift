import Foundation
import Testing

@testable import BUILT

@Suite("Widget Snapshot")
struct WidgetSnapshotTests {
    @Test(
        "A complete widget snapshot survives JSON persistence"
    )
    func codableRoundTrip() throws {
        let snapshot =
            makeSnapshot()

        let data =
            try JSONEncoder()
                .encode(snapshot)

        let decoded =
            try JSONDecoder()
                .decode(
                    WidgetSnapshot.self,
                    from: data
                )

        #expect(decoded == snapshot)
    }

    @Test(
        "Widget calculations match app calculations"
    )
    func calculationParity() {
        let now =
            BuiltTestFixtures
                .referenceDate

        let snapshot =
            makeSnapshot(
                quitDate:
                    now.addingTimeInterval(
                        -(2 * 86_400)
                    ),
                cigarettesPerDay: 10,
                cigarettesPerPack: 20,
                packPrice: 15
            )

        #expect(
            snapshot.fullDays(at: now)
            == 2
        )

        #expect(
            snapshot
                .cigarettesAvoided(
                    at: now
                )
            == 20
        )

        #expect(
            snapshot.moneySaved(
                at: now
            )
            == 15
        )

        #expect(
            snapshot
                .compactElapsedText(
                    at: now
                )
            == "2d 0h"
        )
    }

    @Test(
        "Future dates and invalid currencies use safe fallbacks"
    )
    func safeFallbacks() {
        let now =
            BuiltTestFixtures
                .referenceDate

        let snapshot =
            makeSnapshot(
                quitDate:
                    now.addingTimeInterval(
                        3_600
                    ),
                currencyCode: "u$"
            )

        #expect(
            snapshot.elapsed(at: now)
            == 0
        )

        #expect(
            snapshot
                .cigarettesAvoided(
                    at: now
                )
            == 0
        )

        #expect(
            snapshot.moneySaved(
                at: now
            )
            == 0
        )

        #expect(
            snapshot
                .normalizedCurrencyCode
            == "USD"
        )
    }

    @Test(
        "Active reward progress includes automatic savings and caps at target"
    )
    func activeRewardProgress() {
        let now =
            BuiltTestFixtures
                .referenceDate

        let snapshot =
            makeSnapshot(
                quitDate:
                    now.addingTimeInterval(
                        -86_400
                    ),
                cigarettesPerDay: 20,
                cigarettesPerPack: 20,
                packPrice: 20,
                activeRewardTitle:
                    "Gym shoes",
                activeRewardBankedAmount:
                    20,
                activeRewardAutomaticSavingsBaseline:
                    5,
                activeRewardUsesAutomaticSavings:
                    true,
                activeRewardTargetAmount:
                    30
            )

        #expect(snapshot.hasActiveReward)

        #expect(
            snapshot
                .activeRewardCurrentAmount(
                    at: now
                )
            == 30
        )

        #expect(
            snapshot
                .activeRewardProgress(
                    at: now
                )
            == 1
        )
    }

    @Test(
        "Legacy snapshots without reward fields still decode"
    )
    func legacySnapshotDecodes()
        throws {
        let legacy =
            LegacyWidgetSnapshot(
                quitDate:
                    BuiltTestFixtures
                        .referenceDate,
                cigarettesPerDay: 10,
                cigarettesPerPack: 20,
                packPrice: 15,
                currencyCode: "USD",
                cravingsDefeated: 3,
                identityStatement:
                    "Legacy identity",
                lastUpdated:
                    BuiltTestFixtures
                        .referenceDate,
                isConfigured: true
            )

        let data =
            try JSONEncoder()
                .encode(legacy)

        let decoded =
            try JSONDecoder()
                .decode(
                    WidgetSnapshot.self,
                    from: data
                )

        #expect(
            decoded.activeRewardTitle
            == nil
        )

        #expect(
            decoded.cravingsDefeated
            == 3
        )

        #expect(decoded.isConfigured)
    }

    private func makeSnapshot(
        quitDate: Date =
            BuiltTestFixtures
                .referenceDate,
        cigarettesPerDay:
            Double = 10,
        cigarettesPerPack:
            Double = 20,
        packPrice: Double = 15,
        currencyCode:
            String = "USD",
        activeRewardTitle:
            String? = "Shoes",
        activeRewardBankedAmount:
            Double? = 10,
        activeRewardAutomaticSavingsBaseline:
            Double? = 0,
        activeRewardUsesAutomaticSavings:
            Bool? = false,
        activeRewardTargetAmount:
            Double? = 100
    ) -> WidgetSnapshot {
        WidgetSnapshot(
            quitDate: quitDate,
            cigarettesPerDay:
                cigarettesPerDay,
            cigarettesPerPack:
                cigarettesPerPack,
            packPrice: packPrice,
            currencyCode:
                currencyCode,
            cravingsDefeated: 4,
            identityStatement:
                "I protect what I built.",
            lastUpdated:
                BuiltTestFixtures
                    .referenceDate,
            isConfigured: true,
            activeRewardTitle:
                activeRewardTitle,
            activeRewardIconName:
                "gift.fill",
            activeRewardBankedAmount:
                activeRewardBankedAmount,
            activeRewardAutomaticSavingsBaseline:
                activeRewardAutomaticSavingsBaseline,
            activeRewardUsesAutomaticSavings:
                activeRewardUsesAutomaticSavings,
            activeRewardTargetAmount:
                activeRewardTargetAmount
        )
    }
}

private struct LegacyWidgetSnapshot:
    Codable {
    let quitDate: Date
    let cigarettesPerDay: Double
    let cigarettesPerPack: Double
    let packPrice: Double
    let currencyCode: String
    let cravingsDefeated: Int
    let identityStatement: String
    let lastUpdated: Date
    let isConfigured: Bool
}
