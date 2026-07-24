import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext)
    private var modelContext

    @State private var quitDate =
        Date.now.addingTimeInterval(
            -36 * 3_600
        )

    @State private var cigarettesPerDay =
        10.0

    @State private var cigarettesPerPack =
        20.0

    @State private var packPrice =
        15.0

    @State private var currencyCode =
        "USD"

    @State private var identityStatement =
        "I protect the body and life I am building."

    @State private var showValidationMessage =
        false

    private var canContinue: Bool {
        cigarettesPerDay > 0
        && cigarettesPerPack > 0
        && packPrice >= 0
        && currencyCode
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .count == 3
        && !identityStatement
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
    }

    var body: some View {
        ZStack {
            AmbientBackground()

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: 28
                ) {
                    brandHeader
                    introduction
                    quitDateCard
                    smokingPatternCard
                    identityCard
                    continueButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 44)
            }
            .scrollDismissesKeyboard(
                .interactively
            )
        }
    }

    private var brandHeader: some View {
        HStack {
            Text("BUILT.")
                .font(
                    .system(
                        size: 18,
                        weight: .black
                    )
                )
                .tracking(2.2)
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            Spacer()

            Text("BUILT, NOT BURNED")
                .font(
                    .system(
                        size: 10,
                        weight: .semibold
                    )
                )
                .tracking(1.4)
                .foregroundStyle(
                    BuiltTheme.accent
                )
        }
    }

    private var introduction: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Text(
                """
                This body
                does not smoke.
                """
            )
            .font(
                .system(
                    size: 48,
                    weight: .bold
                )
            )
            .tracking(-1.8)
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .minimumScaleFactor(0.75)

            Text(
                """
                Set your starting point. Everything stays private on your iPhone.
                """
            )
            .font(
                .system(
                    size: 17,
                    weight: .regular
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
    }

    private var quitDateCard: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            cardTitle(
                number: "01",
                title: "Your starting point"
            )

            DatePicker(
                "Last cigarette",
                selection: $quitDate,
                in: ...Date.now,
                displayedComponents: [
                    .date,
                    .hourAndMinute
                ]
            )
            .datePickerStyle(.compact)
            .tint(BuiltTheme.accent)
        }
        .builtCard()
    }

    private var smokingPatternCard: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            cardTitle(
                number: "02",
                title: "Your old pattern"
            )

            numberField(
                title: "Cigarettes per day",
                value: $cigarettesPerDay,
                icon: "number"
            )

            Divider()
                .overlay(
                    BuiltTheme.hairline
                )

            numberField(
                title: "Cigarettes in one pack",
                value: $cigarettesPerPack,
                icon: "shippingbox"
            )

            Divider()
                .overlay(
                    BuiltTheme.hairline
                )

            HStack(spacing: 14) {
                Image(
                    systemName: "banknote"
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(width: 28)

                VStack(
                    alignment: .leading,
                    spacing: 7
                ) {
                    Text("Pack price")
                        .font(
                            .system(
                                size: 13,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )

                    TextField(
                        "15",
                        value: $packPrice,
                        format:
                            .number.precision(
                                .fractionLength(
                                    0...2
                                )
                            )
                    )
                    .font(
                        .system(
                            size: 21,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .keyboardType(.decimalPad)
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                }

                TextField(
                    "USD",
                    text: $currencyCode
                )
                .font(
                    .system(
                        size: 14,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .textInputAutocapitalization(
                    .characters
                )
                .autocorrectionDisabled()
                .multilineTextAlignment(
                    .center
                )
                .frame(width: 64)
                .padding(.vertical, 10)
                .background(
                    Color.white.opacity(0.07),
                    in: Capsule()
                )
                .onChange(
                    of: currencyCode
                ) { _, newValue in
                    let cleaned = String(
                        newValue
                            .uppercased()
                            .filter(\.isLetter)
                            .prefix(3)
                    )

                    if cleaned != newValue {
                        currencyCode = cleaned
                    }
                }
            }
        }
        .builtCard()
    }

    private var identityCard: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            cardTitle(
                number: "03",
                title: "Your reason"
            )

            Text(
                "This appears when a craving hits."
            )
            .font(.system(size: 14))
            .foregroundStyle(
                BuiltTheme.textSecondary
            )

            TextField(
                "Your reason for quitting",
                text: $identityStatement,
                axis: .vertical
            )
            .lineLimit(3...6)
            .font(
                .system(
                    size: 21,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
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

    private var continueButton: some View {
        VStack(spacing: 12) {
            Button {
                guard canContinue else {
                    showValidationMessage = true
                    Haptics.warning()
                    return
                }

                createProfile()
            } label: {
                HStack {
                    Text(
                        "Begin my smoke-free life"
                    )

                    Spacer()

                    Image(
                        systemName: "arrow.right"
                    )
                }
            }
            .buttonStyle(
                BuiltPrimaryButtonStyle()
            )

            if showValidationMessage
                && !canContinue {
                Text(
                    """
                    Complete every field and use a three-letter currency code.
                    """
                )
                .font(
                    .system(
                        size: 12,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    BuiltTheme.danger
                )
                .multilineTextAlignment(
                    .center
                )
            }
        }
    }

    private func cardTitle(
        number: String,
        title: String
    ) -> some View {
        HStack(spacing: 10) {
            Text(number)
                .font(
                    .system(
                        size: 11,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text(title)
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
        }
    }

    private func numberField(
        title: String,
        value: Binding<Double>,
        icon: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(width: 28)

            VStack(
                alignment: .leading,
                spacing: 7
            ) {
                Text(title)
                    .font(
                        .system(
                            size: 13,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )

                TextField(
                    "0",
                    value: value,
                    format:
                        .number.precision(
                            .fractionLength(
                                0...1
                            )
                        )
                )
                .font(
                    .system(
                        size: 21,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .keyboardType(.decimalPad)
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
            }
        }
    }

    private func createProfile() {
        let profile = QuitProfile(
            quitDate: quitDate,
            cigarettesPerDay:
                cigarettesPerDay,
            cigarettesPerPack:
                cigarettesPerPack,
            packPrice: packPrice,
            currencyCode:
                currencyCode.uppercased(),
            identityStatement:
                identityStatement
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
        )

        modelContext.insert(profile)
        try? modelContext.save()

        Haptics.success()
    }
}
