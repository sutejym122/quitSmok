import Foundation

enum BuiltPlanProgressStore {
    private static let storageKey =
        "built.plan.progress.v1"

    static func load(
        defaults: UserDefaults = .standard
    ) -> BuiltPlanProgress? {
        guard
            let data = defaults.data(
                forKey: storageKey
            )
        else {
            return nil
        }

        return try? JSONDecoder().decode(
            BuiltPlanProgress.self,
            from: data
        )
    }

    @discardableResult
    static func loadOrCreate(
        preferences: OnboardingPreferences,
        generatedAt: Date = .now,
        defaults: UserDefaults = .standard
    ) -> BuiltPlanProgress {
        if let existing = load(defaults: defaults) {
            return existing
        }

        let progress =
            BuiltPlanProgress(
                plan:
                    BuiltPlanEngine.makePlan(
                        preferences: preferences,
                        generatedAt: generatedAt
                    )
            )

        save(
            progress,
            defaults: defaults
        )

        return progress
    }

    static func save(
        _ progress: BuiltPlanProgress,
        defaults: UserDefaults = .standard
    ) {
        guard
            let data = try? JSONEncoder().encode(
                progress
            )
        else {
            return
        }

        defaults.set(
            data,
            forKey: storageKey
        )
    }

    static func reset(
        defaults: UserDefaults = .standard
    ) {
        defaults.removeObject(
            forKey: storageKey
        )
    }
}
