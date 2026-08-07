import Foundation
import XCTest

@testable import BUILT

final class BuiltPlanProgressTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    private let fixedDate =
        Date(
            timeIntervalSince1970:
                1_800_000_000
        )

    override func setUpWithError() throws {
        suiteName =
            "BuiltPlanProgressTests.\(UUID().uuidString)"

        defaults =
            UserDefaults(
                suiteName: suiteName
            )

        defaults.removePersistentDomain(
            forName: suiteName
        )
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(
            forName: suiteName
        )

        defaults = nil
        suiteName = nil
    }

    private func makeProgress()
        -> BuiltPlanProgress {
        BuiltPlanProgress(
            plan:
                BuiltPlanEngine.makePlan(
                    preferences: .defaults,
                    generatedAt: fixedDate
                )
        )
    }

    func testDayOneIsFree() {
        let progress = makeProgress()

        XCTAssertTrue(
            progress.canAccess(
                dayNumber: 1,
                hasPro: false
            )
        )
    }

    func testFreeUserCannotAccessDayTwo() {
        var progress = makeProgress()

        progress.complete(
            dayNumber: 1,
            at: fixedDate
        )

        XCTAssertFalse(
            progress.canAccess(
                dayNumber: 2,
                hasPro: false
            )
        )
    }

    func testProStillCompletesPlanSequentially() {
        var progress = makeProgress()

        XCTAssertFalse(
            progress.canAccess(
                dayNumber: 2,
                hasPro: true
            )
        )

        progress.complete(
            dayNumber: 1,
            at: fixedDate
        )

        XCTAssertTrue(
            progress.canAccess(
                dayNumber: 2,
                hasPro: true
            )
        )
    }

    func testCompletionAdvancesNextMission() {
        var progress = makeProgress()

        XCTAssertEqual(
            progress.nextDayNumber,
            1
        )

        progress.complete(
            dayNumber: 1,
            at: fixedDate
        )

        XCTAssertEqual(
            progress.nextDayNumber,
            2
        )
        XCTAssertEqual(
            progress.completedCount,
            1
        )
    }

    func testDuplicateCompletionIsIgnored() {
        var progress = makeProgress()

        progress.complete(
            dayNumber: 1,
            at: fixedDate
        )
        progress.complete(
            dayNumber: 1,
            at:
                fixedDate
                    .addingTimeInterval(60)
        )

        XCTAssertEqual(
            progress.completions.count,
            1
        )
    }

    func testInvalidDayIsIgnored() {
        var progress = makeProgress()

        progress.complete(
            dayNumber: 99,
            at: fixedDate
        )

        XCTAssertEqual(
            progress.completedCount,
            0
        )
    }

    func testStoreRoundTripsProgress() {
        var progress = makeProgress()

        progress.complete(
            dayNumber: 1,
            at: fixedDate
        )

        BuiltPlanProgressStore.save(
            progress,
            defaults: defaults
        )

        XCTAssertEqual(
            BuiltPlanProgressStore.load(
                defaults: defaults
            ),
            progress
        )
    }

    func testLoadOrCreateKeepsOriginalPlan() {
        var firstPreferences =
            OnboardingPreferences.defaults

        firstPreferences.cravingTriggers = [
            .afterFood
        ]

        let first =
            BuiltPlanProgressStore
                .loadOrCreate(
                    preferences:
                        firstPreferences,
                    generatedAt:
                        fixedDate,
                    defaults:
                        defaults
                )

        var changedPreferences =
            OnboardingPreferences.defaults

        changedPreferences.cravingTriggers = [
            .coffee
        ]

        let second =
            BuiltPlanProgressStore
                .loadOrCreate(
                    preferences:
                        changedPreferences,
                    generatedAt:
                        fixedDate
                            .addingTimeInterval(
                                500
                            ),
                    defaults:
                        defaults
                )

        XCTAssertEqual(first, second)
    }

    func testResetRemovesProgress() {
        let progress = makeProgress()

        BuiltPlanProgressStore.save(
            progress,
            defaults: defaults
        )

        BuiltPlanProgressStore.reset(
            defaults: defaults
        )

        XCTAssertNil(
            BuiltPlanProgressStore.load(
                defaults: defaults
            )
        )
    }
}
