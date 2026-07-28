import SwiftUI

struct FitnessMetricCard: View {
    let icon: String
    let value: String
    let title: String
    let footnote: String

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @ScaledMetric(relativeTo: .body)
    private var iconSize: CGFloat = 19

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            Image(systemName: icon)
                .font(
                    .system(
                        size: iconSize,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.accent
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
                    .minimumScaleFactor(0.64)

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
                : 146,
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
