import SwiftUI

struct OnboardingProgressHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let canGoBack: Bool
    let onBack: () -> Void

    private var progress: Double {
        guard totalSteps > 1 else {
            return 1
        }

        return Double(currentStep)
            / Double(totalSteps - 1)
    }

    var body: some View {
        HStack(spacing: 14) {
            Button {
                onBack()
            } label: {
                Image(
                    systemName: "chevron.left"
                )
                .font(
                    .system(
                        size: 15,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .frame(
                    width: 42,
                    height: 42
                )
                .background(
                    .ultraThinMaterial,
                    in: Circle()
                )
                .overlay {
                    Circle()
                        .stroke(
                            BuiltTheme.hairline,
                            lineWidth: 1
                        )
                }
            }
            .disabled(!canGoBack)
            .opacity(canGoBack ? 1 : 0)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            Color.white.opacity(0.09)
                        )

                    Capsule()
                        .fill(BuiltTheme.accent)
                        .frame(
                            width:
                                proxy.size.width
                                * min(max(progress, 0), 1)
                        )
                }
            }
            .frame(height: 5)

            Text(
                "\(currentStep + 1)/\(totalSteps)"
            )
            .font(
                .system(
                    size: 11,
                    weight: .bold,
                    design: .monospaced
                )
            )
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .frame(width: 38)
        }
    }
}

struct OnboardingTitleBlock: View {
    let eyebrow: String
    let title: String
    let message: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 13
        ) {
            Text(eyebrow.uppercased())
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1.9)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(title)
                .font(
                    .system(
                        size: 39,
                        weight: .bold
                    )
                )
                .tracking(-1.35)
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text(message)
                .font(
                    .system(
                        size: 16,
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
    }
}

struct OnboardingSelectionCard: View {
    let title: String
    let detail: String?
    let symbolName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 15) {
                Image(systemName: symbolName)
                    .font(
                        .system(
                            size: 19,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        isSelected
                        ? Color.black
                        : BuiltTheme.accent
                    )
                    .frame(
                        width: 44,
                        height: 44
                    )
                    .background(
                        isSelected
                        ? Color.black.opacity(0.10)
                        : BuiltTheme.accent.opacity(0.10),
                        in: Circle()
                    )

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(title)
                        .font(
                            .system(
                                size: 16,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            isSelected
                            ? Color.black
                            : BuiltTheme.textPrimary
                        )

                    if let detail {
                        Text(detail)
                            .font(
                                .system(
                                    size: 12,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(
                                isSelected
                                ? Color.black.opacity(0.65)
                                : BuiltTheme.textSecondary
                            )
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    }
                }

                Spacer()

                Image(
                    systemName:
                        isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(
                    .system(
                        size: 20,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    isSelected
                    ? Color.black
                    : BuiltTheme.textSecondary
                )
            }
            .padding(16)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                isSelected
                ? BuiltTheme.accent
                : Color.white.opacity(0.065),
                in: RoundedRectangle(
                    cornerRadius: 21,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: 21,
                    style: .continuous
                )
                .stroke(
                    isSelected
                    ? Color.clear
                    : BuiltTheme.hairline,
                    lineWidth: 1
                )
            }
        }
        .buttonStyle(.plain)
    }
}

struct OnboardingChip: View {
    let title: String
    let symbolName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: symbolName)
                Text(title)
            }
            .font(
                .system(
                    size: 13,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                isSelected
                ? Color.black
                : BuiltTheme.textPrimary
            )
            .padding(.horizontal, 13)
            .padding(.vertical, 11)
            .background(
                isSelected
                ? BuiltTheme.accent
                : Color.white.opacity(0.07),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .stroke(
                        isSelected
                        ? Color.clear
                        : BuiltTheme.hairline,
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
    }
}

struct OnboardingMetricTile: View {
    let value: String
    let label: String
    let symbolName: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Image(systemName: symbolName)
                .font(
                    .system(
                        size: 17,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(value)
                .font(
                    .system(
                        size: 26,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .lineLimit(1)
                .minimumScaleFactor(0.65)

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
        .frame(
            maxWidth: .infinity,
            minHeight: 132,
            alignment: .leading
        )
        .builtCard(padding: 17)
    }
}
