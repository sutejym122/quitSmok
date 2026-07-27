import SwiftUI
import SwiftData

struct CelebrationMoment: Identifiable, Equatable {
    enum Kind: Equatable {
        case recovery
        case reward
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
            id: "recovery-\(milestone.id)",
            kind: .recovery,
            eyebrow: "RECOVERY MILESTONE",
            title: milestone.timeLabel,
            message: milestone.title,
            symbolName: milestone.symbolName
        )
    }

    static func reward(
        _ goal: RewardGoal
    ) -> CelebrationMoment {
        CelebrationMoment(
            id: "reward-\(goal.persistentModelID)",
            kind: .reward,
            eyebrow: "REWARD UNLOCKED",
            title: goal.title,
            message: "The money smoking would have taken is now working for you.",
            symbolName: goal.iconName
        )
    }
}

struct CelebrationOverlay: View {
    let moment: CelebrationMoment
    let onDismiss: () -> Void

    @State private var isPresented = false
    @State private var particlesExpanded = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.86)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            particleField

            VStack(spacing: 26) {
                ZStack {
                    Circle()
                        .fill(BuiltTheme.accent.opacity(0.16))
                        .frame(width: 180, height: 180)
                        .blur(radius: 1)
                        .scaleEffect(isPresented ? 1 : 0.72)

                    Circle()
                        .fill(BuiltTheme.accent)
                        .frame(width: 112, height: 112)

                    Image(systemName: moment.symbolName)
                        .font(
                            .system(
                                size: 42,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(.black)
                }

                VStack(spacing: 12) {
                    Text(moment.eyebrow)
                        .font(
                            .system(
                                size: 11,
                                weight: .bold
                            )
                        )
                        .tracking(2)
                        .foregroundStyle(BuiltTheme.accent)

                    Text(moment.title)
                        .font(
                            .system(
                                size: 42,
                                weight: .bold
                            )
                        )
                        .tracking(-1.4)
                        .foregroundStyle(BuiltTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)

                    Text(moment.message)
                        .font(
                            .system(
                                size: 17,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(BuiltTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }

                Button {
                    dismiss()
                } label: {
                    HStack {
                        Text("Keep building")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(BuiltPrimaryButtonStyle())
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 34)
            .frame(maxWidth: 440)
            .scaleEffect(isPresented ? 1 : 0.92)
            .opacity(isPresented ? 1 : 0)
        }
        .transition(.opacity)
        .onAppear {
            Haptics.success()

            withAnimation(
                .spring(
                    response: 0.52,
                    dampingFraction: 0.78
                )
            ) {
                isPresented = true
            }

            withAnimation(
                .easeOut(duration: 1.1)
            ) {
                particlesExpanded = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(moment.eyebrow). \(moment.title). \(moment.message)"
        )
    }

    private var particleField: some View {
        GeometryReader { proxy in
            ForEach(0..<18, id: \.self) { index in
                Circle()
                    .fill(
                        index.isMultiple(of: 3)
                            ? BuiltTheme.accent
                            : Color.white.opacity(0.72)
                    )
                    .frame(
                        width: CGFloat(4 + (index % 4) * 2),
                        height: CGFloat(4 + (index % 4) * 2)
                    )
                    .position(
                        x: particlesExpanded
                            ? particleX(index, width: proxy.size.width)
                            : proxy.size.width / 2,
                        y: particlesExpanded
                            ? particleY(index, height: proxy.size.height)
                            : proxy.size.height * 0.36
                    )
                    .opacity(particlesExpanded ? 0.22 : 0.95)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func particleX(
        _ index: Int,
        width: CGFloat
    ) -> CGFloat {
        let column = CGFloat((index * 37) % 100) / 100
        return max(18, min(width - 18, width * column))
    }

    private func particleY(
        _ index: Int,
        height: CGFloat
    ) -> CGFloat {
        let row = CGFloat((index * 53) % 100) / 100
        return max(40, min(height - 40, height * row))
    }

    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPresented = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}
