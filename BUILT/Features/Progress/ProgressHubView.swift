import SwiftUI

struct ProgressHubView: View {
    let profile: QuitProfile
    @Binding var selectedSection: GrowthSection

    var body: some View {
        Group {
            switch selectedSection {
            case .recovery:
                RecoveryAccessView(profile: profile)
                    .transition(.opacity)

            case .rewards:
                RewardsAccessView(profile: profile)
                    .transition(.opacity)

            case .patterns:
                PatternsAccessView()
                    .transition(.opacity)
            }
        }
        .animation(
            .easeInOut(duration: 0.22),
            value: selectedSection
        )
        .safeAreaInset(
            edge: .top,
            spacing: 0
        ) {
            sectionSelector
        }
    }

    private var sectionSelector: some View {
        HStack(spacing: 6) {
            ForEach(GrowthSection.allCases) { section in
                Button {
                    selectedSection = section
                    Haptics.selection()
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: section.symbolName)
                            .font(
                                .system(
                                    size: 12,
                                    weight: .semibold
                                )
                            )

                        Text(section.title)
                            .font(
                                .system(
                                    size: 12,
                                    weight: .semibold
                                )
                            )
                    }
                    .foregroundStyle(
                        selectedSection == section
                            ? Color.black
                            : BuiltTheme.textSecondary
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        selectedSection == section
                            ? BuiltTheme.accent
                            : Color.clear,
                        in: Capsule()
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(
            .ultraThinMaterial,
            in: Capsule()
        )
        .overlay {
            Capsule()
                .stroke(
                    BuiltTheme.hairline,
                    lineWidth: 1
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(
            LinearGradient(
                colors: [
                    BuiltTheme.background,
                    BuiltTheme.background.opacity(0.92),
                    BuiltTheme.background.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
