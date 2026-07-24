import Foundation

struct NotificationPreferences: Codable, Equatable, Sendable {
    var masterEnabled: Bool

    var morningEnabled: Bool
    var morningHour: Int
    var morningMinute: Int

    var eveningEnabled: Bool
    var eveningHour: Int
    var eveningMinute: Int

    var riskEnabled: Bool
    var riskHour: Int
    var riskMinute: Int

    var milestonesEnabled: Bool

    static let defaultValue = NotificationPreferences(
        masterEnabled: false,
        morningEnabled: true,
        morningHour: 8,
        morningMinute: 0,
        eveningEnabled: true,
        eveningHour: 20,
        eveningMinute: 30,
        riskEnabled: false,
        riskHour: 18,
        riskMinute: 0,
        milestonesEnabled: true
    )
}

struct NotificationScheduleProfile: Sendable {
    let quitDate: Date
    let identityStatement: String
}

enum NotificationPreferencesStore {
    private static let storageKey = "built.notification.preferences.v1"

    static func load() -> NotificationPreferences {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let preferences = try? JSONDecoder().decode(
                NotificationPreferences.self,
                from: data
            )
        else {
            return .defaultValue
        }

        return preferences
    }

    static func save(_ preferences: NotificationPreferences) {
        guard let data = try? JSONEncoder().encode(preferences) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }

    static func reset() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
