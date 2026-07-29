import Foundation
import StoreKit

struct EntitlementManager {
    let productID: String

    func hasCurrentEntitlement()
        async -> Bool {
        for await result in
            Transaction
                .currentEntitlements {
            guard
                case .verified(
                    let transaction
                ) = result
            else {
                continue
            }

            let record =
                EntitlementRecord(
                    productID:
                        transaction.productID,
                    revocationDate:
                        transaction
                            .revocationDate
                )

            if EntitlementEvaluator
                .isCurrentProEntitlement(
                    record,
                    productID:
                        productID
                ) {
                return true
            }
        }

        return false
    }

    func verifiedTransaction(
        from result:
            VerificationResult<Transaction>
    ) throws -> Transaction {
        switch result {
        case .verified(
            let transaction
        ):
            return transaction

        case .unverified:
            throw PurchaseError
                .verificationFailed
        }
    }
}
