import SwiftUI

enum BuiltTheme {
    static let background = Color(
        red: 0.025,
        green: 0.027,
        blue: 0.035
    )

    static let elevated = Color(
        red: 0.070,
        green: 0.074,
        blue: 0.090
    )

    static let accent = Color(
        red: 0.64,
        green: 1.00,
        blue: 0.62
    )

    static let accentSoft = Color(
        red: 0.38,
        green: 0.78,
        blue: 1.00
    )

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)
    static let hairline = Color.white.opacity(0.10)

    static let danger = Color(
        red: 1.00,
        green: 0.36,
        blue: 0.34
    )

    static let largeRadius: CGFloat = 30
    static let mediumRadius: CGFloat = 22
    static let smallRadius: CGFloat = 16
}

struct BuiltCardModifier: ViewModifier {
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(
                    cornerRadius: BuiltTheme.mediumRadius,
                    style: .continuous
                )
                .fill(.ultraThinMaterial)
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
}

extension View {
    func builtCard(
        padding: CGFloat = 18
    ) -> some View {
        modifier(
            BuiltCardModifier(
                padding: padding
            )
        )
    }
}

struct BuiltPrimaryButtonStyle: ButtonStyle {
    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .font(
                .system(
                    size: 17,
                    weight: .semibold
                )
            )
            .foregroundStyle(Color.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background {
                Capsule(style: .continuous)
                    .fill(BuiltTheme.accent)
            }
            .scaleEffect(
                configuration.isPressed ? 0.975 : 1
            )
            .opacity(
                configuration.isPressed ? 0.88 : 1
            )
            .animation(
                .spring(
                    response: 0.25,
                    dampingFraction: 0.78
                ),
                value: configuration.isPressed
            )
    }
}

struct BuiltSecondaryButtonStyle: ButtonStyle {
    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .font(
                .system(
                    size: 17,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(
                                BuiltTheme.hairline,
                                lineWidth: 1
                            )
                    }
            }
            .scaleEffect(
                configuration.isPressed ? 0.975 : 1
            )
            .opacity(
                configuration.isPressed ? 0.86 : 1
            )
            .animation(
                .spring(
                    response: 0.25,
                    dampingFraction: 0.78
                ),
                value: configuration.isPressed
            )
    }
}
