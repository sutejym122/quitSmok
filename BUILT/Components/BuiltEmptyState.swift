import SwiftUI

struct BuiltEmptyState: View {
    let systemName: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @ScaledMetric(relativeTo: .title)
    private var iconContainerSize: CGFloat = 74

    var body: some View {
        VStack(
            spacing: BuiltTheme.Spacing.large
        ) {
            Image(systemName: systemName)
                .font(
                    .title
                    .weight(.light)
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(
                    width: iconContainerSize,
                    height: iconContainerSize
                )
                .background(
                    BuiltTheme.accent.opacity(0.12),
                    in: Circle()
                )
                .accessibilityHidden(true)

            VStack(
                spacing: BuiltTheme.Spacing.small
            ) {
                Text(title)
                    .font(
                        .title3
                        .weight(.bold)
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .multilineTextAlignment(.center)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                    .multilineTextAlignment(.center)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            if let actionTitle,
               let action {
                Button(
                    actionTitle,
                    action: action
                )
                .buttonStyle(
                    BuiltSecondaryButtonStyle()
                )
            }
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(
            dynamicTypeSize.isAccessibilitySize
            ? 20
            : 26
        )
        .builtCard(padding: 0)
        .accessibilityElement(
            children:
                action == nil
                ? .combine
                : .contain
        )
    }
}
