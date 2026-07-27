import Foundation

enum OnboardingPreferencesStore {
    private static let storageKey =
        "built.onboarding.preferences.v1"

    static func load() -> OnboardingPreferences {
        guard
            let data = UserDefaults.standard.data(
                forKey: storageKey
            ),
            let preferences = try? JSONDecoder().decode(
                OnboardingPreferences.self,
                from: data
            )
        else {
            return .defaults
        }

        return preferences
    }

    static func save(
        _ preferences: OnboardingPreferences
    ) throws {
        let data = try JSONEncoder().encode(
            preferences
        )

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }

    static func reset() {
        UserDefaults.standard.removeObject(
            forKey: storageKey
        )
    }

    static var preferredTriggerTitle: String {
        load().cravingTriggers.first?.title
            ?? CravingTrigger.stress.title
    }

    static var preferredActionTitle: String {
        load().rescueActions.first?.title
            ?? RescueAction.drinkWater.title
    }

    static var orderedTriggerTitles: [String] {
        let preferences = load()
        let preferred = preferences.cravingTriggers
        let remaining = CravingTrigger.allCases.filter {
            !preferred.contains($0)
        }

        return (preferred + remaining).map(\.title)
    }

    static var orderedActions: [(String, String)] {
        let preferences = load()
        let preferred = preferences.rescueActions
        let remaining = RescueAction.allCases.filter {
            !preferred.contains($0)
        }

        return (preferred + remaining).map {
            ($0.title, $0.symbolName)
        }
    }
}
