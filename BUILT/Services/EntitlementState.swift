import Foundation

struct EntitlementRecord:
    Equatable,
    Sendable {
    let productID: String
    let revocationDate: Date?
}

enum EntitlementEvaluator {
    static func isCurrentProEntitlement(
        _ record: EntitlementRecord,
        productID: String
    ) -> Bool {
        record.productID == productID
        && record.revocationDate == nil
    }

    static func hasCurrentProEntitlement(
        in records:
            [EntitlementRecord],
        productID: String
    ) -> Bool {
        records.contains {
            isCurrentProEntitlement(
                $0,
                productID: productID
            )
        }
    }
}

struct EntitlementCache {
    static let defaultKey =
        "built.pro.cached-entitlement.v1"

    let defaults: UserDefaults
    let key: String

    init(
        defaults:
            UserDefaults = .standard,
        key: String = defaultKey
    ) {
        self.defaults = defaults
        self.key = key
    }

    func load() -> Bool {
        defaults.bool(
            forKey: key
        )
    }

    func save(
        _ isEntitled: Bool
    ) {
        defaults.set(
            isEntitled,
            forKey: key
        )
    }

    func clear() {
        defaults.removeObject(
            forKey: key
        )
    }
}
