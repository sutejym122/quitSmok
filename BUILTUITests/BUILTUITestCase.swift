import XCTest

enum BUILTUITestScenario:
    String {
    case fresh
    case existingFree =
        "existing-free"
    case existingPro =
        "existing-pro"
}

class BUILTUITestCase:
    XCTestCase {
    var application:
        XCUIApplication?

    override func setUpWithError()
        throws {
        continueAfterFailure = false

        XCUIDevice.shared
            .orientation = .portrait
    }

    override func tearDownWithError()
        throws {
        if let application,
           let testRun,
           testRun.failureCount > 0 {
            let attachment =
                XCTAttachment(
                    screenshot:
                        application
                            .screenshot()
                )

            attachment.name =
                "Failure - \(name)"
            attachment.lifetime =
                .keepAlways

            add(attachment)
        }

        application?
            .terminate()
        application = nil
    }

    @MainActor
    @discardableResult
    func launchBUILT(
        scenario:
            BUILTUITestScenario,
        route: String? = nil,
        presentsPaywall:
            Bool = false
    ) -> XCUIApplication {
        let app =
            XCUIApplication()

        var arguments = [
            "--built-ui-testing",
            "--built-ui-scenario=\(scenario.rawValue)",
            "-AppleLanguages",
            "(en)",
            "-AppleLocale",
            "en_US"
        ]

        if let route {
            arguments.append(
                "--built-ui-route=\(route)"
            )
        }

        if presentsPaywall {
            arguments.append(
                "--built-ui-present-paywall"
            )
        }

        app.launchArguments =
            arguments

        application = app
        app.launch()

        XCTAssertTrue(
            app.wait(
                for:
                    .runningForeground,
                timeout: 12
            ),
            "BUILT did not reach the foreground."
        )

        return app
    }

    @MainActor
    func element(
        _ identifier: String,
        in app:
            XCUIApplication
    ) -> XCUIElement {
        app.descendants(
            matching: .any
        )[identifier]
    }

    @MainActor
    func assertExists(
        _ element:
            XCUIElement,
        timeout:
            TimeInterval = 8,
        _ message: String,
        file:
            StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            element
                .waitForExistence(
                    timeout: timeout
                ),
            message,
            file: file,
            line: line
        )
    }

    @MainActor
    func tap(
        _ element:
            XCUIElement,
        timeout:
            TimeInterval = 8,
        file:
            StaticString = #filePath,
        line: UInt = #line
    ) {
        assertExists(
            element,
            timeout: timeout,
            "Expected element was not available before tapping.",
            file: file,
            line: line
        )

        XCTAssertTrue(
            element.isHittable,
            "Expected element was visible but not hittable.",
            file: file,
            line: line
        )

        element.tap()
    }
}
