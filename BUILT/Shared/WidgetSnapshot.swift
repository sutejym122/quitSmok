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

    public var activeRewardTitle: String?
    public var activeRewardIconName: String?
    public var activeRewardBankedAmount: Double?
    public var activeRewardAutomaticSavingsBaseline: Double?
    public var activeRewardUsesAutomaticSavings: Bool?
    public var activeRewardTargetAmount: Double?

    public init(
        quitDate: Date,
        cigarettesPerDay: Double,
        cigarettesPerPack: Double,
        packPrice: Double,
        currencyCode: String,
        cravingsDefeated: Int,
        identityStatement: String,
        lastUpdated: Date = .now,
        isConfigured: Bool = true,
        activeRewardTitle: String? = nil,
        activeRewardIconName: String? = nil,
        activeRewardBankedAmount: Double? = nil,
        activeRewardAutomaticSavingsBaseline: Double? = nil,
        activeRewardUsesAutomaticSavings: Bool? = nil,
        activeRewardTargetAmount: Double? = nil
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
        self.activeRewardTitle = activeRewardTitle
        self.activeRewardIconName = activeRewardIconName
        self.activeRewardBankedAmount = activeRewardBankedAmount
        self.activeRewardAutomaticSavingsBaseline = activeRewardAutomaticSavingsBaseline
        self.activeRewardUsesAutomaticSavings = activeRewardUsesAutomaticSavings
        self.activeRewardTargetAmount = activeRewardTargetAmount
    }

    private enum CodingKeys: String, CodingKey {
        case quitDate
        case cigarettesPerDay
        case cigarettesPerPack
        case packPrice
        case currencyCode
        case cravingsDefeated
        case identityStatement
        case lastUpdated
        case isConfigured
        case activeRewardTitle
        case activeRewardIconName
        case activeRewardBankedAmount
        case activeRewardAutomaticSavingsBaseline
        case activeRewardUsesAutomaticSavings
        case activeRewardTargetAmount
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        quitDate = try container.decode(
            Date.self,
            forKey: .quitDate
        )

        cigarettesPerDay = try container.decode(
            Double.self,
            forKey: .cigarettesPerDay
        )

        cigarettesPerPack = try container.decode(
            Double.self,
            forKey: .cigarettesPerPack
        )

        packPrice = try container.decode(
            Double.self,
            forKey: .packPrice
        )

        currencyCode = try container.decode(
            String.self,
            forKey: .currencyCode
        )

        cravingsDefeated = try container.decode(
            Int.self,
            forKey: .cravingsDefeated
        )

        identityStatement = try container.decode(
            String.self,
            forKey: .identityStatement
        )

        lastUpdated = try container.decode(
            Date.self,
            forKey: .lastUpdated
        )

        isConfigured = try container.decode(
            Bool.self,
            forKey: .isConfigured
        )

        activeRewardTitle = try container.decodeIfPresent(
            String.self,
            forKey: .activeRewardTitle
        )

        activeRewardIconName = try container.decodeIfPresent(
            String.self,
            forKey: .activeRewardIconName
        )

        activeRewardBankedAmount = try container.decodeIfPresent(
            Double.self,
            forKey: .activeRewardBankedAmount
        )

        activeRewardAutomaticSavingsBaseline = try container.decodeIfPresent(
            Double.self,
            forKey: .activeRewardAutomaticSavingsBaseline
        )

        activeRewardUsesAutomaticSavings = try container.decodeIfPresent(
            Bool.self,
            forKey: .activeRewardUsesAutomaticSavings
        )

        activeRewardTargetAmount = try container.decodeIfPresent(
            Double.self,
            forKey: .activeRewardTargetAmount
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        try container.encode(
            quitDate,
            forKey: .quitDate
        )

        try container.encode(
            cigarettesPerDay,
            forKey: .cigarettesPerDay
        )

        try container.encode(
            cigarettesPerPack,
            forKey: .cigarettesPerPack
        )

        try container.encode(
            packPrice,
            forKey: .packPrice
        )

        try container.encode(
            currencyCode,
            forKey: .currencyCode
        )

        try container.encode(
            cravingsDefeated,
            forKey: .cravingsDefeated
        )

        try container.encode(
            identityStatement,
            forKey: .identityStatement
        )

        try container.encode(
            lastUpdated,
            forKey: .lastUpdated
        )

        try container.encode(
            isConfigured,
            forKey: .isConfigured
        )

        try container.encodeIfPresent(
            activeRewardTitle,
            forKey: .activeRewardTitle
        )

        try container.encodeIfPresent(
            activeRewardIconName,
            forKey: .activeRewardIconName
        )

        try container.encodeIfPresent(
            activeRewardBankedAmount,
            forKey: .activeRewardBankedAmount
        )

        try container.encodeIfPresent(
            activeRewardAutomaticSavingsBaseline,
            forKey: .activeRewardAutomaticSavingsBaseline
        )

        try container.encodeIfPresent(
            activeRewardUsesAutomaticSavings,
            forKey: .activeRewardUsesAutomaticSavings
        )

        try container.encodeIfPresent(
            activeRewardTargetAmount,
            forKey: .activeRewardTargetAmount
        )
    }

    public static let placeholder = WidgetSnapshot(
        quitDate: Date.now.addingTimeInterval(
            -36 * 3_600
        ),
        cigarettesPerDay: 10,
        cigarettesPerPack: 20,
        packPrice: 15,
        currencyCode: "USD",
        cravingsDefeated: 4,
        identityStatement:
            "I protect the body and life I am building.",
        isConfigured: false
    )

    public func elapsed(
        at date: Date
    ) -> TimeInterval {
        max(
            0,
            date.timeIntervalSince(quitDate)
        )
    }

    public func fullDays(
        at date: Date
    ) -> Int {
        Int(
            elapsed(at: date) / 86_400
        )
    }

    public func cigarettesAvoided(
        at date: Date
    ) -> Int {
        let avoided =
            elapsed(at: date)
            / 86_400
            * max(
                0,
                cigarettesPerDay
            )

        return Int(
            floor(avoided)
        )
    }

    public func moneySaved(
        at date: Date
    ) -> Double {
        let packSize = max(
            1,
            cigarettesPerPack
        )

        let avoided =
            elapsed(at: date)
            / 86_400
            * max(
                0,
                cigarettesPerDay
            )

        return avoided
            / packSize
            * max(
                0,
                packPrice
            )
    }

    public func formattedMoney(
        at date: Date
    ) -> String {
        moneySaved(at: date).formatted(
            .currency(
                code: normalizedCurrencyCode
            )
            .precision(
                .fractionLength(0...2)
            )
        )
    }

    public func compactElapsedText(
        at date: Date
    ) -> String {
        let totalSeconds = Int(
            elapsed(at: date)
        )

        let days =
            totalSeconds / 86_400

        let hours =
            (totalSeconds % 86_400)
            / 3_600

        if days > 0 {
            return "\(days)d \(hours)h"
        }

        let minutes =
            (totalSeconds % 3_600)
            / 60

        return "\(hours)h \(minutes)m"
    }

    public var normalizedCurrencyCode: String {
        let cleaned = currencyCode
            .uppercased()
            .filter(\.isLetter)

        return cleaned.count == 3
            ? cleaned
            : "USD"
    }

    public var hasActiveReward: Bool {
        guard
            let activeRewardTitle,
            !activeRewardTitle.isEmpty,
            let activeRewardTargetAmount,
            activeRewardTargetAmount > 0
        else {
            return false
        }

        return true
    }

    public func activeRewardCurrentAmount(
        at date: Date
    ) -> Double? {
        guard
            hasActiveReward,
            let target =
                activeRewardTargetAmount
        else {
            return nil
        }

        let banked = max(
            0,
            activeRewardBankedAmount ?? 0
        )

        let automaticAmount: Double

        if activeRewardUsesAutomaticSavings == true {
            automaticAmount = max(
                0,
                moneySaved(at: date)
                    - (
                        activeRewardAutomaticSavingsBaseline
                        ?? 0
                    )
            )
        } else {
            automaticAmount = 0
        }

        return min(
            banked + automaticAmount,
            target
        )
    }

    public func activeRewardProgress(
        at date: Date
    ) -> Double {
        guard
            let current =
                activeRewardCurrentAmount(
                    at: date
                ),
            let target =
                activeRewardTargetAmount,
            target > 0
        else {
            return 0
        }

        return min(
            max(
                current / target,
                0
            ),
            1
        )
    }

    public func formattedActiveRewardCurrent(
        at date: Date
    ) -> String? {
        guard
            let current =
                activeRewardCurrentAmount(
                    at: date
                )
        else {
            return nil
        }

        return current.formatted(
            .currency(
                code: normalizedCurrencyCode
            )
            .precision(
                .fractionLength(0...2)
            )
        )
    }

    public var formattedActiveRewardTarget: String? {
        guard
            let activeRewardTargetAmount
        else {
            return nil 
        }

        return activeRewardTargetAmount.formatted(
            .currency(
                code: normalizedCurrencyCode
            )
            .precision(
                .fractionLength(0...2)
            )
        )
    }
}
