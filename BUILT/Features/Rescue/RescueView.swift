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
                        spacing: 26
                    ) {
                        SectionHeader(
                            eyebrow:
                                "Craving rescue",
                            title:
                                "Break the moment."
                        )

                        rescueHero
                        startButton
                        historySection
                    }
                    .padding(
                        .horizontal,
                        20
                    )
                    .padding(.top, 18)
                    .padding(
                        .bottom,
                        36
                    )
                }
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

    private var rescueHero: some View {
        VStack(
            alignment: .leading,
            spacing: 22
        ) {
            HStack {
                Image(
                    systemName:
                        "waveform.path.ecg"
                )
                .font(
                    .system(
                        size: 26,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(
                    width: 56,
                    height: 56
                )
                .background(
                    BuiltTheme.accent
                        .opacity(0.12),
                    in: Circle()
                )

                Spacer()

                VStack(
                    alignment: .trailing,
                    spacing: 3
                ) {
                    Text(
                        "\(defeatedCount)"
                    )
                    .font(
                        .system(
                            size: 32,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                    Text("WINS LOGGED")
                        .font(
                            .system(
                                size: 10,
                                weight: .bold
                            )
                        )
                        .tracking(1.2)
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                }
            }

            Text(
                """
                A craving is a wave,
                not a command.
                """
            )
            .font(
                .system(
                    size: 36,
                    weight: .bold
                )
            )
            .tracking(-1.2)
            .foregroundStyle(
                BuiltTheme.textPrimary
            )

            Text(
                profile.identityStatement
            )
            .font(
                .system(
                    size: 17,
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
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 24)
    }

    private var startButton: some View {
        Button {
            showingSession = true
        } label: {
            HStack {
                Image(
                    systemName: "play.fill"
                )

                Text(
                    "Start a 60-second rescue"
                )

                Spacer()

                Image(
                    systemName:
                        "arrow.right"
                )
            }
        }
        .buttonStyle(
            BuiltPrimaryButtonStyle()
        )
    }

    private var historySection: some View {
        VStack(
            alignment: .leading,
            spacing: 16
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
                VStack(spacing: 14) {
                    Image(
                        systemName:
                            "checkmark.shield"
                    )
                    .font(
                        .system(
                            size: 34,
                            weight: .light
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                    Text(
                        "No cravings logged yet"
                    )
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                    Text(
                        """
                        When one arrives, use Rescue. Logging the trigger helps reveal your pattern.
                        """
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                    .multilineTextAlignment(
                        .center
                    )
                }
                .frame(
                    maxWidth: .infinity
                )
                .builtCard(padding: 26)
            } else {
                VStack(spacing: 10) {
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

    var body: some View {
        HStack(spacing: 14) {
            Image(
                systemName:
                    craving.outcome
                        == .defeated
                    ? "checkmark"
                    : "arrow.counterclockwise"
            )
            .font(
                .system(
                    size: 15,
                    weight: .bold
                )
            )
            .foregroundStyle(
                craving.outcome
                    == .defeated
                ? BuiltTheme.accent
                : BuiltTheme.danger
            )
            .frame(
                width: 38,
                height: 38
            )
            .background(
                (
                    craving.outcome
                        == .defeated
                    ? BuiltTheme.accent
                    : BuiltTheme.danger
                )
                .opacity(0.11),
                in: Circle()
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(craving.trigger)
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                Text(
                    """
                    Intensity \(craving.intensity)/10 · \(craving.replacementAction)
                    """
                )
                .font(.system(size: 12))
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
                .lineLimit(1)
            }

            Spacer()

            Text(
                craving.createdAt,
                format:
                    .dateTime
                    .month(.abbreviated)
                    .day()
            )
            .font(
                .system(
                    size: 12,
                    weight: .medium
                )
            )
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
        .builtCard(padding: 14)
    }
}
