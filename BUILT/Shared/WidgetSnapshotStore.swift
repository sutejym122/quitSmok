import Foundation

public enum WidgetSnapshotStore {
    @discardableResult
    public static func save(
        _ snapshot: WidgetSnapshot
    ) -> Bool {
        guard
            let defaults =
                sharedDefaults()
        else {
            return false
        }

        return save(
            snapshot,
            to: defaults
        )
    }

    @discardableResult
    public static func save(
        _ snapshot: WidgetSnapshot,
        to defaults: UserDefaults
    ) -> Bool {
        do {
            let data =
                try JSONEncoder()
                    .encode(snapshot)

            defaults.set(
                data,
                forKey:
                    BuiltSharedConstants
                        .widgetSnapshotKey
            )

            return true
        } catch {
            return false
        }
    }

    public static func load()
        -> WidgetSnapshot {
        guard
            let defaults =
                sharedDefaults()
        else {
            return .placeholder
        }

        return load(from: defaults)
    }

    public static func load(
        from defaults: UserDefaults
    ) -> WidgetSnapshot {
        guard
            let data =
                defaults.data(
                    forKey:
                        BuiltSharedConstants
                            .widgetSnapshotKey
                ),
            let snapshot =
                try? JSONDecoder()
                    .decode(
                        WidgetSnapshot.self,
                        from: data
                    )
        else {
            return .placeholder
        }

        return snapshot
    }

    public static func clear() {
        guard
            let defaults =
                sharedDefaults()
        else {
            return
        }

        clear(from: defaults)
    }

    public static func clear(
        from defaults: UserDefaults
    ) {
        defaults.removeObject(
            forKey:
                BuiltSharedConstants
                    .widgetSnapshotKey
        )
    }

    private static func sharedDefaults()
        -> UserDefaults? {
        UserDefaults(
            suiteName:
                BuiltSharedConstants
                    .appGroupIdentifier
        )
    }
}
