import SwiftUI

struct BuiltSettingsSection<Content: View>: View {
    let title: String
    let symbolName: String
    private let content: Content

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    init(
        title: String,
        symbolName: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.symbolName = symbolName
        self.content = content()
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            Label(
                title,
                systemImage: symbolName
            )
            .font(
                .headline
                .weight(.semibold)
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .accessibilityAddTraits(.isHeader)

            content
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(
            padding:
                dynamicTypeSize.isAccessibilitySize
                ? 20
                : 18
        )
    }
}

struct BuiltSettingsInfoRow: View {
    let symbolName: String
    let title: String
    let subtitle: String
    var value: String? = nil
    var tint: Color = BuiltTheme.accent

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @ScaledMetric(relativeTo: .body)
    private var iconSize: CGFloat = 40

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    HStack(
                        alignment: .top,
                        spacing: BuiltTheme.Spacing.medium
                    ) {
                        icon
                        copy
                    }

                    if let value {
                        Text(value)
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
                    }
                }
            } else {
                HStack(
                    alignment: .center,
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    icon
                    copy
                    Spacer(minLength: 12)

                    if let value {
                        Text(value)
                            .font(
                                .subheadline
                                .weight(.semibold)
                            )
                            .foregroundStyle(
                                BuiltTheme.textPrimary
                            )
                            .multilineTextAlignment(
                                .trailing
                            )
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    }
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            minHeight:
                BuiltTheme.minimumTapTarget,
            alignment: .leading
        )
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(title)
        .accessibilityValue(
            [subtitle, value]
                .compactMap { $0 }
                .joined(separator: ". ")
        )
    }

    private var icon: some View {
        Image(systemName: symbolName)
            .font(.body.weight(.semibold))
            .foregroundStyle(tint)
            .frame(
                width: iconSize,
                height: iconSize
            )
            .background(
                tint.opacity(0.11),
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
                    .subheadline
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text(subtitle)
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
}

struct BuiltSettingsNavigationRow: View {
    let symbolName: String
    let title: String
    let subtitle: String
    var value: String? = nil
    var tint: Color = BuiltTheme.accent

    var body: some View {
        HStack(
            spacing: BuiltTheme.Spacing.medium
        ) {
            BuiltSettingsInfoRow(
                symbolName: symbolName,
                title: title,
                subtitle: subtitle,
                value: value,
                tint: tint
            )

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(
                    BuiltTheme.textTertiary
                )
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(title)
        .accessibilityValue(
            [subtitle, value]
                .compactMap { $0 }
                .joined(separator: ". ")
        )
        .accessibilityHint(
            "Opens \(title)"
        )
        .accessibilityAddTraits(.isButton)
    }
}

struct BuiltSettingsStatusPill: View {
    let title: String
    let symbolName: String
    var tint: Color = BuiltTheme.accent

    var body: some View {
        Label(
            title.uppercased(),
            systemImage: symbolName
        )
        .font(.caption2.weight(.bold))
        .tracking(0.8)
        .foregroundStyle(tint)
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(
            tint.opacity(0.11),
            in: Capsule(style: .continuous)
        )
        .accessibilityElement(
            children: .combine
        )
    }
}

struct BuiltSettingsDivider: View {
    var body: some View {
        Divider()
            .overlay(BuiltTheme.hairline)
            .accessibilityHidden(true)
    }
}
