import SwiftUI

struct UpgradeCard: View {
    let title: String
    let message: String
    var feature: ProFeature?
    let action: () -> Void

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @ScaledMetric(relativeTo: .body)
    private var iconContainerSize: CGFloat = 50

    var body: some View {
        Button(action: action) {
            VStack(
                alignment: .leading,
                spacing: BuiltTheme.Spacing.large
            ) {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(
                        alignment: .leading,
                        spacing: BuiltTheme.Spacing.medium
                    ) {
                        featureIcon
                        ProBadge()
                    }
                } else {
                    HStack(alignment: .top) {
                        featureIcon
                        Spacer()
                        ProBadge()
                    }
                }

                VStack(
                    alignment: .leading,
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

                HStack(spacing: 8) {
                    Text("Explore BUILT Pro")
                        .font(
                            .subheadline
                            .weight(.semibold)
                        )

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(
                            .subheadline
                            .weight(.bold)
                        )
                        .accessibilityHidden(true)
                }
                .foregroundStyle(BuiltTheme.accent)
                .frame(
                    minHeight:
                        BuiltTheme.minimumTapTarget
                )
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .builtCard(padding: 20)
        }
        .buttonStyle(.plain)
        .contentShape(
            RoundedRectangle(
                cornerRadius:
                    BuiltTheme.mediumRadius,
                style: .continuous
            )
        )
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            "\(title). \(message)"
        )
        .accessibilityHint(
            "Opens the BUILT Pro purchase screen"
        )
        .accessibilityAddTraits(.isButton)
    }

    private var featureIcon: some View {
        ZStack {
            Circle()
                .fill(
                    BuiltTheme.accent.opacity(0.14)
                )
                .frame(
                    width: iconContainerSize,
                    height: iconContainerSize
                )

            Image(
                systemName:
                    feature?.symbolName
                    ?? "diamond.fill"
            )
            .font(.title3.weight(.semibold))
            .foregroundStyle(BuiltTheme.accent)
        }
        .accessibilityHidden(true)
    }
}
