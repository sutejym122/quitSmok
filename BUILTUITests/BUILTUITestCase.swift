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
    func scrollToAndTap(
        _ element: XCUIElement,
        in app: XCUIApplication,
        maxSwipes: Int = 6,
        scrollDown: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for _ in 0..<maxSwipes {
            if element.exists &&
                element.isHittable {
                element.tap()
                return
            }

            if scrollDown {
                app.swipeDown()
            } else {
                app.swipeUp()
            }
        }

        XCTAssertTrue(
            element.exists,
            "Expected element was not available after scrolling.",
            file: file,
            line: line
        )

        XCTAssertTrue(
            element.isHittable,
            "Expected element was visible but not hittable after scrolling.",
            file: file,
            line: line
        )

        element.tap()
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
