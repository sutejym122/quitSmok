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

    private var progress: RewardGoalProgress {
        RewardMetrics.progress(
            for: goal,
            totalSaved: totalSaved
        )
    }

    private var normalizedCurrencyCode: String {
        let cleaned = currencyCode
            .uppercased()
            .filter(\.isLetter)

        return cleaned.count == 3 ? cleaned : "USD"
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            header
            progressSection

            if !goal.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(goal.note)
                    .font(.system(size: 13))
                    .foregroundStyle(BuiltTheme.textSecondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            actionRow
        }
        .builtCard(padding: 18)
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: goal.iconName)
                .font(
                    .system(
                        size: 20,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    goal.completedAt == nil
                        ? BuiltTheme.accent
                        : Color.black
                )
                .frame(width: 48, height: 48)
                .background(
                    goal.completedAt == nil
                        ? BuiltTheme.accent.opacity(0.12)
                        : BuiltTheme.accent,
                    in: Circle()
                )

            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text(goal.title)
                    .font(
                        .system(
                            size: 19,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(BuiltTheme.textPrimary)
                    .lineLimit(2)

                statusLabel
            }

            Spacer()

            Menu {
                if goal.completedAt == nil {
                    if goal.isActive {
                        Button {
                            onPause()
                        } label: {
                            Label("Pause automatic progress", systemImage: "pause")
                        }
                    } else {
                        Button {
                            onActivate()
                        } label: {
                            Label("Make active goal", systemImage: "play")
                        }
                    }

                    Button {
                        onAddContribution()
                    } label: {
                        Label("Add contribution", systemImage: "plus")
                    }
                }

                Button(
                    role: .destructive
                ) {
                    onDelete()
                } label: {
                    Label("Delete goal", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(BuiltTheme.textSecondary)
                    .frame(width: 38, height: 38)
                    .background(
                        Color.white.opacity(0.06),
                        in: Circle()
                    )
            }
        }
    }

    @ViewBuilder
    private var statusLabel: some View {
        if goal.claimedAt != nil {
            Text("REWARD CLAIMED")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .tracking(1.2)
                .foregroundStyle(BuiltTheme.accent)
        } else if goal.completedAt != nil {
            Text("UNLOCKED")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .tracking(1.2)
                .foregroundStyle(BuiltTheme.accent)
        } else if goal.isActive {
            HStack(spacing: 6) {
                Circle()
                    .fill(BuiltTheme.accent)
                    .frame(width: 6, height: 6)

                Text(
                    goal.usesAutomaticSavings
                        ? "ACTIVE · AUTO-TRACKING"
                        : "ACTIVE · MANUAL"
                )
            }
            .font(
                .system(
                    size: 10,
                    weight: .bold
                )
            )
            .tracking(0.9)
            .foregroundStyle(BuiltTheme.textSecondary)
        } else {
            Text("PAUSED")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .tracking(1.1)
                .foregroundStyle(BuiltTheme.textSecondary)
        }
    }

    private var progressSection: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            HStack(
                alignment: .firstTextBaseline
            ) {
                Text(
                    progress.currentAmount.formatted(
                        .currency(code: normalizedCurrencyCode)
                        .precision(.fractionLength(0...2))
                    )
                )
                .font(
                    .system(
                        size: 26,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(BuiltTheme.textPrimary)

                Text(
                    "of \(progress.targetAmount.formatted(.currency(code: normalizedCurrencyCode).precision(.fractionLength(0...2))))"
                )
                .font(
                    .system(
                        size: 12,
                        weight: .medium
                    )
                )
                .foregroundStyle(BuiltTheme.textSecondary)

                Spacer()

                Text("\(Int((progress.fraction * 100).rounded()))%")
                    .font(
                        .system(
                            size: 14,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(BuiltTheme.accent)
            }

            ProgressView(value: progress.fraction)
                .tint(BuiltTheme.accent)
                .background(
                    Color.white.opacity(0.08),
                    in: Capsule()
                )

            if goal.completedAt == nil {
                Text(
                    "\(progress.remainingAmount.formatted(.currency(code: normalizedCurrencyCode).precision(.fractionLength(0...2)))) left to unlock"
                )
                .font(.system(size: 12))
                .foregroundStyle(BuiltTheme.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var actionRow: some View {
        if goal.completedAt != nil && goal.claimedAt == nil {
            Button {
                onClaim()
            } label: {
                HStack {
                    Image(systemName: "gift.fill")
                    Text("Mark reward as claimed")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(BuiltPrimaryButtonStyle())
        } else if goal.completedAt == nil {
            HStack(spacing: 10) {
                Button {
                    onAddContribution()
                } label: {
                    Label("Add", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BuiltSecondaryButtonStyle())

                Button {
                    if goal.isActive {
                        onPause()
                    } else {
                        onActivate()
                    }
                } label: {
                    Label(
                        goal.isActive ? "Pause" : "Activate",
                        systemImage: goal.isActive ? "pause.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BuiltSecondaryButtonStyle())
            }
        }
    }
}
