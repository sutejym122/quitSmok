
import Foundation
import SwiftData

enum CravingOutcome: String, Codable, CaseIterable {
    case defeated
    case smoked

    var title: String {
        switch self {
        case .defeated:
            return "Defeated"

        case .smoked:
            return "Smoked"
        }
    }
}

@Model
final class CravingEntry {
    var createdAt: Date
    var intensity: Int
    var trigger: String
    var replacementAction: String
    var outcomeRawValue: String

    var outcome: CravingOutcome {
        get {
            CravingOutcome(
                rawValue: outcomeRawValue
            ) ?? .defeated
        }

        set {
            outcomeRawValue = newValue.rawValue
        }
    }

    init(
        createdAt: Date = .now,
        intensity: Int,
        trigger: String,
        replacementAction: String,
        outcome: CravingOutcome
    ) {
        self.createdAt = createdAt
        self.intensity = intensity
        self.trigger = trigger
        self.replacementAction = replacementAction
        self.outcomeRawValue = outcome.rawValue
    }
}
