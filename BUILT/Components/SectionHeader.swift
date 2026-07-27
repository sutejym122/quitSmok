import SwiftUI

struct SectionHeader: View {
    let eyebrow: String
    let title: String
    var trailingText: String? = nil

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing: BuiltTheme.Spacing.small
                ) {
                    titleBlock

                    if let trailingText {
                        trailingLabel(trailingText)
                    }
                }
            } else {
                HStack(
                    alignment: .lastTextBaseline,
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    titleBlock
                    Spacer(minLength: 12)

                    if let trailingText {
                        trailingLabel(trailingText)
                    }
                }
            }
        }
        .accessibilityElement(
            children: .combine
        )
    }

    private var titleBlock: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.xSmall
        ) {
            Text(eyebrow.uppercased())
                .font(
                    .caption
                    .weight(.bold)
                )
                .tracking(1.4)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(title)
                .font(
                    .title2
                    .weight(.bold)
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

    private func trailingLabel(
        _ text: String
    ) -> some View {
        Text(text)
            .font(
                .subheadline
                .weight(.medium)
            )
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
    }
}
