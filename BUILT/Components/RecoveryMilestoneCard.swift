import SwiftUI

struct RecoveryMilestoneCard: View {
    let milestone: RecoveryMilestone
    let isCompleted: Bool
    let isNext: Bool
    let progress: Double?

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @ScaledMetric(relativeTo: .body)
    private var statusSize: CGFloat = 48

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    HStack {
                        statusColumn
                        Spacer()
                        statusBadge
                    }

                    content
                }
            } else {
                HStack(
                    alignment: .top,
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    statusColumn
                    content
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 18)
        .opacity(
            isCompleted || isNext
            ? 1
            : 0.76
        )
        .accessibilityElement(
            children: .combine
        )
        .accessibilityLabel(
            "\(milestone.timeLabel). \(milestone.title)."
        )
        .accessibilityValue(
            accessibilityStatus
        )
    }

    private var content: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            HStack(
                alignment: .firstTextBaseline,
                spacing: BuiltTheme.Spacing.small
            ) {
                Text(milestone.timeLabel)
                    .font(
                        .caption
                        .weight(.bold)
                    )
                    .tracking(1.2)
                    .foregroundStyle(
                        isCompleted || isNext
                        ? BuiltTheme.accent
                        : BuiltTheme
                            .textSecondary
                    )

                Spacer()

                if !dynamicTypeSize
                    .isAccessibilitySize {
                    statusBadge
                }
            }

            Text(milestone.title)
                .font(
                    .title3
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text(milestone.summary)
                .font(.subheadline)
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            if let progress,
               isNext {
                VStack(
                    alignment: .leading,
                    spacing: BuiltTheme.Spacing.xSmall
                ) {
                    ProgressView(
                        value:
                            min(
                                max(progress, 0),
                                1
                            )
                    )
                    .tint(BuiltTheme.accent)

                    Text(
                        "\(Int((min(max(progress, 0), 1) * 100).rounded()))% toward this milestone"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                }
            }

            DisclosureGroup {
                VStack(
                    alignment: .leading,
                    spacing: BuiltTheme.Spacing.small
                ) {
                    Text(milestone.detail)
                        .font(.subheadline)
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    if let sourceURL =
                        milestone.sourceURL {
                        Link(
                            destination: sourceURL
                        ) {
                            Label(
                                "Source: \(milestone.sourceName)",
                                systemImage:
                                    "arrow.up.right"
                            )
                            .font(
                                .subheadline
                                .weight(.semibold)
                            )
                            .foregroundStyle(
                                BuiltTheme.accent
                            )
                            .frame(
                                minHeight:
                                    BuiltTheme
                                        .minimumTapTarget
                            )
                        }
                    }
                }
                .padding(.top, 8)
            } label: {
                Text("Why this matters")
                    .font(
                        .subheadline
                        .weight(.semibold)
                    )
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                    .frame(
                        minHeight:
                            BuiltTheme
                                .minimumTapTarget
                    )
            }
            .tint(
                BuiltTheme.textSecondary
            )
        }
    }

    private var statusColumn: some View {
        ZStack {
            Circle()
                .fill(
                    isCompleted
                    ? BuiltTheme.accent
                    : BuiltTheme.accent
                        .opacity(
                            isNext
                            ? 0.16
                            : 0.07
                        )
                )
                .frame(
                    width: statusSize,
                    height: statusSize
                )

            Image(
                systemName:
                    isCompleted
                    ? "checkmark"
                    : milestone.symbolName
            )
            .font(
                .body
                .weight(.semibold)
            )
            .foregroundStyle(
                isCompleted
                ? Color.black
                : (
                    isNext
                    ? BuiltTheme.accent
                    : BuiltTheme
                        .textSecondary
                )
            )
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if isCompleted {
            Label(
                "REACHED",
                systemImage: "checkmark"
            )
            .font(
                .caption2
                .weight(.bold)
            )
            .tracking(0.8)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                BuiltTheme.accent,
                in: Capsule()
            )
        } else if isNext {
            Text("NEXT")
                .font(
                    .caption2
                    .weight(.bold)
                )
                .tracking(0.8)
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    BuiltTheme.accent
                        .opacity(0.12),
                    in: Capsule()
                )
        }
    }

    private var accessibilityStatus: String {
        if isCompleted {
            return
                "Reached. \(milestone.summary)"
        }

        if isNext {
            if let progress {
                return
                    "Next milestone. \(Int((min(max(progress, 0), 1) * 100).rounded())) percent complete. \(milestone.summary)"
            }

            return
                "Next milestone. \(milestone.summary)"
        }

        return
            "Upcoming milestone. \(milestone.summary)"
    }
}
