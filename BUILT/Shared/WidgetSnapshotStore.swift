import Foundation

public enum WidgetSnapshotStore {
    @discardableResult
    public static func save(_ snapshot: WidgetSnapshot) -> Bool {
        guard let defaults = UserDefaults(
            suiteName: BuiltSharedConstants.appGroupIdentifier
        ) else {
            return false
        }

        do {
            let data = try JSONEncoder().encode(snapshot)
            defaults.set(data, forKey: BuiltSharedConstants.widgetSnapshotKey)
            return true
        } catch {
            return false
        }
    }

    public static func load() -> WidgetSnapshot {
        guard
            let defaults = UserDefaults(
                suiteName: BuiltSharedConstants.appGroupIdentifier
            ),
            let data = defaults.data(
                forKey: BuiltSharedConstants.widgetSnapshotKey
            ),
            let snapshot = try? JSONDecoder().decode(
                WidgetSnapshot.self,
                from: data
            )
        else {
            return .placeholder
        }

        return snapshot
    }

    public static func clear() {
        UserDefaults(
            suiteName: BuiltSharedConstants.appGroupIdentifier
        )?.removeObject(
            forKey: BuiltSharedConstants.widgetSnapshotKey
        )
    }
}
