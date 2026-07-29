import XCTest

final class BUILTUILaunchPerformanceTests:
    BUILTUITestCase {
    @MainActor
    func testExistingUserLaunchPerformance() {
        let app =
            XCUIApplication()

        app.launchArguments = [
            "--built-ui-testing",
            "--built-ui-scenario=existing-free",
            "-AppleLanguages",
            "(en)",
            "-AppleLocale",
            "en_US"
        ]

        let options =
            XCTMeasureOptions()

        options.iterationCount = 3

        measure(
            metrics: [
                XCTApplicationLaunchMetric(
                    waitUntilResponsive:
                        true
                )
            ],
            options: options
        ) {
            app.launch()

            XCTAssertTrue(
                app.descendants(
                    matching: .any
                )[
                    "built.screen.today"
                ]
                .waitForExistence(
                    timeout: 12
                )
            )

            app.terminate()
        }
    }
}
