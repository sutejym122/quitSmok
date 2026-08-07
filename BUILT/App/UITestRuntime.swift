import Foundation
import SwiftData

struct UITestRuntime {
    enum Scenario:
        String,
        Sendable {
        case fresh
        case existingFree =
            "existing-free"
        case existingPro =
            "existing-pro"
        case planDaySeven =
            "plan-day-seven"
    }

    static let current =
        UITestRuntime()

    let isRunning: Bool
    let scenario: Scenario
    let launchURL: URL?
    let presentsPaywall: Bool

    var usesInMemoryStore: Bool {
        isRunning
    }

    var proEntitlementOverride:
        Bool? {
        guard isRunning else {
            return nil
        }

        switch scenario {
        case .fresh,
             .existingFree:
            return false

        case .existingPro,
             .planDaySeven:
            return true
        }
    }

    init(
        arguments:
            [String] =
                ProcessInfo
                    .processInfo
                    .arguments
    ) {
        #if DEBUG
        let active =
            arguments.contains(
                "--built-ui-testing"
            )
        #else
        let active = false
        #endif

        isRunning = active

        let scenarioValue =
            Self.value(
                after:
                    "--built-ui-scenario=",
                in: arguments
            )

        scenario =
            Scenario(
                rawValue:
                    scenarioValue
                    ?? ""
            )
            ?? .fresh

        let routeValue =
            Self.value(
                after:
                    "--built-ui-route=",
                in: arguments
            )

        if active,
           let routeValue {
            launchURL =
                URL(
                    string: routeValue
                )
        } else {
            launchURL = nil
        }

        presentsPaywall =
            active
            && arguments.contains(
                "--built-ui-present-paywall"
            )
    }

    @MainActor
    func seed(
        modelContainer:
            ModelContainer
    ) throws {
        guard isRunning else {
            return
        }

        BuiltPlanProgressStore.reset()

        switch scenario {
        case .fresh:
            return

        case .existingFree,
             .existingPro,
             .planDaySeven:
            let profile =
                QuitProfile(
                    quitDate:
                        Date.now
                            .addingTimeInterval(
                                -(3 * 86_400)
                            ),
                    cigarettesPerDay:
                        10,
                    cigarettesPerPack:
                        20,
                    packPrice: 15,
                    currencyCode:
                        "USD",
                    identityStatement:
                        "I protect the body and life I am building."
                )

            modelContainer
                .mainContext
                .insert(profile)

            try modelContainer
                .mainContext
                .save()

            if scenario ==
                .planDaySeven {
                let preferences =
                    OnboardingPreferencesStore
                        .load()

                var progress =
                    BuiltPlanProgress(
                        plan:
                            BuiltPlanEngine
                                .makePlan(
                                    preferences:
                                        preferences,
                                    generatedAt:
                                        Date(
                                            timeIntervalSince1970:
                                                1_700_000_000
                                        )
                                )
                    )

                for dayNumber in 1...6 {
                    progress.complete(
                        dayNumber:
                            dayNumber,
                        at:
                            Date(
                                timeIntervalSince1970:
                                    1_700_000_000
                                    + Double(
                                        dayNumber
                                    )
                            )
                    )
                }

                BuiltPlanProgressStore
                    .save(progress)
            }
        }
    }

    private static func value(
        after prefix: String,
        in arguments:
            [String]
    ) -> String? {
        arguments
            .first {
                $0.hasPrefix(prefix)
            }
            .map {
                String(
                    $0.dropFirst(
                        prefix.count
                    )
                )
            }
    }
}
