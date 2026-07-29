import SwiftData

enum AppModelContainerFactory {
    static func make(
        inMemory: Bool = false
    ) throws -> ModelContainer {
        let schema = Schema([
            QuitProfile.self,
            CravingEntry.self,
            MotivationPhoto.self,
            RewardGoal.self
        ])

        let configuration =
            ModelConfiguration(
                isStoredInMemoryOnly:
                    inMemory
            )

        return try ModelContainer(
            for: schema,
            configurations: [
                configuration
            ]
        )
    }
}
