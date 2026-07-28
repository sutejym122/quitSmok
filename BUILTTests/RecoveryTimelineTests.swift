import Foundation
import Testing

@testable import BUILT

@Suite("Recovery Timeline")
@MainActor
struct RecoveryTimelineTests {
    @Test(
        "Milestones are ordered unique and have valid sources"
    )
    func milestoneCatalogIntegrity() {
        let milestones =
            RecoveryTimelineService
                .milestones

        #expect(!milestones.isEmpty)

        let identifiers =
            milestones.map(\.id)

        #expect(
            Set(identifiers).count
            == identifiers.count
        )

        #expect(
            milestones.allSatisfy {
                $0.threshold > 0
            }
        )

        #expect(
            milestones.allSatisfy {
                $0.sourceURL != nil
            }
        )

        let ordered =
            zip(
                milestones,
                milestones.dropFirst()
            )
            .allSatisfy {
                $0.threshold
                < $1.threshold
            }

        #expect(ordered)
    }

    @Test(
        "A future quit date starts at the first milestone"
    )
    func futureQuitDateStartsAtZero() {
        let now =
            BuiltTestFixtures
                .referenceDate

        let snapshot =
            RecoveryTimelineService
                .snapshot(
                    quitDate:
                        now.addingTimeInterval(
                            3_600
                        ),
                    now: now
                )

        #expect(snapshot.elapsed == 0)
        #expect(
            snapshot.completedCount
            == 0
        )
        #expect(
            snapshot.nextMilestone?.id
            == RecoveryTimelineService
                .milestones
                .first?
                .id
        )
        #expect(
            snapshot.progressToNext
            == 0
        )
    }

    @Test(
        "Crossing the first threshold completes exactly one milestone"
    )
    func firstMilestoneBoundary() throws {
        let first = try #require(
            RecoveryTimelineService
                .milestones
                .first
        )

        let now =
            BuiltTestFixtures
                .referenceDate

        let snapshot =
            RecoveryTimelineService
                .snapshot(
                    quitDate:
                        now.addingTimeInterval(
                            -first.threshold
                        ),
                    now: now
                )

        #expect(
            snapshot.completedCount
            == 1
        )
        #expect(
            snapshot.latestCompleted?.id
            == first.id
        )
        #expect(
            snapshot.nextMilestone?.id
            == RecoveryTimelineService
                .milestones[1]
                .id
        )
        #expect(
            snapshot.progressToNext
            == 0
        )
    }

    @Test(
        "Progress is measured between the previous and next threshold"
    )
    func interMilestoneProgress() {
        let previous =
            RecoveryTimelineService
                .milestones[0]

        let next =
            RecoveryTimelineService
                .milestones[1]

        let elapsed =
            previous.threshold
            + (
                next.threshold
                - previous.threshold
            ) / 2

        let now =
            BuiltTestFixtures
                .referenceDate

        let snapshot =
            RecoveryTimelineService
                .snapshot(
                    quitDate:
                        now.addingTimeInterval(
                            -elapsed
                        ),
                    now: now
                )

        #expect(
            snapshot.completedCount
            == 1
        )
        #expect(
            snapshot.nextMilestone?.id
            == next.id
        )
        #expect(
            BuiltTestFixtures
                .approximatelyEqual(
                    snapshot
                        .progressToNext,
                    0.5
                )
        )
    }

    @Test(
        "Completing the final milestone reports a finished timeline"
    )
    func finalMilestoneCompletion() throws {
        let final = try #require(
            RecoveryTimelineService
                .milestones
                .last
        )

        let now =
            BuiltTestFixtures
                .referenceDate

        let snapshot =
            RecoveryTimelineService
                .snapshot(
                    quitDate:
                        now.addingTimeInterval(
                            -(
                                final.threshold
                                + 1
                            )
                        ),
                    now: now
                )

        #expect(
            snapshot.completedCount
            == RecoveryTimelineService
                .milestones
                .count
        )
        #expect(
            snapshot.nextMilestone
            == nil
        )
        #expect(
            snapshot.progressToNext
            == 1
        )
        #expect(
            snapshot.remainingText
            == "All listed milestones reached"
        )
    }

    @Test(
        "Remaining duration formatting covers minute hour day month and year ranges"
    )
    func durationFormatting() {
        #expect(
            RecoveryTimelineService
                .formattedDuration(0)
            == "1m remaining"
        )

        #expect(
            RecoveryTimelineService
                .formattedDuration(61)
            == "2m remaining"
        )

        #expect(
            RecoveryTimelineService
                .formattedDuration(3_600)
            == "1h remaining"
        )

        #expect(
            RecoveryTimelineService
                .formattedDuration(3_660)
            == "1h 1m remaining"
        )

        #expect(
            RecoveryTimelineService
                .formattedDuration(90_000)
            == "1d 1h remaining"
        )

        #expect(
            RecoveryTimelineService
                .formattedDuration(
                    30 * 86_400
                )
            == "1mo remaining"
        )

        #expect(
            RecoveryTimelineService
                .formattedDuration(
                    365 * 86_400
                )
            == "1y remaining"
        )
    }
}
