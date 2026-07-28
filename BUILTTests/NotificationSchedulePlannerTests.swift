import Foundation
import Testing

@testable import BUILT

@Suite("Notification Scheduling")
struct NotificationSchedulePlannerTests {
    private let planner =
        NotificationSchedulePlanner()

    @Test(
        "A disabled master switch produces no requests"
    )
    func masterDisabled() {
        var preferences =
            NotificationPreferences
                .defaultValue

        preferences.masterEnabled =
            false

        let plan = planner.makePlan(
            preferences: preferences,
            profile: profile()
        )

        #expect(plan.isEmpty)
    }

    @Test(
        "Daily schedules clamp invalid hours and preserve routes"
    )
    func dailyScheduleClamps() throws {
        let preferences =
            NotificationPreferences(
                masterEnabled: true,
                morningEnabled: true,
                morningHour: -4,
                morningMinute: 75,
                eveningEnabled: true,
                eveningHour: 25,
                eveningMinute: -2,
                riskEnabled: true,
                riskHour: 18,
                riskMinute: 30,
                milestonesEnabled:
                    false
            )

        let plan = planner.makePlan(
            preferences: preferences,
            profile: profile()
        )

        #expect(plan.count == 3)

        let morning =
            try #require(
                plan.first {
                    $0.identifier
                    == NotificationSchedulePlanner
                        .morningIdentifier
                }
            )

        let evening =
            try #require(
                plan.first {
                    $0.identifier
                    == NotificationSchedulePlanner
                        .eveningIdentifier
                }
            )

        let risk =
            try #require(
                plan.first {
                    $0.identifier
                    == NotificationSchedulePlanner
                        .riskIdentifier
                }
            )

        #expect(
            morning.trigger
            == .daily(
                hour: 0,
                minute: 59
            )
        )

        #expect(
            evening.trigger
            == .daily(
                hour: 23,
                minute: 0
            )
        )

        #expect(
            risk.routeURL
            == BuiltSharedConstants
                .rescueURL
        )

        #expect(
            morning.routeURL
            == BuiltSharedConstants
                .todayURL
        )
    }

    @Test(
        "Morning reminders use the identity or safe fallback"
    )
    func morningBodySelection()
        throws {
        var preferences =
            NotificationPreferences
                .defaultValue

        preferences.masterEnabled = true
        preferences.eveningEnabled =
            false
        preferences.riskEnabled = false
        preferences.milestonesEnabled =
            false

        let personalized =
            planner.makePlan(
                preferences:
                    preferences,
                profile:
                    NotificationScheduleProfile(
                        quitDate:
                            BuiltTestFixtures
                                .referenceDate,
                        identityStatement:
                            "  I train smoke-free.  "
                    )
            )

        let fallback =
            planner.makePlan(
                preferences:
                    preferences,
                profile:
                    NotificationScheduleProfile(
                        quitDate:
                            BuiltTestFixtures
                                .referenceDate,
                        identityStatement:
                            "   "
                    )
            )

        let personalizedBody =
            try #require(
                personalized.first
            )
            .body

        let fallbackBody =
            try #require(
                fallback.first
            )
            .body

        #expect(
            personalizedBody
            == "I train smoke-free."
        )

        #expect(
            fallbackBody
            == "Protect the body and life you are building today."
        )
    }

    @Test(
        "Only future milestone notifications are planned"
    )
    func futureMilestonesOnly() {
        let now =
            BuiltTestFixtures
                .referenceDate

        var preferences =
            NotificationPreferences
                .defaultValue

        preferences.masterEnabled = true
        preferences.morningEnabled =
            false
        preferences.eveningEnabled =
            false
        preferences.riskEnabled = false
        preferences.milestonesEnabled =
            true

        let quitDate =
            now.addingTimeInterval(
                -(100 * 86_400)
            )

        let plan = planner.makePlan(
            preferences: preferences,
            profile:
                NotificationScheduleProfile(
                    quitDate: quitDate,
                    identityStatement:
                        "Identity"
                ),
            now: now,
            calendar:
                gregorianUTC()
        )

        let identifiers =
            Set(
                plan.map(\.identifier)
            )

        #expect(
            identifiers
            == Set([
                NotificationSchedulePlanner
                    .milestoneIdentifier(
                        days: 180
                    ),
                NotificationSchedulePlanner
                    .milestoneIdentifier(
                        days: 365
                    )
            ])
        )
    }

    @Test(
        "Every managed notification identifier is unique"
    )
    func identifiersAreUnique() {
        let identifiers =
            NotificationSchedulePlanner
                .builtIdentifiers

        #expect(
            Set(identifiers).count
            == identifiers.count
        )
    }

    private func profile()
        -> NotificationScheduleProfile {
        NotificationScheduleProfile(
            quitDate:
                BuiltTestFixtures
                    .referenceDate,
            identityStatement:
                "I protect what I built."
        )
    }

    private func gregorianUTC()
        -> Calendar {
        var calendar =
            Calendar(
                identifier: .gregorian
            )

        calendar.timeZone =
            TimeZone(
                secondsFromGMT: 0
            )!

        return calendar
    }
}
