import SwiftUI

struct FitnessMetricCard: View {
    let icon: String
    let value: String
    let title: String
    let footnote: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 17
        ) {
            HStack {
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

                Spacer()
            }

            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text(value)
                    .font(
                        .system(
                            size: 27,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)

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
            minHeight: 146,
            alignment: .leading
        )
        .builtCard(padding: 17)
    }
}
