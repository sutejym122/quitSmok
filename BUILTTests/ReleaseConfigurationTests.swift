import Testing

@testable import BUILT

@Suite("Release Configuration")
struct ReleaseConfigurationTests {
    @Test(
        "A valid BUILT release configuration has no issues"
    )
    func validConfiguration() {
        let info: [String: Any] = [
            "NSHealthShareUsageDescription":
                "BUILT reads workout data.",
            "CFBundleURLTypes": [
                [
                    "CFBundleURLSchemes": [
                        "built"
                    ]
                ]
            ]
        ]

        let issues =
            ReleaseConfigurationValidator
                .issues(
                    infoDictionary: info,
                    bundleIdentifier:
                        "com.sutej.built"
                )

        #expect(issues.isEmpty)
    }

    @Test(
        "Missing health and URL settings are reported without crashing"
    )
    func invalidConfiguration() {
        let issues =
            ReleaseConfigurationValidator
                .issues(
                    infoDictionary: [:],
                    bundleIdentifier: nil
                )

        let codes =
            Set(
                issues.map(\.code)
            )

        #expect(
            codes.contains(
                "missing-bundle-identifier"
            )
        )

        #expect(
            codes.contains(
                "missing-health-purpose"
            )
        )

        #expect(
            codes.contains(
                "missing-built-url-scheme"
            )
        )
    }
}
