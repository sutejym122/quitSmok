import Foundation
import XCTest

@testable import BUILT

final class BuiltPlanEngineTests: XCTestCase {
    private let fixedDate = Date(
        timeIntervalSince1970: 1_800_000_000
    )

    func testPlanAlwaysContainsSevenOrderedMissions() {
        let plan = BuiltPlanEngine.makePlan(
            preferences: .defaults,
            generatedAt: fixedDate
        )

        XCTAssertEqual(plan.durationDays, 7)
        XCTAssertEqual(
            plan.missions.map(\.dayNumber),
            Array(1...7)
        )
        XCTAssertEqual(
            Set(plan.missions.map(\.id)).count,
            7
        )
    }

    func testPlanGenerationIsDeterministic() {
        let first = BuiltPlanEngine.makePlan(
            preferences: .defaults,
            generatedAt: fixedDate
        )

        let second = BuiltPlanEngine.makePlan(
            preferences: .defaults,
            generatedAt: fixedDate
        )

        XCTAssertEqual(first, second)
    }

    func testDayOneUsesPrimaryCravingTrigger() {
        var preferences = OnboardingPreferences.defaults
        preferences.cravingTriggers = [
            .afterFood,
            .stress
        ]

        let plan = BuiltPlanEngine.makePlan(
            preferences: preferences,
            generatedAt: fixedDate
        )

        let mission = plan.missions[0]

        XCTAssertEqual(
            mission.focus,
            .awareness
        )
        XCTAssertTrue(
            mission.detail.localizedCaseInsensitiveContains(
                "after food"
            )
        )
        XCTAssertEqual(
            mission.symbolName,
            CravingTrigger.afterFood.symbolName
        )
    }

    func testDayTwoUsesPrimaryRescueAction() {
        var preferences = OnboardingPreferences.defaults
        preferences.rescueActions = [
            .walk,
            .drinkWater
        ]

        let plan = BuiltPlanEngine.makePlan(
            preferences: preferences,
            generatedAt: fixedDate
        )

        let mission = plan.missions[1]

        XCTAssertEqual(
            mission.focus,
            .replacement
        )
        XCTAssertTrue(
            mission.title.localizedCaseInsensitiveContains(
                "walk"
            )
        )
        XCTAssertEqual(
            mission.symbolName,
            RescueAction.walk.symbolName
        )
    }

    func testDayThreeReflectsFitnessIdentity() {
        var preferences = OnboardingPreferences.defaults
        preferences.fitnessIdentity = .seriousTraining

        let plan = BuiltPlanEngine.makePlan(
            preferences: preferences,
            generatedAt: fixedDate
        )

        let mission = plan.missions[2]

        XCTAssertEqual(
            mission.focus,
            .identity
        )
        XCTAssertTrue(
            mission.reason.contains(
                "performance"
            )
        )
        XCTAssertEqual(
            mission.symbolName,
            FitnessIdentity.seriousTraining.symbolName
        )
    }

    func testDayFourUsesPrimaryQuitReason() {
        var preferences = OnboardingPreferences.defaults
        preferences.quitReasons = [
            .saveMoney,
            .takeControl
        ]

        let plan = BuiltPlanEngine.makePlan(
            preferences: preferences,
            generatedAt: fixedDate
        )

        let mission = plan.missions[3]

        XCTAssertEqual(
            mission.focus,
            .motivation
        )
        XCTAssertTrue(
            mission.detail.localizedCaseInsensitiveContains(
                "money"
            )
        )
        XCTAssertEqual(
            mission.symbolName,
            QuitReason.saveMoney.symbolName
        )
    }

    func testEmptySelectionsStillProduceCompletePlan() {
        var preferences = OnboardingPreferences.defaults
        preferences.quitReasons = []
        preferences.cravingTriggers = []
        preferences.rescueActions = []

        let plan = BuiltPlanEngine.makePlan(
            preferences: preferences,
            generatedAt: fixedDate
        )

        XCTAssertEqual(
            plan.missions.count,
            7
        )

        for mission in plan.missions {
            XCTAssertFalse(
                mission.title.isEmpty
            )
            XCTAssertFalse(
                mission.detail.isEmpty
            )
            XCTAssertFalse(
                mission.action.isEmpty
            )
            XCTAssertFalse(
                mission.reason.isEmpty
            )
            XCTAssertFalse(
                mission.symbolName.isEmpty
            )
        }
    }

    func testPlanRoundTripsThroughJSON() throws {
        let plan = BuiltPlanEngine.makePlan(
            preferences: .defaults,
            generatedAt: fixedDate
        )

        let encoded = try JSONEncoder().encode(
            plan
        )

        let decoded = try JSONDecoder().decode(
            BuiltPlan.self,
            from: encoded
        )

        XCTAssertEqual(
            decoded,
            plan
        )
    }
}
