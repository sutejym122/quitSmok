import Foundation

public struct WidgetSnapshot: Codable, Equatable, Sendable {
    public var quitDate: Date
    public var cigarettesPerDay: Double
    public var cigarettesPerPack: Double
    public var packPrice: Double
    public var currencyCode: String
    public var cravingsDefeated: Int
    public var identityStatement: String
    public var lastUpdated: Date
    public var isConfigured: Bool

    public init(
        quitDate: Date,
        cigarettesPerDay: Double,
        cigarettesPerPack: Double,
        packPrice: Double,
        currencyCode: String,
        cravingsDefeated: Int,
        identityStatement: String,
        lastUpdated: Date = .now,
        isConfigured: Bool = true
    ) {
        self.quitDate = quitDate
        self.cigarettesPerDay = cigarettesPerDay
        self.cigarettesPerPack = cigarettesPerPack
        self.packPrice = packPrice
        self.currencyCode = currencyCode
        self.cravingsDefeated = cravingsDefeated
        self.identityStatement = identityStatement
        self.lastUpdated = lastUpdated
        self.isConfigured = isConfigured
    }

    public static let placeholder = WidgetSnapshot(
        quitDate: Date.now.addingTimeInterval(-36 * 3_600),
        cigarettesPerDay: 10,
        cigarettesPerPack: 20,
        packPrice: 15,
        currencyCode: "USD",
        cravingsDefeated: 4,
        identityStatement: "I protect the body and life I am building.",
        isConfigured: false
    )

    public func elapsed(at date: Date) -> TimeInterval {
        max(0, date.timeIntervalSince(quitDate))
    }

    public func fullDays(at date: Date) -> Int {
        Int(elapsed(at: date) / 86_400)
    }

    public func cigarettesAvoided(at date: Date) -> Int {
        let avoided = elapsed(at: date) / 86_400 * max(0, cigarettesPerDay)
        return Int(floor(avoided))
    }

    public func moneySaved(at date: Date) -> Double {
        let packSize = max(1, cigarettesPerPack)
        let avoided = elapsed(at: date) / 86_400 * max(0, cigarettesPerDay)
        return avoided / packSize * max(0, packPrice)
    }

    public func formattedMoney(at date: Date) -> String {
        moneySaved(at: date).formatted(
            .currency(code: normalizedCurrencyCode)
            .precision(.fractionLength(0...2))
        )
    }

    public func compactElapsedText(at date: Date) -> String {
        let totalSeconds = Int(elapsed(at: date))
        let days = totalSeconds / 86_400
        let hours = (totalSeconds % 86_400) / 3_600

        if days > 0 {
            return "\(days)d \(hours)h"
        }

        let minutes = (totalSeconds % 3_600) / 60
        return "\(hours)h \(minutes)m"
    }

    public var normalizedCurrencyCode: String {
        let cleaned = currencyCode
            .uppercased()
            .filter(\.isLetter)

        return cleaned.count == 3 ? cleaned : "USD"
    }
}
