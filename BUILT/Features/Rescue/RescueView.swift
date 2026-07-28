import SwiftUI
import SwiftData

struct RescueView: View {
    let profile: QuitProfile

    @Query(
        sort: \CravingEntry.createdAt,
        order: .reverse
    )
    private var cravings: [CravingEntry]

    @State private var showingSession =
        false

    private var defeatedCount: Int {
        cravings.filter {
            $0.outcome == .defeated
        }
        .count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing:
                            BuiltTheme.Spacing
                                .xLarge
                    ) {
                        SectionHeader(
                            eyebrow:
                                "Craving rescue",
                            title:
                                "Break the moment."
                        )

                        BuiltHeroPanel(
                            eyebrow:
                                "A wave, not a command",
                            title:
                                "You do not have to obey this urge.",
                            message:
                                profile.identityStatement,
                            systemName:
                                "waveform.path.ecg",
                            trailingValue:
                                "\(defeatedCount)",
                            trailingLabel:
                                "Wins logged"
                        )

                        startButton
                        historySection
                    }
                    .padding(
                        .horizontal,
                        BuiltTheme.Spacing
                            .screenHorizontal
                    )
                    .padding(.top, 18)
                    .padding(.bottom, 38)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .fullScreenCover(
            isPresented:
                $showingSession
        ) {
            CravingSessionView(
                profile: profile
            )
        }
    }

    private var startButton: some View {
        Button {
            showingSession = true
        } label: {
            HStack(spacing: 12) {
                Image(
                    systemName:
                        "play.fill"
                )
                .accessibilityHidden(true)

                Text(
                    "Start a 60-second rescue"
                )

                Spacer()

                Image(
                    systemName:
                        "arrow.right"
                )
                .accessibilityHidden(true)
            }
        }
        .buttonStyle(
            BuiltPrimaryButtonStyle()
        )
        .accessibilityHint(
            "Starts breathing guidance and your personalized replacement actions"
        )
    }

    private var historySection: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            SectionHeader(
                eyebrow: "Evidence",
                title: "Recent cravings",
                trailingText:
                    cravings.isEmpty
                    ? nil
                    : "\(cravings.count) total"
            )

            if cravings.isEmpty {
                BuiltEmptyState(
                    systemName:
                        "checkmark.shield",
                    title:
                        "No cravings logged yet",
                    message:
                        "When one arrives, use Rescue. Logging the trigger turns an urge into a pattern you can understand.",
                    actionTitle:
                        "Start Rescue",
                    action: {
                        showingSession = true
                    }
                )
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(
                        cravings.prefix(8)
                    ) { craving in
                        CravingRow(
                            craving: craving
                        )
                    }
                }
            }
        }
    }
}

private struct CravingRow: View {
    let craving: CravingEntry

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    private var isDefeated: Bool {
        craving.outcome == .defeated
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    rowHeader
                    rowDetails
                }
            } else {
                HStack(
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    outcomeIcon
                    rowDetails
                    Spacer()
                    dateLabel
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 15)
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            "\(isDefeated ? "Craving defeated" : "Slip recorded"). Trigger: \(craving.trigger)."
        )
        .accessibilityValue(
            "Intensity \(craving.intensity) out of 10. Action: \(craving.replacementAction). \(craving.createdAt.formatted(date: .abbreviated, time: .omitted))."
        )
    }

    private var rowHeader: some View {
        HStack(
            spacing: BuiltTheme.Spacing.medium
        ) {
            outcomeIcon
            Spacer()
            dateLabel
        }
    }

    private var outcomeIcon: some View {
        Image(
            systemName:
                isDefeated
                ? "checkmark"
                : "arrow.counterclockwise"
        )
        .font(
            .body
            .weight(.bold)
        )
        .foregroundStyle(
            isDefeated
            ? BuiltTheme.accent
            : BuiltTheme.danger
        )
        .frame(
            width: 40,
            height: 40
        )
        .background(
            (
                isDefeated
                ? BuiltTheme.accent
                : BuiltTheme.danger
            )
            .opacity(0.11),
            in: Circle()
        )
        .accessibilityHidden(true)
    }

    private var rowDetails: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.xSmall
        ) {
            Text(craving.trigger)
                .font(
                    .headline
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            Text(
                "Intensity \(craving.intensity)/10 · \(craving.replacementAction)"
            )
            .font(.caption)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
    }

    private var dateLabel: some View {
        Text(
            craving.createdAt,
            format:
                .dateTime
                .month(.abbreviated)
                .day()
        )
        .font(
            .caption
            .weight(.medium)
        )
        .foregroundStyle(
            BuiltTheme.textSecondary
        )
    }
}
