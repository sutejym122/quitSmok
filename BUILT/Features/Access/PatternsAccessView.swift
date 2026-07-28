import SwiftData
import SwiftUI

struct PatternsAccessView: View {
    @EnvironmentObject
    private var storeManager: StoreManager

    var body: some View {
        if storeManager.hasPro {
            InsightsView()
        } else {
            FreePatternsView()
        }
    }
}

private struct FreePatternsView: View {
    @EnvironmentObject
    private var storeManager: StoreManager

    @Query(
        sort: \CravingEntry.createdAt
    )
    private var cravings: [CravingEntry]

    @State private var showingPaywall = false

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

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 24
                    ) {
                        SectionHeader(
                            eyebrow:
                                "Pattern intelligence",
                            title:
                                "Make the urge visible."
                        )

                        if cravings.isEmpty {
                            emptyState
                        } else {
                            summaryGrid
                            promiseCard
                        }

                        UpgradeCard(
                            title:
                                "Reveal the complete pattern",
                            message:
                                "Unlock seven-day craving trends, trigger rankings, intensity analysis, and the replacement actions that help most.",
                            action: {
                                showingPaywall = true
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 38)
                }
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(context: .patterns)
                .environmentObject(storeManager)
        }
    }

    private var summaryGrid: some View {
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
            FreePatternMetric(
                icon: "waveform",
                value: "\(cravings.count)",
                title: "Cravings logged"
            )

            FreePatternMetric(
                icon: "checkmark.shield.fill",
                value: "\(successRate)%",
                title: "Defeat rate"
            )
        }
    }

    private var promiseCard: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text("WHAT STAYS FREE")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .tracking(1.5)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(
                "Every craving you record remains yours. BUILT never hides or deletes your history when you stay on the free tier."
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
                "Pro adds analysis. It does not take away your data or the ability to use Rescue."
            )
            .font(.system(size: 13))
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 20)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "scope")
                .font(
                    .system(
                        size: 38,
                        weight: .light
                    )
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text("Your pattern starts with one entry")
                .font(
                    .system(
                        size: 21,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            Text(
                "Use Rescue when an urge appears. Basic logging and your full history remain free."
            )
            .font(.system(size: 14))
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .multilineTextAlignment(.center)
        }
        .frame(
            maxWidth: .infinity
        )
        .builtCard(padding: 26)
    }
}

private struct FreePatternMetric: View {
    let icon: String
    let value: String
    let title: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Image(systemName: icon)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(value)
                .font(
                    .system(
                        size: 28,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            Text(title)
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
        .frame(
            maxWidth: .infinity,
            minHeight: 126,
            alignment: .leading
        )
        .builtCard(padding: 17)
    }
}
