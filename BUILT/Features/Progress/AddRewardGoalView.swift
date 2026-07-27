import SwiftUI
import SwiftData

struct AddRewardGoalView: View {
    let profile: QuitProfile
    let totalSaved: Double
    let hasActiveGoal: Bool

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @State private var title = ""
    @State private var targetAmount = 150.0
    @State private var selectedIcon = "gift.fill"
    @State private var note = ""
    @State private var usesAutomaticSavings = true
    @State private var includeExistingSavings = true

    private let icons = [
        "gift.fill",
        "dumbbell.fill",
        "tshirt.fill",
        "headphones",
        "airplane",
        "gamecontroller.fill",
        "camera.fill",
        "cart.fill"
    ]

    private let presets: [(title: String, amount: Double, icon: String)] = [
        ("New gym gear", 150, "dumbbell.fill"),
        ("Fresh outfit", 200, "tshirt.fill"),
        ("Weekend trip", 500, "airplane"),
        ("Something earned", 100, "gift.fill")
    ]

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && targetAmount > 0
    }

    private var normalizedCurrencyCode: String {
        let cleaned = profile.currencyCode
            .uppercased()
            .filter(\.isLetter)

        return cleaned.count == 3 ? cleaned : "USD"
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
                        introduction
                        presetSection
                        goalSection
                        trackingSection
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("New reward")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(
                .ultraThinMaterial,
                for: .navigationBar
            )
            .toolbarBackground(
                .visible,
                for: .navigationBar
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(BuiltTheme.textSecondary)
                }
            }
        }
    }

    private var introduction: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Text("TURN SAVINGS INTO PROOF")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1.8)
                .foregroundStyle(BuiltTheme.accent)

            Text("Give the money a destination.")
                .font(
                    .system(
                        size: 34,
                        weight: .bold
                    )
                )
                .tracking(-1)
                .foregroundStyle(BuiltTheme.textPrimary)

            Text(
                "A reward makes every cigarette you reject visible as something you are building instead."
            )
            .font(.system(size: 15))
            .foregroundStyle(BuiltTheme.textSecondary)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
    }

    private var presetSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text("QUICK START")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .tracking(1.5)
                .foregroundStyle(BuiltTheme.textSecondary)

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                HStack(spacing: 10) {
                    ForEach(presets.indices, id: \.self) { index in
                        let preset = presets[index]

                        Button {
                            title = preset.title
                            targetAmount = preset.amount
                            selectedIcon = preset.icon
                            Haptics.selection()
                        } label: {
                            VStack(
                                alignment: .leading,
                                spacing: 12
                            ) {
                                Image(systemName: preset.icon)
                                    .font(
                                        .system(
                                            size: 18,
                                            weight: .semibold
                                        )
                                    )
                                    .foregroundStyle(BuiltTheme.accent)

                                Text(preset.title)
                                    .font(
                                        .system(
                                            size: 14,
                                            weight: .semibold
                                        )
                                    )
                                    .foregroundStyle(BuiltTheme.textPrimary)

                                Text(
                                    preset.amount.formatted(
                                        .currency(code: normalizedCurrencyCode)
                                        .precision(.fractionLength(0))
                                    )
                                )
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .medium
                                    )
                                )
                                .foregroundStyle(BuiltTheme.textSecondary)
                            }
                            .frame(
                                width: 142,
                                alignment: .leading
                            )
                            .padding(16)
                            .background(
                                .ultraThinMaterial,
                                in: RoundedRectangle(
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                            )
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .stroke(
                                    BuiltTheme.hairline,
                                    lineWidth: 1
                                )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var goalSection: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            Text("REWARD DETAILS")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .tracking(1.5)
                .foregroundStyle(BuiltTheme.accent)

            TextField(
                "What are you earning?",
                text: $title
            )
            .font(
                .system(
                    size: 21,
                    weight: .semibold
                )
            )
            .foregroundStyle(BuiltTheme.textPrimary)
            .padding(16)
            .background(
                Color.white.opacity(0.06),
                in: RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )

            HStack {
                Text("Target")
                    .font(
                        .system(
                            size: 15,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(BuiltTheme.textPrimary)

                Spacer()

                TextField(
                    "150",
                    value: $targetAmount,
                    format: .number.precision(
                        .fractionLength(0...2)
                    )
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(
                    .system(
                        size: 22,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .frame(width: 120)

                Text(normalizedCurrencyCode)
                    .font(
                        .system(
                            size: 12,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .foregroundStyle(BuiltTheme.textSecondary)
            }

            Divider()
                .overlay(BuiltTheme.hairline)

            VStack(
                alignment: .leading,
                spacing: 12
            ) {
                Text("ICON")
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .tracking(1.4)
                    .foregroundStyle(BuiltTheme.textSecondary)

                LazyVGrid(
                    columns: [
                        GridItem(
                            .adaptive(minimum: 48),
                            spacing: 10
                        )
                    ],
                    spacing: 10
                ) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            Haptics.selection()
                        } label: {
                            Image(systemName: icon)
                                .font(
                                    .system(
                                        size: 17,
                                        weight: .semibold
                                    )
                                )
                                .foregroundStyle(
                                    selectedIcon == icon
                                        ? Color.black
                                        : BuiltTheme.textPrimary
                                )
                                .frame(width: 48, height: 48)
                                .background(
                                    selectedIcon == icon
                                        ? BuiltTheme.accent
                                        : Color.white.opacity(0.06),
                                    in: Circle()
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            TextField(
                "Why this reward matters (optional)",
                text: $note,
                axis: .vertical
            )
            .lineLimit(2...4)
            .font(.system(size: 15))
            .foregroundStyle(BuiltTheme.textPrimary)
            .padding(16)
            .background(
                Color.white.opacity(0.06),
                in: RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )
        }
        .builtCard()
    }

    private var trackingSection: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Text("PROGRESS TRACKING")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .tracking(1.5)
                .foregroundStyle(BuiltTheme.accent)

            Toggle(
                "Automatically use smoking savings",
                isOn: $usesAutomaticSavings
            )
            .font(
                .system(
                    size: 15,
                    weight: .semibold
                )
            )
            .tint(BuiltTheme.accent)

            if usesAutomaticSavings && !hasActiveGoal {
                Toggle(
                    "Include money already saved",
                    isOn: $includeExistingSavings
                )
                .font(
                    .system(
                        size: 14,
                        weight: .medium
                    )
                )
                .tint(BuiltTheme.accent)
            }

            Text(
                hasActiveGoal
                    ? "This goal will be created paused because another reward is currently active."
                    : usesAutomaticSavings
                        ? "BUILT will move your calculated cigarette savings toward this goal automatically."
                        : "You will update this goal with manual contributions."
            )
            .font(.system(size: 12))
            .foregroundStyle(BuiltTheme.textSecondary)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .builtCard()
    }

    private var saveButton: some View {
        Button {
            saveGoal()
        } label: {
            HStack {
                Text("Create reward goal")
                Spacer()
                Image(systemName: "arrow.right")
            }
        }
        .buttonStyle(BuiltPrimaryButtonStyle())
        .disabled(!canSave)
        .opacity(canSave ? 1 : 0.45)
    }

    private func saveGoal() {
        guard canSave else {
            return
        }

        let shouldActivate = !hasActiveGoal
        let baseline: Double

        if usesAutomaticSavings && shouldActivate && includeExistingSavings {
            baseline = 0
        } else {
            baseline = totalSaved
        }

        let goal = RewardGoal(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            targetAmount: targetAmount,
            iconName: selectedIcon,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            automaticSavingsBaseline: baseline,
            usesAutomaticSavings: usesAutomaticSavings,
            isActive: shouldActivate
        )

        modelContext.insert(goal)
        try? modelContext.save()
        Haptics.success()
        dismiss()
    }
}
