import SwiftUI
import SwiftData

struct CelebrationMoment:
    Identifiable,
    Equatable {
    enum Kind: Equatable {
        case recovery
        case reward
        case plan
    }

    let id: String
    let kind: Kind
    let eyebrow: String
    let title: String
    let message: String
    let symbolName: String

    static func recovery(
        _ milestone: RecoveryMilestone
    ) -> CelebrationMoment {
        CelebrationMoment(
            id:
                "recovery-\(milestone.id)",
            kind: .recovery,
            eyebrow:
                "RECOVERY MILESTONE",
            title:
                milestone.timeLabel,
            message:
                milestone.title,
            symbolName:
                milestone.symbolName
        )
    }

    static func planCompletion()
        -> CelebrationMoment {
        CelebrationMoment(
            id: "plan-first-week-complete",
            kind: .plan,
            eyebrow: "FIRST WEEK BUILT",
            title: "Seven missions. Done.",
            message:
                "You finished the plan you started. Keep the decisions that worked and carry them forward.",
            symbolName: "checkmark.seal.fill"
        )
    }

    static func reward(
        _ goal: RewardGoal
    ) -> CelebrationMoment {
        CelebrationMoment(
            id:
                "reward-\(goal.persistentModelID)",
            kind: .reward,
            eyebrow:
                "REWARD UNLOCKED",
            title:
                goal.title,
            message:
                "The money smoking would have taken is now working for you.",
            symbolName:
                goal.iconName
        )
    }
}

struct CelebrationOverlay: View {
    let moment: CelebrationMoment
    let onDismiss: () -> Void

    @State private var isPresented =
        false

    @State private var particlesExpanded =
        false

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @Environment(\.accessibilityReduceTransparency)
    private var reduceTransparency

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @ScaledMetric(relativeTo: .title)
    private var symbolContainerSize:
        CGFloat = 112

    var body: some View {
        ZStack {
            background

            if !reduceMotion {
                particleField
                    .accessibilityHidden(true)
            }

            ScrollView {
                VStack(
                    spacing:
                        BuiltTheme.Spacing.xLarge
                ) {
                    symbol
                    copy
                    dismissButton
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 38)
                .frame(maxWidth: 440)
                .scaleEffect(
                    reduceMotion
                    ? 1
                    : (
                        isPresented
                        ? 1
                        : 0.94
                    )
                )
                .opacity(
                    isPresented ? 1 : 0
                )
            }
            .scrollIndicators(.hidden)
        }
        .transition(.opacity)
        .onAppear {
            Haptics.success()

            if reduceMotion {
                isPresented = true
                particlesExpanded = true
            } else {
                withAnimation(
                    BuiltTheme.Motion.standard
                ) {
                    isPresented = true
                }

                withAnimation(
                    .easeOut(duration: 1.0)
                ) {
                    particlesExpanded = true
                }
            }
        }
        .accessibilityElement(
            children: .contain
        )
        .accessibilityIdentifier(
            "built.celebration.\(moment.id)"
        )
    }

    private var background: some View {
        (
            reduceTransparency
            ? Color.black
            : Color.black.opacity(0.88)
        )
        .ignoresSafeArea()
        .onTapGesture {
            dismiss()
        }
        .accessibilityHidden(true)
    }

    private var symbol: some View {
        ZStack {
            Circle()
                .fill(
                    BuiltTheme.accent
                        .opacity(0.16)
                )
                .frame(
                    width:
                        symbolContainerSize
                        * 1.58,
                    height:
                        symbolContainerSize
                        * 1.58
                )
                .scaleEffect(
                    reduceMotion
                    ? 1
                    : (
                        isPresented
                        ? 1
                        : 0.78
                    )
                )

            Circle()
                .fill(
                    BuiltTheme.accent
                )
                .frame(
                    width:
                        symbolContainerSize,
                    height:
                        symbolContainerSize
                )

            Image(
                systemName:
                    moment.symbolName
            )
            .font(
                .title
                .weight(.semibold)
            )
            .foregroundStyle(.black)
        }
        .accessibilityHidden(true)
    }

    private var copy: some View {
        VStack(
            spacing: BuiltTheme.Spacing.small
        ) {
            Text(moment.eyebrow)
                .font(
                    .caption
                    .weight(.bold)
                )
                .tracking(
                    dynamicTypeSize
                        .isAccessibilitySize
                    ? 0.7
                    : 1.8
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(moment.title)
                .font(
                    dynamicTypeSize
                        .isAccessibilitySize
                    ? .title.weight(.bold)
                    : .largeTitle
                        .weight(.bold)
                )
                .tracking(
                    dynamicTypeSize
                        .isAccessibilitySize
                    ? 0
                    : -1.0
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .multilineTextAlignment(
                    .center
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text(moment.message)
                .font(.body)
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
                .multilineTextAlignment(
                    .center
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .accessibilityElement(
            children: .combine
        )
        .accessibilityLabel(
            "\(moment.eyebrow). \(moment.title). \(moment.message)"
        )
    }

    private var dismissButton: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Text("Keep building")
                Spacer()
                Image(
                    systemName:
                        "arrow.right"
                )
                .accessibilityHidden(true)
            }
        }
        .buttonStyle(
            BuiltPrimaryButtonStyle()
        )
        .accessibilityIdentifier(
            "built.celebration.dismiss"
        )
        .accessibilityHint(
            "Dismisses this celebration"
        )
    }

    private var particleField: some View {
        GeometryReader { proxy in
            ForEach(
                0..<18,
                id: \.self
            ) { index in
                Circle()
                    .fill(
                        index.isMultiple(of: 3)
                        ? BuiltTheme.accent
                        : Color.white
                            .opacity(0.72)
                    )
                    .frame(
                        width:
                            CGFloat(
                                4
                                + (index % 4) * 2
                            ),
                        height:
                            CGFloat(
                                4
                                + (index % 4) * 2
                            )
                    )
                    .position(
                        x:
                            particlesExpanded
                            ? particleX(
                                index,
                                width:
                                    proxy.size.width
                            )
                            : proxy.size.width / 2,
                        y:
                            particlesExpanded
                            ? particleY(
                                index,
                                height:
                                    proxy.size.height
                            )
                            : proxy.size.height
                                * 0.36
                    )
                    .opacity(
                        particlesExpanded
                        ? 0.22
                        : 0.95
                    )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func particleX(
        _ index: Int,
        width: CGFloat
    ) -> CGFloat {
        let column =
            CGFloat(
                (index * 37) % 100
            ) / 100

        return max(
            18,
            min(
                width - 18,
                width * column
            )
        )
    }

    private func particleY(
        _ index: Int,
        height: CGFloat
    ) -> CGFloat {
        let row =
            CGFloat(
                (index * 53) % 100
            ) / 100

        return max(
            40,
            min(
                height - 40,
                height * row
            )
        )
    }

    private func dismiss() {
        if reduceMotion {
            onDismiss()
            return
        }

        withAnimation(
            .easeInOut(duration: 0.18)
        ) {
            isPresented = false
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.18
        ) {
            onDismiss()
        }
    }
}
