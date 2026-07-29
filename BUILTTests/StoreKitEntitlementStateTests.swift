import Foundation
import Testing

@testable import BUILT

@Suite("StoreKit Entitlement State")
struct StoreKitEntitlementStateTests {
    @Test(
        "A matching nonrevoked lifetime transaction unlocks Pro"
    )
    func matchingTransactionUnlocks() {
        let record =
            EntitlementRecord(
                productID:
                    StoreManager
                        .proProductID,
                revocationDate: nil
            )

        #expect(
            EntitlementEvaluator
                .isCurrentProEntitlement(
                    record,
                    productID:
                        StoreManager
                            .proProductID
                )
        )
    }

    @Test(
        "Wrong products and revoked transactions do not unlock Pro"
    )
    func invalidTransactionsRemainFree() {
        let wrongProduct =
            EntitlementRecord(
                productID:
                    "com.example.other",
                revocationDate: nil
            )

        let revoked =
            EntitlementRecord(
                productID:
                    StoreManager
                        .proProductID,
                revocationDate:
                    BuiltTestFixtures
                        .referenceDate
            )

        #expect(
            !EntitlementEvaluator
                .hasCurrentProEntitlement(
                    in: [
                        wrongProduct,
                        revoked
                    ],
                    productID:
                        StoreManager
                            .proProductID
                )
        )
    }

    @Test(
        "The entitlement cache round-trips in an isolated defaults suite"
    )
    func cacheRoundTrip() throws {
        let suiteName =
            "built.tests.entitlement.\(UUID().uuidString)"

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

        let cache =
            EntitlementCache(
                defaults: defaults
            )

        #expect(!cache.load())

        cache.save(true)
        #expect(cache.load())

        cache.save(false)
        #expect(!cache.load())

        cache.clear()
        #expect(!cache.load())
    }

    @Test(
        "StoreManager restores cached state without contacting StoreKit"
    )
    @MainActor
    func managerReadsCachedState()
        throws {
        let suiteName =
            "built.tests.store-manager.\(UUID().uuidString)"

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

        EntitlementCache(
            defaults: defaults
        )
        .save(true)

        let manager =
            StoreManager(
                defaults: defaults,
                automaticallyPrepares:
                    false,
                observesTransactionUpdates:
                    false
            )

        #expect(manager.hasPro)
        #expect(!manager.isBusy)
        #expect(
            manager.status == .idle
        )
    }

    @Test(
        "The shipping product identifier remains stable"
    )
    func productIdentifierIsStable() {
        #expect(
            StoreManager.proProductID
            == "com.sutej.built.pro.lifetime"
        )
    }
}
