import Foundation
import Combine

@MainActor
final class OnboardingDraft: ObservableObject {
    @Published var quitDate: Date = .now
    @Published var cigarettesPerDay: Double = 10
    @Published var cigarettesPerPack: Double = 20
    @Published var packPrice: Double = 12
    @Published var currencyCode: String = "USD"

    @Published var fitnessIdentity: FitnessIdentity =
        .buildingConsistency

    @Published var quitReasons: Set<QuitReason> = [
        .protectBody,
        .takeControl
    ]

    @Published var cravingTriggers: Set<CravingTrigger> = [
        .stress,
        .habit
    ]

    @Published var rescueActions: Set<RescueAction> = [
        .drinkWater,
        .walk
    ]

    @Published var identityStatement =
        "I protect the body and life I am building."

    @Published var customReason = ""
    @Published var motivationPhotoData: Data?
    @Published var motivationPhotoCaption =
        "Protect what you built."

    @Published private(set) var identityWasEdited = false

    var isSmokingPatternValid: Bool {
        cigarettesPerDay > 0
            && cigarettesPerPack > 0
            && packPrice >= 0
            && normalizedCurrencyCode.count == 3
            && quitDate <= .now
    }

    var normalizedCurrencyCode: String {
        let cleaned = currencyCode
            .uppercased()
            .filter(\.isLetter)

        return String(cleaned.prefix(3))
    }

    var sortedReasons: [QuitReason] {
        QuitReason.allCases.filter {
            quitReasons.contains($0)
        }
    }

    var sortedTriggers: [CravingTrigger] {
        CravingTrigger.allCases.filter {
            cravingTriggers.contains($0)
        }
    }

    var sortedRescueActions: [RescueAction] {
        RescueAction.allCases.filter {
            rescueActions.contains($0)
        }
    }

    var projectedThirtyDayCigarettes: Int {
        Int(
            floor(
                max(0, cigarettesPerDay) * 30
            )
        )
    }

    var projectedThirtyDaySavings: Double {
        let packSize = max(
            1,
            cigarettesPerPack
        )

        return max(0, cigarettesPerDay)
            * 30
            / packSize
            * max(0, packPrice)
    }

    func selectFitnessIdentity(
        _ identity: FitnessIdentity
    ) {
        fitnessIdentity = identity

        guard !identityWasEdited else {
            return
        }

        identityStatement = identity.identityStatement
    }

    func toggleReason(_ reason: QuitReason) {
        if quitReasons.contains(reason) {
            quitReasons.remove(reason)
        } else {
            quitReasons.insert(reason)

            guard !identityWasEdited else {
                return
            }

            identityStatement = reason.identityStatement
        }
    }

    func toggleTrigger(_ trigger: CravingTrigger) {
        if cravingTriggers.contains(trigger) {
            cravingTriggers.remove(trigger)
        } else {
            cravingTriggers.insert(trigger)
        }
    }

    func toggleRescueAction(
        _ action: RescueAction
    ) {
        if rescueActions.contains(action) {
            rescueActions.remove(action)
        } else {
            rescueActions.insert(action)
        }
    }

    func markIdentityEdited() {
        identityWasEdited = true
    }

    func applyCustomReasonIfNeeded() {
        let cleaned = customReason
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleaned.isEmpty else {
            return
        }

        identityStatement = cleaned
        identityWasEdited = true
    }

    func makePreferences() -> OnboardingPreferences {
        OnboardingPreferences(
            fitnessIdentity: fitnessIdentity,
            quitReasons: sortedReasons,
            cravingTriggers:
                sortedTriggers.isEmpty
                ? [.stress]
                : sortedTriggers,
            rescueActions:
                sortedRescueActions.isEmpty
                ? [.drinkWater]
                : sortedRescueActions,
            completedAt: .now
        )
    }
}
