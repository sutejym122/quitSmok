import Foundation
import UserNotifications
import OSLog

actor NotificationManager {
    static let shared =
        NotificationManager()

    private let center =
        UNUserNotificationCenter
            .current()

    private let planner =
        NotificationSchedulePlanner()

    func configureCategories() {
        let rescueAction =
            UNNotificationAction(
                identifier:
                    BuiltSharedConstants
                        .notificationOpenRescueActionIdentifier,
                title: "Open Rescue",
                options: [.foreground]
            )

        let category =
            UNNotificationCategory(
                identifier:
                    BuiltSharedConstants
                        .notificationCategoryIdentifier,
                actions: [
                    rescueAction
                ],
                intentIdentifiers: [],
                options: []
            )

        center.setNotificationCategories([
            category
        ])
    }

    func authorizationStatus()
        async -> UNAuthorizationStatus {
        let settings =
            await center
                .notificationSettings()

        return settings
            .authorizationStatus
    }

    func requestAuthorization()
        async -> Bool {
        do {
            return try await center
                .requestAuthorization(
                    options: [
                        .alert,
                        .sound,
                        .badge
                    ]
                )
        } catch {
            BuiltLog.notifications.error(
                "Notification authorization request failed: \(error.localizedDescription, privacy: .private)"
            )

            return false
        }
    }

    func schedule(
        preferences:
            NotificationPreferences,
        profile:
            NotificationScheduleProfile
    ) async {
        removeBuiltRequests()

        guard preferences.masterEnabled
        else {
            BuiltLog.notifications.info(
                "BUILT reminders are paused."
            )
            return
        }

        let status =
            await authorizationStatus()

        guard
            status == .authorized
            || status == .provisional
            || status == .ephemeral
        else {
            BuiltLog.notifications.info(
                "Notification scheduling skipped because authorization is unavailable."
            )
            return
        }

        let plan = planner.makePlan(
            preferences: preferences,
            profile: profile
        )

        for item in plan {
            let request =
                makeRequest(from: item)

            do {
                try await center.add(
                    request
                )
            } catch {
                BuiltLog.notifications.error(
                    "Failed to schedule \(item.identifier, privacy: .public): \(error.localizedDescription, privacy: .private)"
                )
            }
        }

        BuiltLog.notifications.info(
            "Scheduled \(plan.count, privacy: .public) BUILT notification requests."
        )
    }

    func cancelAll() async {
        removeBuiltRequests()

        BuiltLog.notifications.info(
            "Cancelled BUILT notification requests."
        )
    }

    private func makeRequest(
        from item:
            NotificationPlanItem
    ) -> UNNotificationRequest {
        let content =
            UNMutableNotificationContent()

        content.title = item.title
        content.body = item.body
        content.sound = .default
        content.categoryIdentifier =
            BuiltSharedConstants
                .notificationCategoryIdentifier

        content.userInfo = [
            BuiltSharedConstants
                .notificationRouteUserInfoKey:
                    item
                        .routeURL
                        .absoluteString
        ]

        let trigger:
            UNNotificationTrigger

        switch item.trigger {
        case .daily(
            let hour,
            let minute
        ):
            var components =
                DateComponents()

            components.hour = hour
            components.minute = minute

            trigger =
                UNCalendarNotificationTrigger(
                    dateMatching:
                        components,
                    repeats: true
                )

        case .date(let components):
            trigger =
                UNCalendarNotificationTrigger(
                    dateMatching:
                        components,
                    repeats: false
                )
        }

        return UNNotificationRequest(
            identifier:
                item.identifier,
            content: content,
            trigger: trigger
        )
    }

    private func removeBuiltRequests() {
        let identifiers =
            NotificationSchedulePlanner
                .builtIdentifiers

        center
            .removePendingNotificationRequests(
                withIdentifiers:
                    identifiers
            )

        center
            .removeDeliveredNotifications(
                withIdentifiers:
                    identifiers
            )
    }
}
