import XCTest

final class BUILTUISmokeTests:
    BUILTUITestCase {
    @MainActor
    func testFreshInstallCompletesOnboarding()
        throws {
        let app =
            launchBUILT(
                scenario: .fresh
            )

        assertExists(
            app.staticTexts[
                "THIS BODY DOES NOT SMOKE"
            ],
            "Fresh launch did not show onboarding."
        )

        tap(
            app.buttons[
                "Build my quit plan"
            ]
        )

        assertExists(
            app.staticTexts[
                "Make the numbers yours."
            ],
            "Smoking-pattern onboarding did not open."
        )

        tap(
            app.buttons["Continue"]
        )

        assertExists(
            app.staticTexts[
                "What are you protecting?"
            ],
            "Fitness-identity onboarding did not open."
        )

        tap(
            app.buttons["Continue"]
        )

        assertExists(
            app.staticTexts[
                "Make the reason personal."
            ],
            "Quit-reason onboarding did not open."
        )

        tap(
            app.buttons["Continue"]
        )

        assertExists(
            app.staticTexts[
                "Know what usually pulls you back."
            ],
            "Trigger onboarding did not open."
        )

        tap(
            app.buttons["Continue"]
        )

        assertExists(
            app.staticTexts[
                "What can you do instead?"
            ],
            "Rescue-plan onboarding did not open."
        )

        tap(
            app.buttons["Continue"]
        )

        assertExists(
            app.staticTexts[
                "Add the photo that reminds you who you are."
            ],
            "Motivation-photo onboarding did not open."
        )

        tap(
            app.buttons["Not now"]
        )

        assertExists(
            app.staticTexts[
                "Let training become proof."
            ],
            "Apple Health onboarding did not open."
        )

        tap(
            app.buttons["Not now"]
        )

        assertExists(
            app.staticTexts[
                "This is bigger than a counter."
            ],
            "Personalized-plan onboarding did not open."
        )

        tap(
            app.buttons["Enter BUILT"]
        )

        assertExists(
            element(
                "built.screen.today",
                in: app
            ),
            timeout: 12,
            "Completing onboarding did not open Today."
        )

        XCTAssertTrue(
            app.tabBars
                .buttons["Today"]
                .exists
        )
    }

    @MainActor
    func testExistingFreeUserLaunchesToday() {
        let app =
            launchBUILT(
                scenario:
                    .existingFree
            )

        assertExists(
            element(
                "built.screen.today",
                in: app
            ),
            "Existing-user launch did not open Today."
        )

        XCTAssertTrue(
            app.tabBars
                .buttons["Today"]
                .exists
        )
    }

    @MainActor
    func testRescueDeepLinkCompletesFreeFlow() {
        let app =
            launchBUILT(
                scenario:
                    .existingFree,
                route:
                    "built://rescue"
            )

        assertExists(
            app.staticTexts[
                "Name the urge."
            ],
            timeout: 10,
            "Rescue deep link did not open the rescue session."
        )

        tap(
            app.buttons[
                "Begin 60-second reset"
            ]
        )

        tap(
            app.buttons[
                "Skip to actions"
            ]
        )

        tap(
            app.buttons[
                "I didn’t smoke"
            ]
        )

        assertExists(
            app.staticTexts[
                "Craving defeated."
            ],
            "The successful rescue result did not appear."
        )

        tap(
            app.buttons["Done"]
        )

        assertExists(
            app.buttons[
                "Start a 60-second rescue"
            ],
            "Closing the rescue session did not return to Rescue."
        )
    }

    @MainActor
    func testFreeUserCanOpenAndClosePaywall() {
        let app =
            launchBUILT(
                scenario:
                    .existingFree,
                presentsPaywall:
                    true
            )

        let close =
            app.buttons[
                "Close BUILT Pro"
            ]

        assertExists(
            close,
            timeout: 10,
            "The BUILT Pro paywall did not appear."
        )

        tap(close)

        assertExists(
            element(
                "built.screen.today",
                in: app
            ),
            "Closing the paywall did not return to the app."
        )
    }

    @MainActor
    func testSettingsOpensNotificationPreferences() {
        let app =
            launchBUILT(
                scenario:
                    .existingFree
            )

        tap(
            app.buttons[
                "Open settings"
            ]
        )

        assertExists(
            app.navigationBars[
                "Settings"
            ],
            "Settings did not open."
        )

        let notifications =
            element(
                "built.settings.notifications",
                in: app
            )

        for _ in 0..<7
        where !notifications.isHittable {
            app.swipeUp()
        }

        tap(notifications)

        assertExists(
            app.navigationBars[
                "Notifications"
            ],
            "Notification preferences did not open."
        )
    }

    @MainActor
    func testFitnessDeepLinkSelectsFitness() {
        let app =
            launchBUILT(
                scenario:
                    .existingFree,
                route:
                    "built://fitness"
            )

        assertExists(
            element(
                "built.screen.fitness",
                in: app
            ),
            "Fitness deep link did not open Fitness."
        )

        XCTAssertTrue(
            app.tabBars
                .buttons["Fitness"]
                .exists
        )
    }

    @MainActor
    func testRewardsDeepLinkSelectsGrowthRewards() {
        let app =
            launchBUILT(
                scenario:
                    .existingFree,
                route:
                    "built://rewards"
            )

        assertExists(
            element(
                "built.screen.growth",
                in: app
            ),
            "Rewards deep link did not open Growth."
        )

        XCTAssertTrue(
            app.tabBars
                .buttons["Growth"]
                .exists
        )

        let rewardsIsVisible =
            app.buttons[
                "Rewards"
            ]
            .exists
            || app.staticTexts[
                "Rewards"
            ]
            .exists

        XCTAssertTrue(
            rewardsIsVisible,
            "The Rewards growth section was not selected."
        )
    }

    @MainActor
    func testFreeUserCanTryDayOneThenReachPlanPaywall() {
        let app =
            launchBUILT(
                scenario:
                    .existingFree
            )

        tap(
            element(
                "built.today.plan",
                in: app
            )
        )

        assertExists(
            element(
                "built.screen.plan",
                in: app
            ),
            "The personalized BUILT Plan did not open."
        )

        assertExists(
            app.staticTexts["DAY 1"],
            "The free first mission was not visible."
        )

        scrollToAndTap(
            app.buttons[
                "Complete Day 1"
            ],
            in: app
        )

        assertExists(
            app.buttons[
                "Unlock Days 2–7"
            ],
            "Completing free Day 1 did not expose the full-plan upgrade."
        )

        scrollToAndTap(
            app.buttons[
                "Unlock Days 2–7"
            ],
            in: app,
            scrollDown: true
        )

        assertExists(
            app.buttons[
                "Close BUILT Pro"
            ],
            timeout: 10,
            "The full-plan upgrade did not open BUILT Pro."
        )
    }

    @MainActor
    func testProUserAdvancesFromDayOneToDayTwo() {
        let app =
            launchBUILT(
                scenario:
                    .existingPro
            )

        tap(
            element(
                "built.today.plan",
                in: app
            )
        )

        assertExists(
            element(
                "built.screen.plan",
                in: app
            ),
            "The personalized BUILT Plan did not open for Pro."
        )

        scrollToAndTap(
            app.buttons[
                "Complete Day 1"
            ],
            in: app
        )

        assertExists(
            app.staticTexts["DAY 2"],
            "Completing Day 1 did not reveal Day 2."
        )

        assertExists(
            app.buttons[
                "Complete Day 2"
            ],
            "Day 2 did not become actionable for the Pro user."
        )
    }

}
