import SwiftUI

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let footnote: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Image(systemName: icon)
                .font(
                    .system(
                        size: 17,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(
                    width: 36,
                    height: 36
                )
                .background(
                    BuiltTheme.accent.opacity(0.12),
                    in: Circle()
                )

            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text(value)
                    .font(
                        .system(
                            size: 24,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(title)
                    .font(
                        .system(
                            size: 13,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary.opacity(0.88)
                    )

                Text(footnote)
                    .font(
                        .system(
                            size: 11,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                    .lineLimit(2)
            }
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 152,
            alignment: .leading
        )
        .builtCard(padding: 16)
    }
}
