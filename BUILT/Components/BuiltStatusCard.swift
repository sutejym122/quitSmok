import SwiftUI

enum BuiltStatusKind {
    case neutral
    case success
    case warning
    case error

    var icon: String {
        switch self {
        case .neutral:
            return "info.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "exclamationmark.octagon.fill"
        }
    }

    var tint: Color {
        switch self {
        case .neutral:
            return BuiltTheme.accentSoft
        case .success:
            return BuiltTheme.success
        case .warning:
            return BuiltTheme.warning
        case .error:
            return BuiltTheme.danger
        }
    }

    var accessibilityPrefix: String {
        switch self {
        case .neutral:
            return "Information"
        case .success:
            return "Success"
        case .warning:
            return "Warning"
        case .error:
            return "Error"
        }
    }
}

struct BuiltStatusCard: View {
    let kind: BuiltStatusKind
    let title: String
    let message: String
    var primaryActionTitle: String? = nil
    var primaryAction: (() -> Void)? = nil
    var secondaryActionTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing: BuiltTheme.Spacing.small
                ) {
                    statusIcon
                    copy
                }
            } else {
                HStack(
                    alignment: .top,
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    statusIcon
                    copy
                }
            }

            if primaryActionTitle != nil
                || secondaryActionTitle != nil {
                actionArea
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 18)
    }

    private var statusIcon: some View {
        Image(systemName: kind.icon)
            .font(.title3.weight(.semibold))
            .foregroundStyle(kind.tint)
            .frame(
                width: 40,
                height: 40
            )
            .background(
                kind.tint.opacity(0.12),
                in: Circle()
            )
            .accessibilityHidden(true)
    }

    private var copy: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.xSmall
        ) {
            Text(title)
                .font(
                    .headline
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text(message)
                .font(.subheadline)
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            "\(kind.accessibilityPrefix): \(title)"
        )
        .accessibilityValue(message)
    }

    @ViewBuilder
    private var actionArea: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: 4) {
                primaryActionButton
                secondaryActionButton
            }
        } else {
            HStack(spacing: 18) {
                primaryActionButton
                secondaryActionButton
            }
        }
    }

    @ViewBuilder
    private var primaryActionButton: some View {
        if let primaryActionTitle,
           let primaryAction {
            Button(
                primaryActionTitle,
                action: primaryAction
            )
            .buttonStyle(
                BuiltTertiaryButtonStyle()
            )
        }
    }

    @ViewBuilder
    private var secondaryActionButton: some View {
        if let secondaryActionTitle,
           let secondaryAction {
            Button(
                secondaryActionTitle,
                action: secondaryAction
            )
            .buttonStyle(
                BuiltTertiaryButtonStyle()
            )
        }
    }
}

struct BuiltLoadingCard: View {
    let title: String
    var message: String? = nil

    var body: some View {
        HStack(
            alignment: .center,
            spacing: BuiltTheme.Spacing.medium
        ) {
            ProgressView()
                .tint(BuiltTheme.accent)
                .controlSize(.regular)
                .accessibilityHidden(true)

            VStack(
                alignment: .leading,
                spacing: BuiltTheme.Spacing.xSmall
            ) {
                Text(title)
                    .font(
                        .headline
                        .weight(.semibold)
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                if let message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 18)
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(title)
        .accessibilityValue(
            message ?? "In progress"
        )
    }
}
