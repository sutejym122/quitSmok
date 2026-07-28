import SwiftUI
import UIKit

struct HealthKitPermissionView: View {
    let isAvailable: Bool
    let isWorking: Bool
    let errorMessage: String?
    let onConnect: () -> Void

    @Environment(\.openURL)
    private var openURL

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.xLarge
        ) {
            permissionHero
            privacyCard

            Button {
                onConnect()
            } label: {
                HStack(spacing: 12) {
                    Image(
                        systemName:
                            "heart.text.clipboard"
                    )
                    .accessibilityHidden(true)

                    Text(
                        isWorking
                        ? "Connecting to Apple Health…"
                        : "Connect Apple Health"
                    )

                    Spacer()

                    if isWorking {
                        ProgressView()
                            .tint(.black)
                            .accessibilityHidden(true)
                    } else {
                        Image(
                            systemName: "arrow.right"
                        )
                        .accessibilityHidden(true)
                    }
                }
            }
            .buttonStyle(
                BuiltPrimaryButtonStyle()
            )
            .disabled(
                !isAvailable || isWorking
            )
            .accessibilityHint(
                isAvailable
                ? "Shows the Apple Health permission screen"
                : "Apple Health is unavailable on this device"
            )

            if let errorMessage {
                BuiltStatusCard(
                    kind: .error,
                    title:
                        "Apple Health needs attention",
                    message: errorMessage,
                    primaryActionTitle:
                        "Open Settings",
                    primaryAction: openAppSettings,
                    secondaryActionTitle:
                        "Try again",
                    secondaryAction: onConnect
                )
            } else if !isAvailable {
                BuiltStatusCard(
                    kind: .warning,
                    title:
                        "Apple Health is unavailable",
                    message:
                        "Run BUILT on an iPhone with the Health app to connect workout data."
                )
            }
        }
    }

    private var permissionHero: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.large
        ) {
            Image(systemName: "heart.fill")
                .font(.title2.weight(.semibold))
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(
                    width: 62,
                    height: 62
                )
                .background(
                    BuiltTheme.accent.opacity(0.12),
                    in: Circle()
                )
                .accessibilityHidden(true)

            Text(
                "Your training is proof of the change."
            )
            .font(
                dynamicTypeSize.isAccessibilitySize
                ? .title.weight(.bold)
                : .largeTitle.weight(.bold)
            )
            .tracking(
                dynamicTypeSize.isAccessibilitySize
                ? 0
                : -1
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            Text(
                isAvailable
                ? "Connect Apple Health to see every workout completed by the version of you that does not smoke."
                : "Health data is not available on this device. Run BUILT on an iPhone with the Health app."
            )
            .font(.body)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 24)
        .accessibilityElement(
            children: .combine
        )
    }

    private var privacyCard: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            Label(
                "Private by design",
                systemImage: "lock.shield.fill"
            )
            .font(
                .headline
                .weight(.semibold)
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )

            permissionRow(
                icon: "figure.run",
                text: "Reads completed workouts"
            )

            permissionRow(
                icon: "flame.fill",
                text: "Reads active energy"
            )

            permissionRow(
                icon: "clock.fill",
                text:
                    "Reads Apple Exercise Time"
            )

            Divider()
                .overlay(
                    BuiltTheme.hairline
                )

            Text(
                "BUILT never writes to Apple Health and does not upload your health data."
            )
            .font(.footnote)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .builtCard()
        .accessibilityElement(
            children: .combine
        )
    }

    private func permissionRow(
        icon: String,
        text: String
    ) -> some View {
        HStack(
            alignment: .firstTextBaseline,
            spacing: 12
        ) {
            Image(systemName: icon)
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(width: 24)
                .accessibilityHidden(true)

            Text(text)
                .font(
                    .subheadline
                    .weight(.medium)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                        .opacity(0.90)
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
    }

    private func openAppSettings() {
        guard let settingsURL = URL(
            string:
                UIApplication.openSettingsURLString
        ) else {
            return
        }

        openURL(settingsURL)
    }
}
