import Foundation
import Testing

@testable import BUILT

@Suite("Onboarding Preferences")
struct OnboardingPreferencesTests {
    @Test(
        "Default onboarding preferences stay useful and nonempty"
    )
    func defaultsAreStable() {
        let defaults =
            OnboardingPreferences.defaults

        #expect(
            defaults.fitnessIdentity
            == .buildingConsistency
        )

        #expect(
            defaults.quitReasons
            == [
                .protectBody,
                .takeControl
            ]
        )

        #expect(
            defaults.cravingTriggers
            == [
                .stress,
                .habit
            ]
        )

        #expect(
            defaults.rescueActions
            == [
                .drinkWater,
                .walk
            ]
        )
    }

    @Test(
        "Onboarding preferences survive JSON persistence"
    )
    func codableRoundTrip() throws {
        let original =
            OnboardingPreferences(
                fitnessIdentity:
                    .seriousTraining,
                quitReasons: [
                    .protectBody,
                    .breatheBetter,
                    .saveMoney
                ],
                cravingTriggers: [
                    .stress,
                    .coffee,
                    .driving
                ],
                rescueActions: [
                    .drinkWater,
                    .pushUps,
                    .leaveRoom
                ],
                completedAt:
                    BuiltTestFixtures
                        .referenceDate
            )

        let data = try JSONEncoder()
            .encode(original)

        let decoded = try JSONDecoder()
            .decode(
                OnboardingPreferences.self,
                from: data
            )

        #expect(decoded == original)
    }

    @Test(
        "Every onboarding option has a unique identifier and visible copy"
    )
    func optionCatalogIntegrity() {
        #expect(
            Set(
                FitnessIdentity
                    .allCases
                    .map(\.rawValue)
            )
            .count
            == FitnessIdentity
                .allCases
                .count
        )

        #expect(
            FitnessIdentity
                .allCases
                .allSatisfy {
                    !$0.title.isEmpty
                    && !$0.detail.isEmpty
                    && !$0
                        .identityStatement
                        .isEmpty
                    && !$0
                        .symbolName
                        .isEmpty
                }
        )

        #expect(
            QuitReason
                .allCases
                .allSatisfy {
                    !$0.title.isEmpty
                    && !$0
                        .identityStatement
                        .isEmpty
                    && !$0
                        .symbolName
                        .isEmpty
                }
        )

        #expect(
            CravingTrigger
                .allCases
                .allSatisfy {
                    !$0.title.isEmpty
                    && !$0
                        .symbolName
                        .isEmpty
                }
        )

        #expect(
            RescueAction
                .allCases
                .allSatisfy {
                    !$0.title.isEmpty
                    && !$0
                        .shortTitle
                        .isEmpty
                    && !$0
                        .symbolName
                        .isEmpty
                }
        )
    }
}

@Suite("Notification Preferences")
struct NotificationPreferencesTests {
    @Test(
        "Default notification schedule remains conservative"
    )
    func defaultsAreStable() {
        let defaults =
            NotificationPreferences
                .defaultValue

        #expect(
            !defaults.masterEnabled
        )

        #expect(
            defaults.morningEnabled
        )
        #expect(
            defaults.morningHour == 8
        )
        #expect(
            defaults.morningMinute == 0
        )

        #expect(
            defaults.eveningEnabled
        )
        #expect(
            defaults.eveningHour == 20
        )
        #expect(
            defaults.eveningMinute == 30
        )

        #expect(
            !defaults.riskEnabled
        )
        #expect(
            defaults.riskHour == 18
        )
        #expect(
            defaults.riskMinute == 0
        )

        #expect(
            defaults.milestonesEnabled
        )
    }

    @Test(
        "Notification preferences survive JSON persistence"
    )
    func codableRoundTrip() throws {
        let original =
            NotificationPreferences(
                masterEnabled: true,
                morningEnabled: true,
                morningHour: 7,
                morningMinute: 15,
                eveningEnabled: false,
                eveningHour: 21,
                eveningMinute: 45,
                riskEnabled: true,
                riskHour: 17,
                riskMinute: 30,
                milestonesEnabled: false
            )

        let data = try JSONEncoder()
            .encode(original)

        let decoded = try JSONDecoder()
            .decode(
                NotificationPreferences.self,
                from: data
            )

        #expect(decoded == original)
    }
}
