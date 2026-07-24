import Foundation
import UserNotifications

actor NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    private let morningIdentifier = "built.notification.morning"
    private let eveningIdentifier = "built.notification.evening"
    private let riskIdentifier = "built.notification.risk"

    private let milestoneDays = [2, 3, 7, 14, 30, 60, 90, 180, 365]

    func configureCategories() {
        let rescueAction = UNNotificationAction(
            identifier: BuiltSharedConstants.notificationOpenRescueActionIdentifier,
            title: "Open Rescue",
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: BuiltSharedConstants.notificationCategoryIdentifier,
            actions: [rescueAction],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([category])
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        } catch {
            return false
        }
    }

    func schedule(
        preferences: NotificationPreferences,
        profile: NotificationScheduleProfile
    ) async {
        await removeBuiltRequests()

        guard preferences.masterEnabled else {
            return
        }

        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional else {
            return
        }

        if preferences.morningEnabled {
            await addDailyNotification(
                identifier: morningIdentifier,
                hour: preferences.morningHour,
                minute: preferences.morningMinute,
                title: "THIS BODY DOES NOT SMOKE",
                body: morningBody(for: profile),
                routeURL: BuiltSharedConstants.todayURL
            )
        }

        if preferences.eveningEnabled {
            await addDailyNotification(
                identifier: eveningIdentifier,
                hour: preferences.eveningHour,
                minute: preferences.eveningMinute,
                title: "BUILT, NOT BURNED",
                body: "Another day protected. Open BUILT and look at what you are preserving.",
                routeURL: BuiltSharedConstants.todayURL
            )
        }

        if preferences.riskEnabled {
            await addDailyNotification(
                identifier: riskIdentifier,
                hour: preferences.riskHour,
                minute: preferences.riskMinute,
                title: "A CRAVING IS NOT A COMMAND",
                body: "Use the 60-second rescue before the urge gets to negotiate.",
                routeURL: BuiltSharedConstants.rescueURL
            )
        }

        if preferences.milestonesEnabled {
            await addMilestoneNotifications(profile: profile)
        }
    }

    func cancelAll() async {
        await removeBuiltRequests()
    }

    private func morningBody(
        for profile: NotificationScheduleProfile
    ) -> String {
        let statement = profile.identityStatement
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if statement.isEmpty {
            return "Protect the body and life you are building today."
        }

        return statement
    }

    private func addDailyNotification(
        identifier: String,
        hour: Int,
        minute: Int,
        title: String,
        body: String,
        routeURL: URL
    ) async {
        let content = makeContent(
            title: title,
            body: body,
            routeURL: routeURL
        )

        var components = DateComponents()
        components.hour = min(max(hour, 0), 23)
        components.minute = min(max(minute, 0), 59)

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    private func addMilestoneNotifications(
        profile: NotificationScheduleProfile
    ) async {
        let calendar = Calendar.current
        let now = Date.now

        for days in milestoneDays {
            guard let fireDate = calendar.date(
                byAdding: .day,
                value: days,
                to: profile.quitDate
            ), fireDate > now else {
                continue
            }

            let title = milestoneTitle(days: days)
            let body = milestoneBody(days: days)

            let content = makeContent(
                title: title,
                body: body,
                routeURL: BuiltSharedConstants.todayURL
            )

            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: fireDate
            )

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: milestoneIdentifier(days: days),
                content: content,
                trigger: trigger
            )

            try? await center.add(request)
        }
    }

    private func makeContent(
        title: String,
        body: String,
        routeURL: URL
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = BuiltSharedConstants.notificationCategoryIdentifier
        content.userInfo = [
            BuiltSharedConstants.notificationRouteUserInfoKey: routeURL.absoluteString
        ]
        return content
    }

    private func milestoneIdentifier(days: Int) -> String {
        "built.notification.milestone.\(days)"
    }

    private func milestoneTitle(days: Int) -> String {
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

    private func milestoneBody(days: Int) -> String {
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

    private func removeBuiltRequests() async {
        let identifiers = [
            morningIdentifier,
            eveningIdentifier,
            riskIdentifier
        ] + milestoneDays.map(milestoneIdentifier(days:))

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}
