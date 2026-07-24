import SwiftUI
import SwiftData
import Charts

private struct DailyCravingSummary:
    Identifiable {
    let date: Date
    let total: Int
    let defeated: Int

    var id: Date {
        date
    }
}

struct InsightsView: View {
    @Query(
        sort: \CravingEntry.createdAt
    )
    private var cravings:
        [CravingEntry]

    private var defeatedCount: Int {
        cravings.filter {
            $0.outcome == .defeated
        }
        .count
    }

    private var successRate: Int {
        guard !cravings.isEmpty else {
            return 0
        }

        return Int(
            (
                Double(defeatedCount)
                / Double(cravings.count)
                * 100
            )
            .rounded()
        )
    }

    private var mostCommonTrigger:
        String {
        let grouped = Dictionary(
            grouping: cravings,
            by: \.trigger
        )

        return grouped.max(
            by: {
                $0.value.count
                    < $1.value.count
            }
        )?.key ?? "No data"
    }

    private var dailySummaries:
        [DailyCravingSummary] {
        let calendar =
            Calendar.current

        let today =
            calendar.startOfDay(
                for: .now
            )

        return (0..<7)
            .reversed()
            .compactMap { offset in
                guard
                    let date =
                        calendar.date(
                            byAdding: .day,
                            value: -offset,
                            to: today
                        ),
                    let nextDate =
                        calendar.date(
                            byAdding: .day,
                            value: 1,
                            to: date
                        )
                else {
                    return nil
                }

                let entries =
                    cravings.filter {
                        $0.createdAt
                            >= date
                        && $0.createdAt
                            < nextDate
                    }

                return DailyCravingSummary(
                    date: date,
                    total:
                        entries.count,
                    defeated:
                        entries.filter {
                            $0.outcome
                                == .defeated
                        }
                        .count
                )
            }
    }

    private var triggerBreakdown:
        [(name: String, count: Int)] {
        Dictionary(
            grouping: cravings,
            by: \.trigger
        )
        .map {
            (
                name: $0.key,
                count: $0.value.count
            )
        }
        .sorted { lhs, rhs in
            if lhs.count == rhs.count {
                return lhs.name < rhs.name
            }

            return lhs.count > rhs.count
        }
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
                                "Pattern intelligence",
                            title:
                                "Know what pulls you."
                        )

                        statGrid
                        weeklyChart
                        triggerSection
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
    }

    private var statGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .flexible(),
                    spacing: 12
                ),
                GridItem(
                    .flexible(),
                    spacing: 12
                )
            ],
            spacing: 12
        ) {
            InsightStat(
                value:
                    "\(cravings.count)",
                label:
                    "Cravings logged",
                icon:
                    "waveform"
            )

            InsightStat(
                value:
                    "\(successRate)%",
                label:
                    "Defeat rate",
                icon:
                    "checkmark.shield"
            )

            InsightStat(
                value:
                    "\(defeatedCount)",
                label:
                    "Total wins",
                icon:
                    "trophy"
            )

            InsightStat(
                value:
                    mostCommonTrigger,
                label:
                    "Top trigger",
                icon:
                    "scope"
            )
        }
    }

    private var weeklyChart: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            HStack {
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(
                        "LAST SEVEN DAYS"
                    )
                    .font(
                        .system(
                            size: 11,
                            weight: .bold
                        )
                    )
                    .tracking(1.6)
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                    Text(
                        "Craving frequency"
                    )
                    .font(
                        .system(
                            size: 22,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                }

                Spacer()

                Text(
                    """
                    \(dailySummaries.reduce(0) { $0 + $1.total }) events
                    """
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

            Chart(
                dailySummaries
            ) { summary in
                BarMark(
                    x: .value(
                        "Day",
                        summary.date,
                        unit: .day
                    ),
                    y: .value(
                        "Cravings",
                        summary.total
                    )
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            BuiltTheme.accent,
                            BuiltTheme
                                .accentSoft
                        ],
                        startPoint:
                            .bottom,
                        endPoint:
                            .top
                    )
                )
                .cornerRadius(6)
            }
            .frame(height: 220)
            .chartYAxis {
                AxisMarks(
                    position: .leading
                ) { _ in
                    AxisGridLine()
                        .foregroundStyle(
                            Color.white
                                .opacity(
                                    0.08
                                )
                        )

                    AxisValueLabel()
                        .foregroundStyle(
                            BuiltTheme
                                .textSecondary
                        )
                }
            }
            .chartXAxis {
                AxisMarks(
                    values:
                        .stride(
                            by: .day
                        )
                ) { _ in
                    AxisValueLabel(
                        format:
                            .dateTime
                            .weekday(
                                .narrow
                            )
                    )
                    .foregroundStyle(
                        BuiltTheme
                            .textSecondary
                    )
                }
            }
        }
        .builtCard(padding: 20)
    }

    private var triggerSection: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            SectionHeader(
                eyebrow:
                    "Trigger map",
                title:
                    "What starts the urge"
            )

            if triggerBreakdown.isEmpty {
                VStack(spacing: 12) {
                    Image(
                        systemName:
                            "scope"
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
                        """
                        Your patterns will appear here
                        """
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
                        Use Rescue whenever a craving appears. Even a few entries can make repeated triggers easier to see.
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
                        Array(
                            triggerBreakdown
                                .enumerated()
                        ),
                        id: \.element.name
                    ) { index, item in
                        HStack(spacing: 14) {
                            Text(
                                String(
                                    format:
                                        "%02d",
                                    index + 1
                                )
                            )
                            .font(
                                .system(
                                    size: 11,
                                    weight: .bold,
                                    design:
                                        .monospaced
                                )
                            )
                            .foregroundStyle(
                                BuiltTheme.accent
                            )

                            Text(item.name)
                                .font(
                                    .system(
                                        size: 16,
                                        weight:
                                            .semibold
                                    )
                                )
                                .foregroundStyle(
                                    BuiltTheme
                                        .textPrimary
                                )

                            Spacer()

                            Text(
                                "\(item.count)"
                            )
                            .font(
                                .system(
                                    size: 17,
                                    weight: .bold,
                                    design:
                                        .rounded
                                )
                            )
                            .foregroundStyle(
                                BuiltTheme
                                    .textPrimary
                            )
                        }
                        .builtCard(
                            padding: 15
                        )
                    }
                }
            }
        }
    }
}

private struct InsightStat: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
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

            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text(value)
                    .font(
                        .system(
                            size: 25,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(
                        0.55
                    )

                Text(label)
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
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 126,
            alignment: .leading
        )
        .builtCard(padding: 17)
    }
}
