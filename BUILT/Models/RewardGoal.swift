import Foundation
import SwiftData

@Model
final class RewardGoal {
    var title: String
    var targetAmount: Double
    var iconName: String
    var note: String
    var bankedAmount: Double
    var automaticSavingsBaseline: Double
    var usesAutomaticSavings: Bool
    var isActive: Bool
    var createdAt: Date
    var completedAt: Date?
    var claimedAt: Date?

    init(
        title: String,
        targetAmount: Double,
        iconName: String = "gift.fill",
        note: String = "",
        bankedAmount: Double = 0,
        automaticSavingsBaseline: Double = 0,
        usesAutomaticSavings: Bool = true,
        isActive: Bool = false,
        createdAt: Date = .now,
        completedAt: Date? = nil,
        claimedAt: Date? = nil
    ) {
        self.title = title
        self.targetAmount = targetAmount
        self.iconName = iconName
        self.note = note
        self.bankedAmount = bankedAmount
        self.automaticSavingsBaseline = automaticSavingsBaseline
        self.usesAutomaticSavings = usesAutomaticSavings
        self.isActive = isActive
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.claimedAt = claimedAt
    }
}
