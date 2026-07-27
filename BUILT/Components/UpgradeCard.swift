import SwiftUI

struct UpgradeCard: View {
    let title: String
    let message: String
    var feature: ProFeature?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(
                alignment: .leading,
                spacing: 18
            ) {
                HStack(alignment: .top) {
                    ZStack {
                        Circle()
                            .fill(
                                BuiltTheme.accent.opacity(0.14)
                            )
                            .frame(width: 48, height: 48)

                        Image(
                            systemName:
                                feature?.symbolName
                                ?? "diamond.fill"
                        )
                        .font(
                            .system(
                                size: 19,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(BuiltTheme.accent)
                    }

                    Spacer()
                    ProBadge()
                }

                VStack(
                    alignment: .leading,
                    spacing: 7
                ) {
                    Text(title)
                        .font(
                            .system(
                                size: 22,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )

                    Text(message)
                        .font(
                            .system(
                                size: 14,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }

                HStack {
                    Text("Explore BUILT Pro")
                        .font(
                            .system(
                                size: 14,
                                weight: .semibold
                            )
                        )

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(
                            .system(
                                size: 13,
                                weight: .bold
                            )
                        )
                }
                .foregroundStyle(BuiltTheme.accent)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .builtCard(padding: 20)
        }
        .buttonStyle(.plain)
        .accessibilityHint(
            "Opens the BUILT Pro purchase screen"
        )
    }
}
