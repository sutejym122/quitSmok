import Foundation

enum NotificationPlanTrigger:
    Equatable,
    Sendable {
    case daily(
        hour: Int,
        minute: Int
    )

    case date(DateComponents)
}

struct NotificationPlanItem:
    Equatable,
    Sendable {
    let identifier: String
    let title: String
    let body: String
    let routeURL: URL
    let trigger:
        NotificationPlanTrigger
}

struct NotificationSchedulePlanner:
    Sendable {
    static let morningIdentifier =
        "built.notification.morning"

    static let eveningIdentifier =
        "built.notification.evening"

    static let riskIdentifier =
        "built.notification.risk"

    static let milestoneDays = [
        2,
        3,
        7,
        14,
        30,
        60,
        90,
        180,
        365
    ]

    static var builtIdentifiers:
        [String] {
        [
            morningIdentifier,
            eveningIdentifier,
            riskIdentifier
        ]
        + milestoneDays.map(
            milestoneIdentifier(days:)
        )
    }

    func makePlan(
        preferences:
            NotificationPreferences,
        profile:
            NotificationScheduleProfile,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [NotificationPlanItem] {
        guard preferences.masterEnabled
        else {
            return []
        }

        var plan:
            [NotificationPlanItem] = []

        if preferences.morningEnabled {
            plan.append(
                NotificationPlanItem(
                    identifier:
                        Self.morningIdentifier,
                    title:
                        "THIS BODY DOES NOT SMOKE",
                    body:
                        morningBody(
                            for: profile
                        ),
                    routeURL:
                        BuiltSharedConstants
                            .todayURL,
                    trigger:
                        .daily(
                            hour:
                                clampedHour(
                                    preferences
                                        .morningHour
                                ),
                            minute:
                                clampedMinute(
                                    preferences
                                        .morningMinute
                                )
                        )
                )
            )
        }

        if preferences.eveningEnabled {
            plan.append(
                NotificationPlanItem(
                    identifier:
                        Self.eveningIdentifier,
                    title:
                        "BUILT, NOT BURNED",
                    body:
                        "Another day protected. Open BUILT and look at what you are preserving.",
                    routeURL:
                        BuiltSharedConstants
                            .todayURL,
                    trigger:
                        .daily(
                            hour:
                                clampedHour(
                                    preferences
                                        .eveningHour
                                ),
                            minute:
                                clampedMinute(
                                    preferences
                                        .eveningMinute
                                )
                        )
                )
            )
        }

        if preferences.riskEnabled {
            plan.append(
                NotificationPlanItem(
                    identifier:
                        Self.riskIdentifier,
                    title:
                        "A CRAVING IS NOT A COMMAND",
                    body:
                        "Use the 60-second rescue before the urge gets to negotiate.",
                    routeURL:
                        BuiltSharedConstants
                            .rescueURL,
                    trigger:
                        .daily(
                            hour:
                                clampedHour(
                                    preferences
                                        .riskHour
                                ),
                            minute:
                                clampedMinute(
                                    preferences
                                        .riskMinute
                                )
                        )
                )
            )
        }

        if preferences.milestonesEnabled {
            plan.append(
                contentsOf:
                    milestoneItems(
                        profile: profile,
                        now: now,
                        calendar: calendar
                    )
            )
        }

        return plan
    }

    static func milestoneIdentifier(
        days: Int
    ) -> String {
        "built.notification.milestone.\(days)"
    }

    private func morningBody(
        for profile:
            NotificationScheduleProfile
    ) -> String {
        let statement =
            profile
                .identityStatement
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        if statement.isEmpty {
            return
                "Protect the body and life you are building today."
        }

        return statement
    }

    private func milestoneItems(
        profile:
            NotificationScheduleProfile,
        now: Date,
        calendar: Calendar
    ) -> [NotificationPlanItem] {
        Self.milestoneDays.compactMap {
            days in

            guard
                let fireDate =
                    calendar.date(
                        byAdding: .day,
                        value: days,
                        to:
                            profile.quitDate
                    ),
                fireDate > now
            else {
                return nil
            }

            let components =
                calendar.dateComponents(
                    [
                        .year,
                        .month,
                        .day,
                        .hour,
                        .minute,
                        .second
                    ],
                    from: fireDate
                )

            return NotificationPlanItem(
                identifier:
                    Self
                        .milestoneIdentifier(
                            days: days
                        ),
                title:
                    milestoneTitle(
                        days: days
                    ),
                body:
                    milestoneBody(
                        days: days
                    ),
                routeURL:
                    BuiltSharedConstants
                        .todayURL,
                trigger:
                    .date(components)
            )
        }
    }

    private func clampedHour(
        _ hour: Int
    ) -> Int {
        min(max(hour, 0), 23)
    }

    private func clampedMinute(
        _ minute: Int
    ) -> Int {
        min(max(minute, 0), 59)
    }

    private func milestoneTitle(
        days: Int
    ) -> String {
        switch days {
        case 2:
            return "48 HOURS BUILT"
        case 3:
            return "THREE DAYS SMOKE-FREE"
        case 7:
            return "ONE FULL WEEK"
        case 14:
            return "TWO WEEKS BUILT"
        case 30:
            return "30 DAYS. NEW STANDARD."
        case 60:
            return "60 DAYS SMOKE-FREE"
        case 90:
            return "90 DAYS OF PROOF"
        case 180:
            return "SIX MONTHS BUILT"
        case 365:
            return "ONE YEAR, NOT BURNED"
        default:
            return "BUILT, NOT BURNED"
        }
    }

    private func milestoneBody(
        days: Int
    ) -> String {
        switch days {
        case 2:
            return "You have protected your body for two full days. Keep the identity, not the old ritual."
        case 3:
            return "Three days of choosing the person you are becoming."
        case 7:
            return "Seven days. Your actions are beginning to look like an identity."
        case 14:
            return "Two weeks of evidence that a craving does not control you."
        case 30:
            return "A full month protected. Look at the body and life you refused to trade away."
        case 60:
            return "Sixty days of keeping the promise."
        case 90:
            return "Ninety days. This is no longer an attempt. This is your standard."
        case 180:
            return "Six months of decisions made by the smoke-free version of you."
        case 365:
            return "One complete year. Built, not burned."
        default:
            return "Open BUILT and see what you have protected."
        }
    }
}
