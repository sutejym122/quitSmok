import SwiftUI

struct SectionHeader: View {
    let eyebrow: String
    let title: String
    var trailingText: String? = nil

    var body: some View {
        HStack(
            alignment: .lastTextBaseline
        ) {
            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text(eyebrow.uppercased())
                    .font(
                        .system(
                            size: 11,
                            weight: .semibold
                        )
                    )
                    .tracking(1.8)
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                Text(title)
                    .font(
                        .system(
                            size: 28,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
            }

            Spacer()

            if let trailingText {
                Text(trailingText)
                    .font(
                        .system(
                            size: 13,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
            }
        }
    }
}
