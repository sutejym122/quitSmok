import SwiftUI

struct BuiltHeroPanel: View {
    let eyebrow: String
    let title: String
    let message: String
    let systemName: String
    var trailingValue: String? = nil
    var trailingLabel: String? = nil

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @ScaledMetric(relativeTo: .title)
    private var iconContainerSize: CGFloat = 58

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.large
        ) {
            topRow

            VStack(
                alignment: .leading,
                spacing: BuiltTheme.Spacing.small
            ) {
                Text(eyebrow.uppercased())
                    .font(
                        .caption
                        .weight(.bold)
                    )
                    .tracking(
                        dynamicTypeSize.isAccessibilitySize
                        ? 0.7
                        : 1.6
                    )
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                Text(title)
                    .font(
                        dynamicTypeSize.isAccessibilitySize
                        ? .title.weight(.bold)
                        : .largeTitle.weight(.bold)
                    )
                    .tracking(
                        dynamicTypeSize.isAccessibilitySize
                        ? 0
                        : -1.0
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(message)
                    .font(.body)
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
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

    @ViewBuilder
    private var topRow: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(
                alignment: .leading,
                spacing: BuiltTheme.Spacing.medium
            ) {
                icon

                if trailingValue != nil {
                    trailingMetric
                }
            }
        } else {
            HStack(
                alignment: .top,
                spacing: BuiltTheme.Spacing.medium
            ) {
                icon
                Spacer()

                if trailingValue != nil {
                    trailingMetric
                }
            }
        }
    }

    private var icon: some View {
        Image(systemName: systemName)
            .font(
                .title3
                .weight(.semibold)
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
    }

    private var trailingMetric: some View {
        VStack(
            alignment:
                dynamicTypeSize.isAccessibilitySize
                ? .leading
                : .trailing,
            spacing: BuiltTheme.Spacing.xSmall
        ) {
            Text(trailingValue ?? "")
                .font(
                    .title2
                    .weight(.bold)
                    .monospacedDigit()
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            if let trailingLabel {
                Text(trailingLabel.uppercased())
                    .font(
                        .caption2
                        .weight(.bold)
                    )
                    .tracking(1.0)
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
            }
        }
    }
}
