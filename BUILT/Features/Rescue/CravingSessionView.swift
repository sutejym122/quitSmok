import SwiftUI
import SwiftData

struct CravingSessionView: View {
    private enum Phase: Equatable {
        case setup
        case breathe
        case action
        case result
    }

    let profile: QuitProfile

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @State private var phase:
        Phase = .setup

    @State private var intensity =
        6.0

    @State private var selectedTrigger =
        "Stress"

    @State private var selectedAction =
        "Drink water"

    @State private var secondsRemaining =
        60

    @State private var savedOutcome:
        CravingOutcome?

    @State private var showingSlipAlert =
        false

    @State private var hasSaved =
        false

    private let triggers = [
        "Stress",
        "After food",
        "Coffee",
        "Alcohol",
        "Boredom",
        "Social",
        "Driving",
        "Habit"
    ]

    private let actions = [
        (
            "Drink water",
            "drop.fill"
        ),
        (
            "Walk 5 minutes",
            "figure.walk"
        ),
        (
            "20 push-ups",
            "figure.strengthtraining.traditional"
        ),
        (
            "Chew gum",
            "mouth.fill"
        ),
        (
            "Leave the room",
            "door.left.hand.open"
        ),
        (
            "Text someone",
            "message.fill"
        )
    ]

    var body: some View {
        ZStack {
            AmbientBackground()

            VStack(spacing: 0) {
                topBar

                Group {
                    switch phase {
                    case .setup:
                        setupView

                    case .breathe:
                        breathingView

                    case .action:
                        actionView

                    case .result:
                        resultView
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .transition(
                    .opacity.combined(
                        with:
                            .move(
                                edge: .trailing
                            )
                    )
                )
            }
        }
        .animation(
            .spring(
                response: 0.42,
                dampingFraction: 0.86
            ),
            value: phase
        )
        .task(id: phase) {
            guard phase == .breathe else {
                return
            }

            secondsRemaining = 60

            while secondsRemaining > 0 {
                do {
                    try await Task.sleep(
                        for: .seconds(1)
                    )
                } catch {
                    return
                }

                guard !Task.isCancelled,
                      phase == .breathe else {
                    return
                }

                secondsRemaining -= 1
            }

            guard phase == .breathe else {
                return
            }

            withAnimation {
                phase = .action
            }

            Haptics.selection()
        }
        .alert(
            "Did you smoke?",
            isPresented:
                $showingSlipAlert
        ) {
            Button(
                "Keep current counter"
            ) {
                save(
                    outcome: .smoked,
                    resetCounter: false
                )
            }

            Button(
                "Reset counter to now",
                role: .destructive
            ) {
                save(
                    outcome: .smoked,
                    resetCounter: true
                )
            }

            Button(
                "Cancel",
                role: .cancel
            ) {}
        } message: {
            Text(
                """
                A slip does not erase your progress. Choose whether this cigarette should restart the current timer.
                """
            )
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(
                    systemName: "xmark"
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

            Spacer()

            Text("CRAVING RESCUE")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1.7)
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )

            Spacer()

            Color.clear
                .frame(
                    width: 42,
                    height: 42
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var setupView: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 28
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {
                    Text("Name the urge.")
                        .font(
                            .system(
                                size: 42,
                                weight: .bold
                            )
                        )
                        .tracking(-1.4)
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )

                    Text(
                        """
                        You are observing a craving, not obeying it.
                        """
                    )
                    .font(.system(size: 16))
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                }

                intensityCard
                triggerCard

                Button {
                    phase = .breathe
                    Haptics.selection()
                } label: {
                    HStack {
                        Text(
                            "Begin 60-second reset"
                        )

                        Spacer()

                        Image(
                            systemName:
                                "arrow.right"
                        )
                    }
                }
                .buttonStyle(
                    BuiltPrimaryButtonStyle()
                )
            }
            .padding(
                .horizontal,
                20
            )
            .padding(.top, 26)
            .padding(.bottom, 36)
        }
    }

    private var intensityCard: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            HStack(
                alignment:
                    .firstTextBaseline
            ) {
                Text("Intensity")
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                Spacer()

                Text(
                    "\(Int(intensity))/10"
                )
                .font(
                    .system(
                        size: 28,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )
            }

            Slider(
                value: $intensity,
                in: 1...10,
                step: 1
            )
            .tint(BuiltTheme.accent)

            HStack {
                Text("Mild")

                Spacer()

                Text("Overwhelming")
            }
            .font(
                .system(
                    size: 11,
                    weight: .medium
                )
            )
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
        .builtCard()
    }

    private var triggerCard: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Text("What triggered it?")
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            LazyVGrid(
                columns: [
                    GridItem(
                        .adaptive(
                            minimum: 96
                        ),
                        spacing: 10
                    )
                ],
                spacing: 10
            ) {
                ForEach(
                    triggers,
                    id: \.self
                ) { trigger in
                    Button {
                        selectedTrigger =
                            trigger

                        Haptics.selection()
                    } label: {
                        Text(trigger)
                            .font(
                                .system(
                                    size: 13,
                                    weight:
                                        .semibold
                                )
                            )
                            .foregroundStyle(
                                selectedTrigger
                                    == trigger
                                ? Color.black
                                : BuiltTheme
                                    .textPrimary
                            )
                            .frame(
                                maxWidth:
                                    .infinity
                            )
                            .padding(
                                .vertical,
                                12
                            )
                            .background(
                                selectedTrigger
                                    == trigger
                                ? BuiltTheme
                                    .accent
                                : Color.white
                                    .opacity(
                                        0.07
                                    ),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .builtCard()
    }

    private var breathingView: some View {
        VStack(spacing: 26) {
            Spacer()

            VStack(spacing: 10) {
                Text(
                    "Stay with the wave."
                )
                .font(
                    .system(
                        size: 36,
                        weight: .bold
                    )
                )
                .tracking(-1)
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

                Text(
                    profile.identityStatement
                )
                .font(
                    .system(
                        size: 16,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
                .multilineTextAlignment(
                    .center
                )
                .padding(
                    .horizontal,
                    26
                )
            }

            BreathingPulse(
                secondsRemaining:
                    secondsRemaining
            )
            .frame(height: 330)

            Button("Skip to actions") {
                phase = .action
            }
            .font(
                .system(
                    size: 14,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                BuiltTheme.textSecondary
            )

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var actionView: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 26
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {
                    Text(
                        "Replace the ritual."
                    )
                    .font(
                        .system(
                            size: 40,
                            weight: .bold
                        )
                    )
                    .tracking(-1.3)
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                    Text(
                        """
                        Choose one action and do it immediately.
                        """
                    )
                    .font(.system(size: 16))
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                }

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
                    ForEach(
                        actions,
                        id: \.0
                    ) { action in
                        Button {
                            selectedAction =
                                action.0

                            Haptics.selection()
                        } label: {
                            VStack(
                                alignment:
                                    .leading,
                                spacing: 18
                            ) {
                                Image(
                                    systemName:
                                        action.1
                                )
                                .font(
                                    .system(
                                        size: 22,
                                        weight:
                                            .semibold
                                    )
                                )
                                .foregroundStyle(
                                    selectedAction
                                        == action.0
                                    ? Color.black
                                    : BuiltTheme
                                        .accent
                                )

                                Text(action.0)
                                    .font(
                                        .system(
                                            size: 15,
                                            weight:
                                                .semibold
                                        )
                                    )
                                    .foregroundStyle(
                                        selectedAction
                                            == action.0
                                        ? Color.black
                                        : BuiltTheme
                                            .textPrimary
                                    )
                                    .frame(
                                        maxWidth:
                                            .infinity,
                                        alignment:
                                            .leading
                                    )
                            }
                            .padding(17)
                            .frame(
                                maxWidth:
                                    .infinity,
                                minHeight: 112,
                                alignment:
                                    .leading
                            )
                            .background(
                                selectedAction
                                    == action.0
                                ? BuiltTheme
                                    .accent
                                : Color.white
                                    .opacity(
                                        0.07
                                    ),
                                in:
                                    RoundedRectangle(
                                        cornerRadius:
                                            20,
                                        style:
                                            .continuous
                                    )
                            )
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius:
                                        20,
                                    style:
                                        .continuous
                                )
                                .stroke(
                                    BuiltTheme
                                        .hairline,
                                    lineWidth:
                                        selectedAction
                                            == action.0
                                        ? 0
                                        : 1
                                )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(spacing: 12) {
                    Button {
                        save(
                            outcome:
                                .defeated,
                            resetCounter:
                                false
                        )
                    } label: {
                        HStack {
                            Image(
                                systemName:
                                    "checkmark"
                            )

                            Text(
                                "I didn’t smoke"
                            )

                            Spacer()

                            Image(
                                systemName:
                                    "arrow.right"
                            )
                        }
                    }
                    .buttonStyle(
                        BuiltPrimaryButtonStyle()
                    )

                    Button {
                        showingSlipAlert =
                            true
                    } label: {
                        Text("I smoked")
                    }
                    .buttonStyle(
                        BuiltSecondaryButtonStyle()
                    )
                }
            }
            .padding(
                .horizontal,
                20
            )
            .padding(.top, 26)
            .padding(.bottom, 36)
        }
    }

    private var resultView: some View {
        VStack(spacing: 26) {
            Spacer()

            Image(
                systemName:
                    savedOutcome
                        == .defeated
                    ? "checkmark"
                    : "arrow.counterclockwise"
            )
            .font(
                .system(
                    size: 40,
                    weight: .bold
                )
            )
            .foregroundStyle(
                savedOutcome == .defeated
                ? Color.black
                : BuiltTheme.textPrimary
            )
            .frame(
                width: 110,
                height: 110
            )
            .background(
                savedOutcome == .defeated
                ? BuiltTheme.accent
                : BuiltTheme.danger
                    .opacity(0.18),
                in: Circle()
            )
            .overlay {
                Circle()
                    .stroke(
                        savedOutcome
                            == .defeated
                        ? Color.clear
                        : BuiltTheme
                            .danger
                            .opacity(0.55),
                        lineWidth: 1
                    )
            }

            VStack(spacing: 12) {
                Text(
                    savedOutcome
                        == .defeated
                    ? "Craving defeated."
                    : "Continue from here."
                )
                .font(
                    .system(
                        size: 38,
                        weight: .bold
                    )
                )
                .tracking(-1.2)
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .multilineTextAlignment(
                    .center
                )

                Text(
                    savedOutcome
                        == .defeated
                    ? """
                    You kept the promise you made to yourself.
                    """
                    : """
                    One decision does not get to define the next one.
                    """
                )
                .font(.system(size: 16))
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
                .multilineTextAlignment(
                    .center
                )
                .padding(
                    .horizontal,
                    30
                )
            }

            Spacer()

            Button("Done") {
                dismiss()
            }
            .buttonStyle(
                BuiltPrimaryButtonStyle()
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
    }

    private func save(
        outcome: CravingOutcome,
        resetCounter: Bool
    ) {
        guard !hasSaved else {
            return
        }

        hasSaved = true

        let entry = CravingEntry(
            intensity: Int(intensity),
            trigger: selectedTrigger,
            replacementAction:
                selectedAction,
            outcome: outcome
        )

        modelContext.insert(entry)

        if outcome == .smoked {
            profile.slipCount += 1

            if resetCounter {
                profile.quitDate = .now
            }

            Haptics.warning()
        } else {
            Haptics.success()
        }

        try? modelContext.save()

        savedOutcome = outcome
        phase = .result
    }
}

private struct BreathingPulse: View {
    let secondsRemaining: Int

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval:
                    1.0 / 30.0
            )
        ) { context in
            let cycle =
                context.date
                    .timeIntervalSinceReferenceDate
                    .truncatingRemainder(
                        dividingBy: 8
                    )

            let isInhaling =
                cycle < 4

            let normalized =
                isInhaling
                ? cycle / 4
                : (8 - cycle) / 4

            let scale =
                0.78
                + (0.22 * normalized)

            ZStack {
                Circle()
                    .stroke(
                        Color.white
                            .opacity(0.08),
                        lineWidth: 1
                    )
                    .frame(
                        width: 270,
                        height: 270
                    )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                BuiltTheme
                                    .accent
                                    .opacity(0.34),
                                BuiltTheme
                                    .accent
                                    .opacity(0.03)
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 132
                        )
                    )
                    .frame(
                        width: 250,
                        height: 250
                    )
                    .scaleEffect(scale)

                Circle()
                    .stroke(
                        BuiltTheme
                            .accent
                            .opacity(0.70),
                        lineWidth: 2
                    )
                    .frame(
                        width: 210,
                        height: 210
                    )
                    .scaleEffect(scale)

                VStack(spacing: 7) {
                    Text(
                        isInhaling
                        ? "INHALE"
                        : "EXHALE"
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .bold
                        )
                    )
                    .tracking(2)
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                    Text(
                        "\(secondsRemaining)"
                    )
                    .font(
                        .system(
                            size: 52,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                    Text("SECONDS")
                        .font(
                            .system(
                                size: 10,
                                weight: .semibold
                            )
                        )
                        .tracking(1.4)
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                }
            }
        }
    }
}
