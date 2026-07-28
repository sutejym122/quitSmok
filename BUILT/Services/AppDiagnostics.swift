import Foundation
import OSLog

enum BuiltLog {
    private static let subsystem =
        Bundle.main.bundleIdentifier
        ?? "com.sutej.built"

    static let lifecycle = Logger(
        subsystem: subsystem,
        category: "Lifecycle"
    )

    static let persistence = Logger(
        subsystem: subsystem,
        category: "Persistence"
    )

    static let notifications = Logger(
        subsystem: subsystem,
        category: "Notifications"
    )

    static let storeKit = Logger(
        subsystem: subsystem,
        category: "StoreKit"
    )

    static let widgets = Logger(
        subsystem: subsystem,
        category: "Widgets"
    )
}

struct ReleaseConfigurationIssue:
    Equatable,
    Sendable {
    let code: String
    let message: String
}

enum ReleaseConfigurationValidator {
    static func issues(
        infoDictionary: [String: Any],
        bundleIdentifier: String?
    ) -> [ReleaseConfigurationIssue] {
        var issues:
            [ReleaseConfigurationIssue] = []

        let trimmedBundleIdentifier =
            bundleIdentifier?
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
            ?? ""

        if trimmedBundleIdentifier.isEmpty {
            issues.append(
                ReleaseConfigurationIssue(
                    code:
                        "missing-bundle-identifier",
                    message:
                        "The main app bundle identifier is missing."
                )
            )
        }

        let healthPurpose =
            (
                infoDictionary[
                    "NSHealthShareUsageDescription"
                ] as? String
            )?
            .trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )
            ?? ""

        if healthPurpose.isEmpty {
            issues.append(
                ReleaseConfigurationIssue(
                    code:
                        "missing-health-purpose",
                    message:
                        "NSHealthShareUsageDescription is missing or empty."
                )
            )
        }

        let registeredSchemes =
            registeredURLSchemes(
                in: infoDictionary
            )

        if !registeredSchemes.contains(
            BuiltSharedConstants.urlScheme
        ) {
            issues.append(
                ReleaseConfigurationIssue(
                    code:
                        "missing-built-url-scheme",
                    message:
                        "The built URL scheme is not registered."
                )
            )
        }

        if BuiltSharedConstants
            .appGroupIdentifier
            != "group.com.sutej.built" {
            issues.append(
                ReleaseConfigurationIssue(
                    code:
                        "unexpected-app-group",
                    message:
                        "The shared app-group identifier does not match BUILT's release configuration."
                )
            )
        }

        if StoreManager.proProductID
            != "com.sutej.built.pro.lifetime" {
            issues.append(
                ReleaseConfigurationIssue(
                    code:
                        "unexpected-pro-product-id",
                    message:
                        "The lifetime Pro product identifier does not match BUILT's release configuration."
                )
            )
        }

        return issues
    }

    private static func registeredURLSchemes(
        in infoDictionary: [String: Any]
    ) -> Set<String> {
        guard
            let urlTypes =
                infoDictionary[
                    "CFBundleURLTypes"
                ] as? [[String: Any]]
        else {
            return []
        }

        let schemes = urlTypes.flatMap {
            entry -> [String] in

            entry[
                "CFBundleURLSchemes"
            ] as? [String]
            ?? []
        }

        return Set(
            schemes.map {
                $0.lowercased()
            }
        )
    }
}

enum AppDiagnostics {
    static func recordLaunch(
        bundle: Bundle = .main
    ) {
        BuiltLog.lifecycle.info(
            "BUILT launch started."
        )

        let issues =
            ReleaseConfigurationValidator
                .issues(
                    infoDictionary:
                        bundle.infoDictionary
                        ?? [:],
                    bundleIdentifier:
                        bundle
                            .bundleIdentifier
                )

        guard issues.isEmpty else {
            for issue in issues {
                BuiltLog.lifecycle.fault(
                    "Release configuration issue [\(issue.code, privacy: .public)]: \(issue.message, privacy: .public)"
                )
            }

            return
        }

        BuiltLog.lifecycle.info(
            "Release configuration validation passed."
        )
    }

    static func recordModelContainerReady(
        inMemory: Bool
    ) {
        BuiltLog.persistence.info(
            "SwiftData container ready. In-memory: \(inMemory, privacy: .public)"
        )
    }

    static func recordModelContainerFailure(
        _ error: Error
    ) {
        BuiltLog.persistence.fault(
            "SwiftData container creation failed: \(error.localizedDescription, privacy: .private)"
        )
    }
}
