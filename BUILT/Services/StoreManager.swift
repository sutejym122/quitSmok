import Foundation
import StoreKit
import Combine
import OSLog

enum PurchaseStatus:
    Equatable {
    case idle
    case purchasing
    case pending
    case purchased
    case restoring
    case restored
}

@MainActor
final class StoreManager:
    ObservableObject {
    nonisolated
    static let proProductID =
        "com.sutej.built.pro.lifetime"

    @Published
    private(set)
    var proProduct: Product?

    @Published
    private(set)
    var hasPro: Bool

    @Published
    private(set)
    var status:
        PurchaseStatus = .idle

    @Published
    private(set)
    var isLoadingProducts = false

    @Published
    var purchaseError:
        PurchaseError?

    @Published
    var presentsPurchaseSuccess =
        false

    private let entitlementManager =
        EntitlementManager(
            productID:
                StoreManager.proProductID
        )

    private let entitlementCache:
        EntitlementCache

    private var transactionUpdatesTask:
        Task<Void, Never>?

    init(
        defaults:
            UserDefaults = .standard,
        automaticallyPrepares:
            Bool = true,
        observesTransactionUpdates:
            Bool = true
    ) {
        let cache =
            EntitlementCache(
                defaults: defaults
            )

        entitlementCache = cache
        hasPro = cache.load()

        if observesTransactionUpdates {
            observeTransactionUpdates()
        }

        if automaticallyPrepares {
            Task {
                await prepare()
            }
        }
    }

    deinit {
        transactionUpdatesTask?
            .cancel()
    }

    var displayPrice: String? {
        proProduct?.displayPrice
    }

    var isBusy: Bool {
        isLoadingProducts
        || status == .purchasing
        || status == .restoring
    }

    func prepare() async {
        await refreshEntitlements()

        guard proProduct == nil
        else {
            return
        }

        isLoadingProducts = true

        defer {
            isLoadingProducts = false
        }

        do {
            let products =
                try await Product
                    .products(
                        for: [
                            Self.proProductID
                        ]
                    )

            proProduct =
                products.first {
                    $0.id
                    == Self.proProductID
                }

            if proProduct == nil {
                purchaseError =
                    .productUnavailable
            }
        } catch {
            purchaseError =
                .productLoadingFailed(
                    error
                        .localizedDescription
                )

            BuiltLog.storeKit.error(
                "Failed to load BUILT Pro: \(error.localizedDescription, privacy: .private)"
            )
        }
    }

    func purchasePro() async {
        purchaseError = nil

        if hasPro {
            status = .purchased
            presentsPurchaseSuccess =
                true
            return
        }

        guard let proProduct
        else {
            purchaseError =
                .productUnavailable

            await prepare()
            return
        }

        status = .purchasing

        do {
            let result =
                try await proProduct
                    .purchase()

            switch result {
            case .success(
                let verificationResult
            ):
                let transaction =
                    try entitlementManager
                        .verifiedTransaction(
                            from:
                                verificationResult
                        )

                guard
                    transaction.productID
                    == Self.proProductID
                else {
                    throw PurchaseError
                        .verificationFailed
                }

                await transaction.finish()
                await refreshEntitlements()

                guard hasPro else {
                    throw PurchaseError
                        .verificationFailed
                }

                status = .purchased
                presentsPurchaseSuccess =
                    true
                Haptics.success()

            case .pending:
                status = .pending
                purchaseError =
                    .purchasePending

            case .userCancelled:
                status = .idle

            @unknown default:
                status = .idle
                purchaseError =
                    .purchaseFailed(
                        "The App Store returned an unknown purchase result."
                    )
            }
        } catch
            let error
                as PurchaseError {
            status = .idle
            purchaseError = error
            Haptics.warning()

            BuiltLog.storeKit.error(
                "BUILT Pro purchase failed with a controlled purchase error."
            )
        } catch {
            status = .idle
            purchaseError =
                .purchaseFailed(
                    error
                        .localizedDescription
                )
            Haptics.warning()

            BuiltLog.storeKit.error(
                "BUILT Pro purchase failed: \(error.localizedDescription, privacy: .private)"
            )
        }
    }

    func restorePurchases() async {
        purchaseError = nil
        status = .restoring

        do {
            try await AppStore.sync()
            await refreshEntitlements()

            guard hasPro else {
                status = .idle
                purchaseError =
                    .nothingToRestore
                return
            }

            status = .restored
            presentsPurchaseSuccess =
                true
            Haptics.success()
        } catch {
            status = .idle
            purchaseError =
                .restoreFailed(
                    error
                        .localizedDescription
                )
            Haptics.warning()

            BuiltLog.storeKit.error(
                "Restore purchases failed: \(error.localizedDescription, privacy: .private)"
            )
        }
    }

    func refreshEntitlements()
        async {
        let entitled =
            await entitlementManager
                .hasCurrentEntitlement()

        hasPro = entitled
        entitlementCache.save(
            entitled
        )

        BuiltLog.storeKit.info(
            "BUILT Pro entitlement refreshed. Active: \(entitled, privacy: .public)"
        )
    }

    func clearPresentationState() {
        purchaseError = nil
        presentsPurchaseSuccess =
            false

        if status != .pending {
            status = .idle
        }
    }

    private func observeTransactionUpdates() {
        transactionUpdatesTask =
            Task { [weak self] in
                for await result in
                    Transaction.updates {
                    guard let self
                    else {
                        return
                    }

                    await self
                        .processTransactionUpdate(
                            result
                        )
                }
            }
    }

    private func processTransactionUpdate(
        _ result:
            VerificationResult<Transaction>
    ) async {
        do {
            let transaction =
                try entitlementManager
                    .verifiedTransaction(
                        from: result
                    )

            guard
                transaction.productID
                == Self.proProductID
            else {
                return
            }

            await transaction.finish()
            await refreshEntitlements()

            if hasPro {
                status = .purchased
            }
        } catch {
            purchaseError =
                .verificationFailed

            BuiltLog.storeKit.error(
                "A StoreKit transaction update failed verification."
            )
        }
    }
}
