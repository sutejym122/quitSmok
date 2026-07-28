import SwiftUI

enum BuiltTheme {
    enum Spacing {
        static let xSmall: CGFloat = 6
        static let small: CGFloat = 10
        static let medium: CGFloat = 16
        static let large: CGFloat = 22
        static let xLarge: CGFloat = 30
        static let screenHorizontal: CGFloat = 20
    }

    enum Radius {
        static let small: CGFloat = 16
        static let medium: CGFloat = 22
        static let large: CGFloat = 30
    }

    enum Motion {
        static let quick = Animation.spring(
            response: 0.24,
            dampingFraction: 0.86
        )

        static let standard = Animation.spring(
            response: 0.38,
            dampingFraction: 0.88
        )
    }

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

    static let elevatedStrong = Color(
        red: 0.105,
        green: 0.110,
        blue: 0.132
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
    static let textSecondary = Color.white.opacity(0.68)
    static let textTertiary = Color.white.opacity(0.50)
    static let hairline = Color.white.opacity(0.12)

    static let danger = Color(
        red: 1.00,
        green: 0.36,
        blue: 0.34
    )

    static let warning = Color(
        red: 1.00,
        green: 0.76,
        blue: 0.28
    )

    static let success = accent

    static let largeRadius = Radius.large
    static let mediumRadius = Radius.medium
    static let smallRadius = Radius.small

    static let minimumTapTarget: CGFloat = 52
}

struct BuiltCardModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency)
    private var reduceTransparency

    let padding: CGFloat
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .fill(
                    reduceTransparency
                    ? BuiltTheme.elevatedStrong
                    : BuiltTheme.elevated.opacity(0.72)
                )
                .background {
                    if !reduceTransparency {
                        RoundedRectangle(
                            cornerRadius: cornerRadius,
                            style: .continuous
                        )
                        .fill(.ultraThinMaterial)
                    }
                }
                .overlay {
                    RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                    .stroke(
                        BuiltTheme.hairline,
                        lineWidth: 1
                    )
                }
                .shadow(
                    color:
                        reduceTransparency
                        ? .clear
                        : .black.opacity(0.16),
                    radius: 18,
                    y: 10
                )
            }
    }
}

extension View {
    func builtCard(
        padding: CGFloat = 18,
        cornerRadius: CGFloat =
            BuiltTheme.mediumRadius
    ) -> some View {
        modifier(
            BuiltCardModifier(
                padding: padding,
                cornerRadius: cornerRadius
            )
        )
    }

    @ViewBuilder
    func builtAnimation<Value: Equatable>(
        _ animation: Animation = BuiltTheme.Motion.standard,
        value: Value
    ) -> some View {
        modifier(
            BuiltAnimationModifier(
                animation: animation,
                value: value
            )
        )
    }
}

private struct BuiltAnimationModifier<
    Value: Equatable
>: ViewModifier {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    let animation: Animation
    let value: Value

    func body(content: Content) -> some View {
        content.animation(
            reduceMotion ? nil : animation,
            value: value
        )
    }
}

struct BuiltPrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @Environment(\.isEnabled)
    private var isEnabled

    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(
                Color.black.opacity(
                    isEnabled ? 1 : 0.45
                )
            )
            .frame(maxWidth: .infinity)
            .frame(
                minHeight:
                    BuiltTheme.minimumTapTarget
            )
            .padding(.horizontal, 20)
            .background {
                Capsule(style: .continuous)
                    .fill(
                        BuiltTheme.accent.opacity(
                            isEnabled ? 1 : 0.42
                        )
                    )
            }
            .contentShape(
                Capsule(style: .continuous)
            )
            .scaleEffect(
                reduceMotion
                ? 1
                : (
                    configuration.isPressed
                    ? 0.985
                    : 1
                )
            )
            .opacity(
                configuration.isPressed
                ? 0.88
                : 1
            )
            .animation(
                reduceMotion
                ? nil
                : BuiltTheme.Motion.quick,
                value: configuration.isPressed
            )
    }
}

struct BuiltSecondaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @Environment(\.accessibilityReduceTransparency)
    private var reduceTransparency

    @Environment(\.isEnabled)
    private var isEnabled

    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(
                BuiltTheme.textPrimary.opacity(
                    isEnabled ? 1 : 0.42
                )
            )
            .frame(maxWidth: .infinity)
            .frame(
                minHeight:
                    BuiltTheme.minimumTapTarget
            )
            .padding(.horizontal, 20)
            .background {
                Capsule(style: .continuous)
                    .fill(
                        reduceTransparency
                        ? BuiltTheme.elevatedStrong
                        : BuiltTheme.elevated
                            .opacity(0.62)
                    )
                    .background {
                        if !reduceTransparency {
                            Capsule(
                                style: .continuous
                            )
                            .fill(.ultraThinMaterial)
                        }
                    }
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(
                                BuiltTheme.hairline,
                                lineWidth: 1
                            )
                    }
            }
            .contentShape(
                Capsule(style: .continuous)
            )
            .scaleEffect(
                reduceMotion
                ? 1
                : (
                    configuration.isPressed
                    ? 0.985
                    : 1
                )
            )
            .opacity(
                configuration.isPressed
                ? 0.86
                : 1
            )
            .animation(
                reduceMotion
                ? nil
                : BuiltTheme.Motion.quick,
                value: configuration.isPressed
            )
    }
}

struct BuiltTertiaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @Environment(\.isEnabled)
    private var isEnabled

    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(
                BuiltTheme.accent.opacity(
                    isEnabled ? 1 : 0.42
                )
            )
            .frame(
                minHeight:
                    BuiltTheme.minimumTapTarget
            )
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
            .opacity(
                configuration.isPressed
                ? 0.62
                : 1
            )
            .scaleEffect(
                reduceMotion
                ? 1
                : (
                    configuration.isPressed
                    ? 0.985
                    : 1
                )
            )
            .animation(
                reduceMotion
                ? nil
                : BuiltTheme.Motion.quick,
                value: configuration.isPressed
            )
    }
}

struct BuiltDestructiveButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @Environment(\.isEnabled)
    private var isEnabled

    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(
                BuiltTheme.danger.opacity(
                    isEnabled ? 1 : 0.42
                )
            )
            .frame(maxWidth: .infinity)
            .frame(
                minHeight:
                    BuiltTheme.minimumTapTarget
            )
            .padding(.horizontal, 20)
            .background {
                Capsule(style: .continuous)
                    .fill(
                        BuiltTheme.danger.opacity(
                            isEnabled ? 0.12 : 0.06
                        )
                    )
                    .overlay {
                        Capsule(style: .continuous)
                            .stroke(
                                BuiltTheme.danger
                                    .opacity(0.34),
                                lineWidth: 1
                            )
                    }
            }
            .contentShape(
                Capsule(style: .continuous)
            )
            .scaleEffect(
                reduceMotion
                ? 1
                : (
                    configuration.isPressed
                    ? 0.985
                    : 1
                )
            )
            .animation(
                reduceMotion
                ? nil
                : BuiltTheme.Motion.quick,
                value: configuration.isPressed
            )
    }
}
