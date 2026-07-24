import Foundation

private enum NotificationRouteStorage {
    static let pendingURLKey = "built.pending.notification.route"
}

enum NotificationRouteStore {
    static func save(urlString: String) {
        UserDefaults.standard.set(
            urlString,
            forKey: NotificationRouteStorage.pendingURLKey
        )
    }

    static func consume() -> URL? {
        guard let value = UserDefaults.standard.string(
            forKey: NotificationRouteStorage.pendingURLKey
        ) else {
            return nil
        }

        UserDefaults.standard.removeObject(
            forKey: NotificationRouteStorage.pendingURLKey
        )

        return URL(string: value)
    }
}
