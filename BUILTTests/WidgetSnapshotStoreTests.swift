import Foundation
import Testing

@testable import BUILT

@Suite(
    "Widget Snapshot Store",
    .serialized
)
struct WidgetSnapshotStoreTests {
    @Test(
        "A snapshot saves loads and clears in an isolated defaults suite"
    )
    func saveLoadAndClear()
        throws {
        let suiteName =
            "built.tests.widget.\(UUID().uuidString)"

        let defaults =
            try #require(
                UserDefaults(
                    suiteName: suiteName
                )
            )

        defer {
            defaults
                .removePersistentDomain(
                    forName:
                        suiteName
                )
        }

        let snapshot =
            WidgetSnapshot(
                quitDate:
                    BuiltTestFixtures
                        .referenceDate,
                cigarettesPerDay: 10,
                cigarettesPerPack: 20,
                packPrice: 15,
                currencyCode: "USD",
                cravingsDefeated: 5,
                identityStatement:
                    "Stored safely.",
                lastUpdated:
                    BuiltTestFixtures
                        .referenceDate,
                isConfigured: true
            )

        let saved =
            WidgetSnapshotStore.save(
                snapshot,
                to: defaults
            )

        #expect(saved)

        let loaded =
            WidgetSnapshotStore.load(
                from: defaults
            )

        #expect(loaded == snapshot)

        WidgetSnapshotStore.clear(
            from: defaults
        )

        let cleared =
            WidgetSnapshotStore.load(
                from: defaults
            )

        #expect(
            cleared.isConfigured
            == false
        )
    }

    @Test(
        "Corrupt widget data returns the safe placeholder"
    )
    func corruptDataUsesPlaceholder()
        throws {
        let suiteName =
            "built.tests.widget.corrupt.\(UUID().uuidString)"

        let defaults =
            try #require(
                UserDefaults(
                    suiteName: suiteName
                )
            )

        defer {
            defaults
                .removePersistentDomain(
                    forName:
                        suiteName
                )
        }

        defaults.set(
            Data([
                0xFF,
                0x00,
                0xAB
            ]),
            forKey:
                BuiltSharedConstants
                    .widgetSnapshotKey
        )

        let loaded =
            WidgetSnapshotStore.load(
                from: defaults
            )

        #expect(
            loaded.isConfigured
            == false
        )
    }
}
