import SwiftUI

struct RecoveryMilestoneCard: View {
    let milestone: RecoveryMilestone
    let isCompleted: Bool
    let isNext: Bool
    let progress: Double?

    var body: some View {
        HStack(
            alignment: .top,
            spacing: 16
        ) {
            statusColumn

            VStack(
                alignment: .leading,
                spacing: 12
            ) {
                HStack(
                    alignment: .firstTextBaseline,
                    spacing: 10
                ) {
                    Text(milestone.timeLabel)
                        .font(
                            .system(
                                size: 10,
                                weight: .bold
                            )
                        )
                        .tracking(1.5)
                        .foregroundStyle(
                            isCompleted || isNext
                                ? BuiltTheme.accent
                                : BuiltTheme.textSecondary
                        )

                    Spacer()

                    if isCompleted {
                        Label(
                            "REACHED",
                            systemImage: "checkmark"
                        )
                        .font(
                            .system(
                                size: 9,
                                weight: .bold
                            )
                        )
                        .tracking(1)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(
                            BuiltTheme.accent,
                            in: Capsule()
                        )
                    } else if isNext {
                        Text("NEXT")
                            .font(
                                .system(
                                    size: 9,
                                    weight: .bold
                                )
                            )
                            .tracking(1)
                            .foregroundStyle(BuiltTheme.accent)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 6)
                            .background(
                                BuiltTheme.accent.opacity(0.12),
                                in: Capsule()
                            )
                    }
                }

                Text(milestone.title)
                    .font(
                        .system(
                            size: 21,
                            weight: .semibold
                        )
                    )
                    .tracking(-0.4)
                    .foregroundStyle(BuiltTheme.textPrimary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(milestone.summary)
                    .font(
                        .system(
                            size: 14,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(BuiltTheme.textSecondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                if let progress, isNext {
                    ProgressView(value: progress)
                        .tint(BuiltTheme.accent)
                        .background(
                            Color.white.opacity(0.08),
                            in: Capsule()
                        )
                }

                DisclosureGroup {
                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {
                        Text(milestone.detail)
                            .font(.system(size: 13))
                            .foregroundStyle(BuiltTheme.textSecondary)
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )

                        if let sourceURL = milestone.sourceURL {
                            Link(destination: sourceURL) {
                                Label(
                                    "Source: \(milestone.sourceName)",
                                    systemImage: "arrow.up.right"
                                )
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .semibold
                                    )
                                )
                                .foregroundStyle(BuiltTheme.accent)
                            }
                        }
                    }
                    .padding(.top, 8)
                } label: {
                    Text("Why this matters")
                        .font(
                            .system(
                                size: 12,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(BuiltTheme.textSecondary)
                }
                .tint(BuiltTheme.textSecondary)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 18)
        .opacity(isCompleted || isNext ? 1 : 0.72)
    }

    private var statusColumn: some View {
        ZStack {
            Circle()
                .fill(
                    isCompleted
                        ? BuiltTheme.accent
                        : BuiltTheme.accent.opacity(isNext ? 0.16 : 0.07)
                )
                .frame(width: 46, height: 46)

            Image(systemName: isCompleted ? "checkmark" : milestone.symbolName)
                .font(
                    .system(
                        size: 17,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    isCompleted
                        ? Color.black
                        : isNext
                            ? BuiltTheme.accent
                            : BuiltTheme.textSecondary
                )
        }
    }
}
