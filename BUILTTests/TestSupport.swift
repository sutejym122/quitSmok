import Foundation

@testable import BUILT

enum BuiltTestFixtures {
    static let referenceDate = Date(
        timeIntervalSince1970:
            2_000_000_000
    )

    static func makeProfile(
        quitDate: Date? = nil,
        cigarettesPerDay: Double = 20,
        cigarettesPerPack: Double = 20,
        packPrice: Double = 15,
        currencyCode: String = "USD",
        identityStatement: String =
            "I protect what I built.",
        slipCount: Int = 0
    ) -> QuitProfile {
        QuitProfile(
            quitDate:
                quitDate
                ?? referenceDate,
            cigarettesPerDay:
                cigarettesPerDay,
            cigarettesPerPack:
                cigarettesPerPack,
            packPrice:
                packPrice,
            currencyCode:
                currencyCode,
            identityStatement:
                identityStatement,
            slipCount:
                slipCount,
            createdAt:
                referenceDate
        )
    }

    static func approximatelyEqual(
        _ lhs: Double,
        _ rhs: Double,
        tolerance: Double = 0.000_001
    ) -> Bool {
        abs(lhs - rhs) <= tolerance
    }
}
