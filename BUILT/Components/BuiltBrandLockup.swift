import SwiftUI

struct BuiltBrandLockup: View {
    var compact = false

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.xSmall
        ) {
            Text("BUILT.")
                .font(
                    compact
                    ? .headline.weight(.black)
                    : .title3.weight(.black)
                )
                .tracking(
                    dynamicTypeSize.isAccessibilitySize
                    ? 0.8
                    : 2.0
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            Text("BUILT, NOT BURNED")
                .font(
                    .caption2
                    .weight(.bold)
                )
                .tracking(
                    dynamicTypeSize.isAccessibilitySize
                    ? 0.5
                    : 1.35
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )
        }
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            "BUILT. Built, not burned."
        )
    }
}
