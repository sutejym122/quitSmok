import SwiftUI

struct PremiumFeatureLock<Content: View>: View {
    let feature: ProFeature
    let isUnlocked: Bool
    let action: () -> Void
    private let content: Content

    init(
        feature: ProFeature,
        isUnlocked: Bool,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.feature = feature
        self.isUnlocked = isUnlocked
        self.action = action
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
                .blur(radius: isUnlocked ? 0 : 8)
                .opacity(isUnlocked ? 1 : 0.42)
                .allowsHitTesting(isUnlocked)
                .accessibilityHidden(!isUnlocked)

            if !isUnlocked {
                VStack(spacing: 14) {
                    Image(systemName: "lock.fill")
                        .font(
                            .system(
                                size: 20,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(BuiltTheme.accent)
                        .frame(width: 46, height: 46)
                        .background(
                            BuiltTheme.accent.opacity(0.13),
                            in: Circle()
                        )

                    VStack(spacing: 6) {
                        Text(feature.title)
                            .font(
                                .system(
                                    size: 18,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(
                                BuiltTheme.textPrimary
                            )

                        Text(feature.detail)
                            .font(.system(size: 13))
                            .foregroundStyle(
                                BuiltTheme.textSecondary
                            )
                            .multilineTextAlignment(.center)
                    }

                    Button("Unlock with BUILT Pro") {
                        action()
                    }
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        BuiltTheme.accent,
                        in: Capsule()
                    )
                }
                .padding(22)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(
                cornerRadius: BuiltTheme.mediumRadius,
                style: .continuous
            )
            .fill(.ultraThinMaterial)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: BuiltTheme.mediumRadius,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: BuiltTheme.mediumRadius,
                style: .continuous
            )
            .stroke(
                BuiltTheme.hairline,
                lineWidth: 1
            )
        }
    }
}
