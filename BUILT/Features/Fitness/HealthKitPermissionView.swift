import SwiftUI

struct HealthKitPermissionView: View {
    let isAvailable: Bool
    let isWorking: Bool
    let errorMessage: String?
    let onConnect: () -> Void

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 26
        ) {
            permissionHero
            privacyCard

            Button {
                onConnect()
            } label: {
                HStack {
                    Image(
                        systemName: "heart.text.clipboard"
                    )

                    Text(
                        isWorking
                        ? "Connecting to Apple Health…"
                        : "Connect Apple Health"
                    )

                    Spacer()

                    if isWorking {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Image(
                            systemName: "arrow.right"
                        )
                    }
                }
            }
            .buttonStyle(
                BuiltPrimaryButtonStyle()
            )
            .disabled(
                !isAvailable || isWorking
            )

            if let errorMessage {
                Text(errorMessage)
                    .font(
                        .system(
                            size: 13,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.danger
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .multilineTextAlignment(
                        .center
                    )
            }
        }
    }

    private var permissionHero: some View {
        VStack(
            alignment: .leading,
            spacing: 22
        ) {
            Image(
                systemName: "heart.fill"
            )
            .font(
                .system(
                    size: 28,
                    weight: .semibold
                )
            )
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

            Text(
                """
                Your training is
                proof of the change.
                """
            )
            .font(
                .system(
                    size: 38,
                    weight: .bold
                )
            )
            .tracking(-1.2)
            .foregroundStyle(
                BuiltTheme.textPrimary
            )

            Text(
                isAvailable
                ? """
                Connect Apple Health to see every workout completed by the version of you that does not smoke.
                """
                : """
                Health data is not available on this device. Run BUILT on an iPhone with the Health app.
                """
            )
            .font(
                .system(
                    size: 16,
                    weight: .medium
                )
            )
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
    }

    private var privacyCard: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Label(
                "Private by design",
                systemImage: "lock.shield.fill"
            )
            .font(
                .system(
                    size: 17,
                    weight: .semibold
                )
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
                text: "Reads Apple Exercise Time"
            )

            Divider()
                .overlay(
                    BuiltTheme.hairline
                )

            Text(
                """
                BUILT never writes to Apple Health and does not upload your health data.
                """
            )
            .font(.system(size: 13))
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
        .builtCard()
    }

    private func permissionRow(
        icon: String,
        text: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(width: 24)

            Text(text)
                .font(
                    .system(
                        size: 14,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary.opacity(0.88)
                )
        }
    }
}
