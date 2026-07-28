import SwiftUI

struct RewardGoalCard: View {
    let goal: RewardGoal
    let totalSaved: Double
    let currencyCode: String
    let onAddContribution: () -> Void
    let onActivate: () -> Void
    let onPause: () -> Void
    let onClaim: () -> Void
    let onDelete: () -> Void

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @ScaledMetric(relativeTo: .body)
    private var iconSize: CGFloat = 50

    private var progress:
        RewardGoalProgress {
        RewardMetrics.progress(
            for: goal,
            totalSaved: totalSaved
        )
    }

    private var normalizedCurrencyCode:
        String {
        let cleaned = currencyCode
            .uppercased()
            .filter(\.isLetter)

        return cleaned.count == 3
            ? cleaned
            : "USD"
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.large
        ) {
            header
            progressSection

            if !goal.note
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .isEmpty {
                Text(goal.note)
                    .font(.subheadline)
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            actionArea
        }
        .builtCard(padding: 18)
        .accessibilityElement(
            children: .contain
        )
    }

    private var header: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    HStack {
                        rewardIcon
                        Spacer()
                        menu
                    }

                    titleBlock
                }
            } else {
                HStack(
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    rewardIcon
                    titleBlock
                    Spacer()
                    menu
                }
            }
        }
    }

    private var rewardIcon: some View {
        Image(systemName: goal.iconName)
            .font(
                .title3
                .weight(.semibold)
            )
            .foregroundStyle(
                goal.completedAt == nil
                ? BuiltTheme.accent
                : Color.black
            )
            .frame(
                width: iconSize,
                height: iconSize
            )
            .background(
                goal.completedAt == nil
                ? BuiltTheme.accent
                    .opacity(0.12)
                : BuiltTheme.accent,
                in: Circle()
            )
            .accessibilityHidden(true)
    }

    private var titleBlock: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.xSmall
        ) {
            Text(goal.title)
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

            statusLabel
        }
    }

    private var menu: some View {
        Menu {
            if goal.completedAt == nil {
                if goal.isActive {
                    Button {
                        onPause()
                    } label: {
                        Label(
                            "Pause automatic progress",
                            systemImage: "pause"
                        )
                    }
                } else {
                    Button {
                        onActivate()
                    } label: {
                        Label(
                            "Make active goal",
                            systemImage: "play"
                        )
                    }
                }

                Button {
                    onAddContribution()
                } label: {
                    Label(
                        "Add contribution",
                        systemImage: "plus"
                    )
                }
            }

            Button(
                role: .destructive
            ) {
                onDelete()
            } label: {
                Label(
                    "Delete goal",
                    systemImage: "trash"
                )
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(
                    .body
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
                .frame(
                    width:
                        BuiltTheme
                            .minimumTapTarget,
                    height:
                        BuiltTheme
                            .minimumTapTarget
                )
                .background(
                    BuiltTheme.elevatedStrong,
                    in: Circle()
                )
        }
        .accessibilityLabel(
            "More actions for \(goal.title)"
        )
    }

    @ViewBuilder
    private var statusLabel: some View {
        if goal.claimedAt != nil {
            badge(
                "REWARD CLAIMED",
                accent: true
            )
        } else if goal.completedAt != nil {
            badge(
                "UNLOCKED",
                accent: true
            )
        } else if goal.isActive {
            HStack(spacing: 7) {
                Circle()
                    .fill(
                        BuiltTheme.accent
                    )
                    .frame(
                        width: 7,
                        height: 7
                    )
                    .accessibilityHidden(true)

                Text(
                    goal.usesAutomaticSavings
                    ? "ACTIVE · AUTO-TRACKING"
                    : "ACTIVE · MANUAL"
                )
            }
            .font(
                .caption2
                .weight(.bold)
            )
            .tracking(0.7)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        } else {
            badge(
                "PAUSED",
                accent: false
            )
        }
    }

    private func badge(
        _ text: String,
        accent: Bool
    ) -> some View {
        Text(text)
            .font(
                .caption2
                .weight(.bold)
            )
            .tracking(0.8)
            .foregroundStyle(
                accent
                ? BuiltTheme.accent
                : BuiltTheme
                    .textSecondary
            )
    }

    private var progressSection: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.small
        ) {
            HStack(
                alignment: .firstTextBaseline
            ) {
                Text(
                    formatted(
                        progress.currentAmount
                    )
                )
                .font(
                    .title2
                    .weight(.bold)
                    .monospacedDigit()
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

                Spacer()

                Text(
                    "of \(formatted(progress.targetAmount))"
                )
                .font(
                    .subheadline
                    .weight(.medium)
                )
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
            }

            ProgressView(
                value: progress.fraction
            )
            .tint(BuiltTheme.accent)
            .accessibilityLabel(
                "\(goal.title) progress"
            )
            .accessibilityValue(
                "\(Int((progress.fraction * 100).rounded())) percent"
            )

            HStack {
                Text(
                    "\(Int((progress.fraction * 100).rounded()))% complete"
                )

                Spacer()

                Text(
                    progress.isComplete
                    ? "Ready"
                    : "\(formatted(progress.remainingAmount)) remaining"
                )
            }
            .font(.caption)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
        .accessibilityElement(
            children: .combine
        )
    }

    @ViewBuilder
    private var actionArea: some View {
        if goal.completedAt != nil,
           goal.claimedAt == nil {
            Button {
                onClaim()
            } label: {
                HStack {
                    Text(
                        "Mark reward as claimed"
                    )
                    Spacer()
                    Image(
                        systemName:
                            "checkmark"
                    )
                    .accessibilityHidden(true)
                }
            }
            .buttonStyle(
                BuiltPrimaryButtonStyle()
            )
        } else if goal.completedAt == nil {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 4) {
                    contributionButton
                    activeStateButton
                }
            } else {
                HStack(spacing: 10) {
                    contributionButton
                    activeStateButton
                }
            }
        }
    }

    private var contributionButton: some View {
        Button {
            onAddContribution()
        } label: {
            Label(
                "Add money",
                systemImage: "plus"
            )
        }
        .buttonStyle(
            BuiltSecondaryButtonStyle()
        )
    }

    private var activeStateButton: some View {
        Button {
            if goal.isActive {
                onPause()
            } else {
                onActivate()
            }
        } label: {
            Label(
                goal.isActive
                ? "Pause"
                : "Activate",
                systemImage:
                    goal.isActive
                    ? "pause"
                    : "play"
            )
        }
        .buttonStyle(
            BuiltSecondaryButtonStyle()
        )
    }

    private func formatted(
        _ amount: Double
    ) -> String {
        amount.formatted(
            .currency(
                code:
                    normalizedCurrencyCode
            )
            .precision(
                .fractionLength(0...2)
            )
        )
    }
}
