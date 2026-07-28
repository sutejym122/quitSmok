import SwiftUI

struct ProFeatureRow: View {
    let feature: ProFeature

    var body: some View {
        HStack(
            alignment: .top,
            spacing: 14
        ) {
            Image(systemName: feature.symbolName)
                .font(
                    .system(
                        size: 16,
                        weight: .semibold
                    )
                )
                .foregroundStyle(BuiltTheme.accent)
                .frame(width: 38, height: 38)
                .background(
                    BuiltTheme.accent.opacity(0.12),
                    in: Circle()
                )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(feature.title)
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                Text(feature.detail)
                    .font(.system(size: 13))
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            Spacer(minLength: 0)
        }
    }
}
