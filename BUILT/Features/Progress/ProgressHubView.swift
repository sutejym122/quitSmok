import SwiftUI

struct ProgressHubView: View {
    let profile: QuitProfile
    @Binding var selectedSection: GrowthSection

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    var body: some View {
        Group {
            switch selectedSection {
            case .recovery:
                RecoveryAccessView(profile: profile)
                    .transition(
                        reduceMotion
                        ? .opacity
                        : .opacity.combined(
                            with:
                                .move(edge: .trailing)
                        )
                    )

            case .rewards:
                RewardsAccessView(profile: profile)
                    .transition(
                        reduceMotion
                        ? .opacity
                        : .opacity.combined(
                            with:
                                .move(edge: .trailing)
                        )
                    )

            case .patterns:
                PatternsAccessView()
                    .transition(
                        reduceMotion
                        ? .opacity
                        : .opacity.combined(
                            with:
                                .move(edge: .trailing)
                        )
                    )
            }
        }
        .animation(
            reduceMotion
            ? nil
            : BuiltTheme.Motion.standard,
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
        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            HStack(
                spacing: BuiltTheme.Spacing.small
            ) {
                ForEach(
                    GrowthSection.allCases
                ) { section in
                    Button {
                        selectedSection = section
                        Haptics.selection()
                    } label: {
                        Label(
                            section.title,
                            systemImage:
                                section.symbolName
                        )
                        .font(
                            .subheadline
                            .weight(.semibold)
                        )
                        .foregroundStyle(
                            selectedSection
                                == section
                            ? Color.black
                            : BuiltTheme
                                .textPrimary
                        )
                        .padding(
                            .horizontal,
                            dynamicTypeSize
                                .isAccessibilitySize
                            ? 16
                            : 18
                        )
                        .frame(
                            minHeight:
                                BuiltTheme
                                    .minimumTapTarget
                        )
                        .background(
                            selectedSection
                                == section
                            ? BuiltTheme.accent
                            : BuiltTheme.elevated
                                .opacity(0.88),
                            in: Capsule(
                                style: .continuous
                            )
                        )
                        .overlay {
                            Capsule(
                                style: .continuous
                            )
                            .stroke(
                                selectedSection
                                    == section
                                ? Color.clear
                                : BuiltTheme
                                    .hairline,
                                lineWidth: 1
                            )
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(
                        selectedSection
                            == section
                        ? .isSelected
                        : []
                    )
                    .accessibilityHint(
                        "Shows the \(section.title.lowercased()) section"
                    )
                }
            }
            .padding(
                .horizontal,
                BuiltTheme.Spacing
                    .screenHorizontal
            )
            .padding(.vertical, 10)
        }
        .background(
            .ultraThinMaterial
        )
        .overlay(
            alignment: .bottom
        ) {
            Divider()
                .overlay(
                    BuiltTheme.hairline
                )
        }
    }
}
