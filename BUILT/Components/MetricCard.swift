import SwiftUI

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let footnote: String

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @ScaledMetric(relativeTo: .body)
    private var iconContainerSize: CGFloat = 38

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
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
                alignment: .leading,
                spacing: BuiltTheme.Spacing.xSmall
            ) {
                Text(value)
                    .font(
                        .title2
                        .weight(.bold)
                        .monospacedDigit()
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .lineLimit(
                        dynamicTypeSize
                            .isAccessibilitySize
                        ? nil
                        : 1
                    )
                    .minimumScaleFactor(0.72)

                Text(title)
                    .font(
                        .subheadline
                        .weight(.semibold)
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                            .opacity(0.90)
                    )

                Text(footnote)
                    .font(.caption)
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
            minHeight:
                dynamicTypeSize
                    .isAccessibilitySize
                ? nil
                : 152,
            alignment: .leading
        )
        .builtCard(padding: 17)
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            "\(title), \(value)"
        )
        .accessibilityValue(footnote)
    }
}
