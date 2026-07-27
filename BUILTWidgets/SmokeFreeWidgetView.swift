import SwiftUI
import WidgetKit

struct SmokeFreeWidgetView: View {
    let entry: SmokeFreeEntry

    @Environment(\.widgetFamily)
    private var family

    private let accent = Color(
        red: 0.64,
        green: 1.00,
        blue: 0.62
    )

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallView
            case .systemMedium:
                mediumView
            case .accessoryCircular:
                circularView
            case .accessoryRectangular:
                rectangularView
            case .accessoryInline:
                inlineView
            default:
                smallView
            }
        }
    }

    private var smallView: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {
            HStack {
                Text("BUILT.")
                    .font(
                        .system(
                            size: 13,
                            weight: .black
                        )
                    )
                    .tracking(1.4)

                Spacer()

                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(accent)
                    .widgetAccentable()
            }

            Spacer()

            Text("SMOKE-FREE")
                .font(
                    .system(
                        size: 9,
                        weight: .bold
                    )
                )
                .tracking(1.4)
                .foregroundStyle(accent)
                .widgetAccentable()

            Text(entry.snapshot.quitDate, style: .timer)
                .font(
                    .system(
                        size: 27,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .contentTransition(.numericText())

            Text(
                "\(entry.snapshot.cigarettesAvoided(at: entry.date)) rejected"
            )
            .font(
                .system(
                    size: 11,
                    weight: .semibold
                )
            )
            .foregroundStyle(.secondary)
            .padding(.top, 5)
        }
        .padding(2)
    }

    private var mediumView: some View {
        HStack(spacing: 18) {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {
                HStack(spacing: 8) {
                    Text("BUILT.")
                        .font(
                            .system(
                                size: 14,
                                weight: .black
                            )
                        )
                        .tracking(1.5)

                    Text("BUILT, NOT BURNED")
                        .font(
                            .system(
                                size: 8,
                                weight: .bold
                            )
                        )
                        .tracking(1.1)
                        .foregroundStyle(accent)
                        .widgetAccentable()
                }

                Spacer()

                Text("SMOKE-FREE")
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .tracking(1.6)
                    .foregroundStyle(accent)
                    .widgetAccentable()

                Text(entry.snapshot.quitDate, style: .timer)
                    .font(
                        .system(
                            size: 30,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
                    .contentTransition(.numericText())

                mediumMotivationContent
                    .padding(.top, 6)
            }

            VStack(spacing: 10) {
                metricPill(
                    icon: "nosign",
                    value: "\(entry.snapshot.cigarettesAvoided(at: entry.date))",
                    label: "rejected"
                )

                metricPill(
                    icon: "banknote.fill",
                    value: entry.snapshot.formattedMoney(at: entry.date),
                    label: "protected"
                )

                Link(destination: BuiltSharedConstants.rescueURL) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.heart.fill")
                        Text("RESCUE")
                    }
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(
                        accent,
                        in: Capsule()
                    )
                }
            }
            .frame(width: 108)
        }
        .padding(2)
    }


    @ViewBuilder
    private var mediumMotivationContent: some View {
        if entry.snapshot.hasActiveReward,
           let title = entry.snapshot.activeRewardTitle {
            Link(destination: BuiltSharedConstants.rewardsURL) {
                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    HStack(spacing: 5) {
                        Image(
                            systemName: entry.snapshot.activeRewardIconName
                                ?? "gift.fill"
                        )
                        .font(
                            .system(
                                size: 9,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(accent)
                        .widgetAccentable()

                        Text(title.uppercased())
                            .font(
                                .system(
                                    size: 8,
                                    weight: .bold
                                )
                            )
                            .tracking(0.8)
                            .lineLimit(1)
                    }

                    ProgressView(
                        value: entry.snapshot.activeRewardProgress(at: entry.date)
                    )
                    .tint(accent)

                    if let current = entry.snapshot.formattedActiveRewardCurrent(at: entry.date),
                       let target = entry.snapshot.formattedActiveRewardTarget {
                        Text("\(current) of \(target)")
                            .font(
                                .system(
                                    size: 8,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                }
            }
        } else {
            Text(entry.snapshot.identityStatement)
                .font(
                    .system(
                        size: 10,
                        weight: .medium
                    )
                )
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }

    private func metricPill(
        icon: String,
        value: String,
        label: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 3
        ) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(accent)
                    .widgetAccentable()

                Text(value)
                    .font(
                        .system(
                            size: 12,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Text(label)
                .font(
                    .system(
                        size: 8,
                        weight: .medium
                    )
                )
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            Color.white.opacity(0.08),
            in: RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
        )
    }

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 0) {
                Text("\(entry.snapshot.fullDays(at: entry.date))")
                    .font(
                        .system(
                            size: 22,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .minimumScaleFactor(0.65)

                Text("DAYS")
                    .font(
                        .system(
                            size: 8,
                            weight: .bold
                        )
                    )
                    .tracking(0.8)
            }
        }
        .widgetAccentable()
    }

    private var rectangularView: some View {
        VStack(
            alignment: .leading,
            spacing: 3
        ) {
            Text("BUILT, NOT BURNED")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )

            Text(entry.snapshot.quitDate, style: .timer)
                .font(
                    .system(
                        size: 17,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(
                "\(entry.snapshot.cigarettesAvoided(at: entry.date)) cigarettes rejected"
            )
            .font(.system(size: 10, weight: .medium))
            .lineLimit(1)
        }
        .widgetAccentable()
    }

    private var inlineView: some View {
        Text(
            "BUILT · \(entry.snapshot.compactElapsedText(at: entry.date)) smoke-free"
        )
    }
}
