import Foundation
import SwiftData
import Testing

@testable import BUILT

@Suite(
    "SwiftData Persistence",
    .serialized
)
@MainActor
struct SwiftDataPersistenceTests {
    @Test(
        "The release schema creates an in-memory container"
    )
    func createsInMemoryContainer()
        throws {
        let container =
            try AppModelContainerFactory
                .make(
                    inMemory: true
                )

        let profiles =
            try container
                .mainContext
                .fetch(
                    FetchDescriptor<
                        QuitProfile
                    >()
                )

        #expect(profiles.isEmpty)
    }

    @Test(
        "All production models save and fetch"
    )
    func savesAndFetchesAllModels()
        throws {
        let container =
            try AppModelContainerFactory
                .make(
                    inMemory: true
                )

        let context =
            container.mainContext

        let profile =
            BuiltTestFixtures
                .makeProfile(
                    identityStatement:
                        "Persistence works."
                )

        let craving =
            CravingEntry(
                createdAt:
                    BuiltTestFixtures
                        .referenceDate,
                intensity: 7,
                trigger: "Stress",
                replacementAction:
                    "Walk",
                outcome: .defeated
            )

        let photo =
            MotivationPhoto(
                imageData:
                    Data([
                        0x01,
                        0x02,
                        0x03
                    ]),
                caption: "Proof",
                isHero: true,
                createdAt:
                    BuiltTestFixtures
                        .referenceDate
            )

        let reward =
            RewardGoal(
                title:
                    "Running shoes",
                targetAmount: 150,
                iconName:
                    "figure.run",
                bankedAmount: 25,
                usesAutomaticSavings:
                    false,
                isActive: true,
                createdAt:
                    BuiltTestFixtures
                        .referenceDate
            )

        context.insert(profile)
        context.insert(craving)
        context.insert(photo)
        context.insert(reward)
        try context.save()

        let profiles =
            try context.fetch(
                FetchDescriptor<
                    QuitProfile
                >()
            )

        let cravings =
            try context.fetch(
                FetchDescriptor<
                    CravingEntry
                >()
            )

        let photos =
            try context.fetch(
                FetchDescriptor<
                    MotivationPhoto
                >()
            )

        let rewards =
            try context.fetch(
                FetchDescriptor<
                    RewardGoal
                >()
            )

        #expect(profiles.count == 1)
        #expect(cravings.count == 1)
        #expect(photos.count == 1)
        #expect(rewards.count == 1)

        #expect(
            profiles.first?
                .identityStatement
            == "Persistence works."
        )

        #expect(
            cravings.first?.outcome
            == .defeated
        )

        #expect(
            photos.first?.isHero
            == true
        )

        #expect(
            rewards.first?.title
            == "Running shoes"
        )
    }

    @Test(
        "Saved models update and delete"
    )
    func updatesAndDeletesModels()
        throws {
        let container =
            try AppModelContainerFactory
                .make(
                    inMemory: true
                )

        let context =
            container.mainContext

        let profile =
            BuiltTestFixtures
                .makeProfile()

        let craving =
            CravingEntry(
                intensity: 5,
                trigger: "Coffee",
                replacementAction:
                    "Drink water",
                outcome: .defeated
            )

        context.insert(profile)
        context.insert(craving)
        try context.save()

        profile.identityStatement =
            "Updated identity."

        craving.outcome = .smoked
        try context.save()

        let fetchedProfiles =
            try context.fetch(
                FetchDescriptor<
                    QuitProfile
                >()
            )

        let fetchedCravings =
            try context.fetch(
                FetchDescriptor<
                    CravingEntry
                >()
            )

        let savedProfile =
            try #require(
                fetchedProfiles.first
            )

        let savedCraving =
            try #require(
                fetchedCravings.first
            )

        #expect(
            savedProfile
                .identityStatement
            == "Updated identity."
        )

        #expect(
            savedCraving.outcome
            == .smoked
        )

        context.delete(savedCraving)
        context.delete(savedProfile)
        try context.save()

        let profileCount =
            try context.fetchCount(
                FetchDescriptor<
                    QuitProfile
                >()
            )

        let cravingCount =
            try context.fetchCount(
                FetchDescriptor<
                    CravingEntry
                >()
            )

        #expect(profileCount == 0)
        #expect(cravingCount == 0)
    }
}
