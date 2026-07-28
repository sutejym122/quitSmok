import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct OnboardingView: View {
    private enum Step: Int, CaseIterable {
        case welcome
        case smokingPattern
        case fitnessIdentity
        case reasons
        case triggers
        case rescuePlan
        case motivationPhoto
        case appleHealth
        case personalizedPlan

        var isOptional: Bool {
            switch self {
            case .motivationPhoto, .appleHealth:
                return true
            default:
                return false
            }
        }
    }

    @Environment(\.modelContext)
    private var modelContext

    @EnvironmentObject
    private var storeManager: StoreManager

    @StateObject
    private var draft = OnboardingDraft()

    @State private var step: Step = .welcome
    @State private var direction = 1
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isLoadingPhoto = false
    @State private var healthKitManager = HealthKitManager()
    @State private var showingPaywall = false
    @State private var isFinishing = false
    @State private var completionError: String?

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    private var onboardingColumns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [
                GridItem(
                    .flexible(),
                    spacing: 11
                )
            ]
        }

        return [
            GridItem(
                .flexible(),
                spacing: 11
            ),
            GridItem(
                .flexible(),
                spacing: 11
            )
        ]
    }

    private var onboardingChipColumns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [
                GridItem(
                    .flexible(),
                    spacing: 10
                )
            ]
        }

        return [
            GridItem(
                .adaptive(minimum: 118),
                spacing: 10
            )
        ]
    }

    private var onboardingPhotoHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize
        ? 300
        : 380
    }

    private var onboardingPickerHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize
        ? 270
        : 330
    }

    private var onboardingStepTransition:
        AnyTransition {
        guard !reduceMotion else {
            return .opacity
        }

        return .asymmetric(
            insertion:
                .opacity.combined(
                    with: .move(
                        edge:
                            direction > 0
                            ? .trailing
                            : .leading
                    )
                ),
            removal:
                .opacity.combined(
                    with: .move(
                        edge:
                            direction > 0
                            ? .leading
                            : .trailing
                    )
                )
        )
    }

    private var progressStepIndex: Int {
        step.rawValue
    }

    private var canContinue: Bool {
        switch step {
        case .welcome:
            return true
        case .smokingPattern:
            return draft.isSmokingPatternValid
        case .fitnessIdentity:
            return true
        case .reasons:
            return !draft.quitReasons.isEmpty
        case .triggers:
            return !draft.cravingTriggers.isEmpty
        case .rescuePlan:
            return !draft.rescueActions.isEmpty
        case .motivationPhoto,
             .appleHealth,
             .personalizedPlan:
            return true
        }
    }

    private var primaryButtonTitle: String {
        switch step {
        case .welcome:
            return "Build my quit plan"
        case .personalizedPlan:
            return isFinishing
                ? "Building your dashboard…"
                : "Enter BUILT"
        default:
            return "Continue"
        }
    }

    var body: some View {
        ZStack {
            AmbientBackground()

            VStack(spacing: 0) {
                if step != .welcome {
                    OnboardingProgressHeader(
                        currentStep: progressStepIndex,
                        totalSteps: Step.allCases.count,
                        canGoBack: step.rawValue > 0,
                        onBack: moveBack
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                }

                ZStack {
                    stepContent
                        .id(step)
                        .transition(
                            onboardingStepTransition
                        )
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

                bottomControls
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                    .background {
                        LinearGradient(
                            colors: [
                                BuiltTheme.background.opacity(0),
                                BuiltTheme.background.opacity(0.92),
                                BuiltTheme.background
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    }
            }
        }
        .animation(
            reduceMotion
            ? nil
            : BuiltTheme.Motion.standard,
            value: step
        )
        .sheet(isPresented: $showingPaywall) {
            PaywallView(context: .general)
                .environmentObject(storeManager)
        }
        .alert(
            "BUILT could not finish setup",
            isPresented: Binding(
                get: { completionError != nil },
                set: { newValue in
                    if !newValue {
                        completionError = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                completionError = nil
            }
        } message: {
            Text(
                completionError
                ?? "Please try again."
            )
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else {
                return
            }

            Task {
                await loadPhoto(from: newItem)
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .welcome:
            welcomeStep
        case .smokingPattern:
            smokingPatternStep
        case .fitnessIdentity:
            fitnessIdentityStep
        case .reasons:
            reasonsStep
        case .triggers:
            triggersStep
        case .rescuePlan:
            rescuePlanStep
        case .motivationPhoto:
            motivationPhotoStep
        case .appleHealth:
            appleHealthStep
        case .personalizedPlan:
            personalizedPlanStep
        }
    }

    private var welcomeStep: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: 28
                ) {
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

                        Label(
                            "PRIVATE BY DESIGN",
                            systemImage: "lock.fill"
                        )
                        .font(
                            .system(
                                size: 9,
                                weight: .bold
                            )
                        )
                        .tracking(1.2)
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                    }

                    Spacer(minLength: 42)

                    ZStack {
                        Circle()
                            .fill(
                                BuiltTheme.accent.opacity(0.14)
                            )
                            .frame(
                                width: min(
                                    proxy.size.width * 0.72,
                                    300
                                )
                            )
                            .blur(radius: 36)

                        Image(
                            systemName:
                                "figure.strengthtraining.traditional"
                        )
                        .font(
                            .system(
                                size: 116,
                                weight: .ultraLight
                            )
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    BuiltTheme.textPrimary,
                                    BuiltTheme.accent
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .frame(
                        maxWidth: .infinity
                    )
                    .accessibilityHidden(true)

                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {
                        Text(
                            "THIS BODY DOES NOT SMOKE"
                        )
                        .font(
                            .system(
                                size: 11,
                                weight: .bold
                            )
                        )
                        .tracking(2.2)
                        .foregroundStyle(
                            BuiltTheme.accent
                        )

                        Text(
                            "Quit smoking.\nProtect what you built."
                        )
                        .font(
                            dynamicTypeSize
                                .isAccessibilitySize
                            ? .largeTitle
                                .weight(.bold)
                            : .system(
                                size: 48,
                                weight: .bold
                            )
                        )
                        .tracking(
                            dynamicTypeSize
                                .isAccessibilitySize
                            ? 0
                            : -1.9
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )
                        .minimumScaleFactor(0.76)

                        Text(
                            "BUILT turns quitting into visible proof: time, money, recovery, fitness, and control."
                        )
                        .font(
                            .system(
                                size: 17,
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

                    Group {
                        if dynamicTypeSize
                            .isAccessibilitySize {
                            VStack(spacing: 10) {
                                welcomePill(
                                    icon:
                                        "bolt.heart.fill",
                                    text:
                                        "Craving Rescue"
                                )

                                welcomePill(
                                    icon:
                                        "figure.strengthtraining.traditional",
                                    text:
                                        "Fitness proof"
                                )

                                welcomePill(
                                    icon:
                                        "banknote.fill",
                                    text:
                                        "Money protected"
                                )
                            }
                        } else {
                            HStack(spacing: 10) {
                                welcomePill(
                                    icon:
                                        "bolt.heart.fill",
                                    text:
                                        "Craving Rescue"
                                )

                                welcomePill(
                                    icon:
                                        "figure.strengthtraining.traditional",
                                    text:
                                        "Fitness proof"
                                )

                                welcomePill(
                                    icon:
                                        "banknote.fill",
                                    text:
                                        "Money protected"
                                )
                            }
                        }
                    }
                }
                .frame(
                    minHeight: proxy.size.height - 20,
                    alignment: .top
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
    }

    private var smokingPatternStep: some View {
        onboardingScroll {
            OnboardingTitleBlock(
                eyebrow: "Your starting line",
                title: "Make the numbers yours.",
                message:
                    "BUILT uses your old smoking pattern to calculate what every smoke-free hour gives back."
            )

            VStack(
                alignment: .leading,
                spacing: 17
            ) {
                fieldLabel(
                    "When was your last cigarette?",
                    symbol: "calendar"
                )

                DatePicker(
                    "Last cigarette",
                    selection: $draft.quitDate,
                    in: ...Date.now,
                    displayedComponents: [
                        .date,
                        .hourAndMinute
                    ]
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(BuiltTheme.accent)
            }
            .builtCard()

            VStack(spacing: 0) {
                smokingNumberRow(
                    title: "Cigarettes per day",
                    icon: "number",
                    value: $draft.cigarettesPerDay,
                    precision: 0...1
                )

                onboardingDivider

                smokingNumberRow(
                    title: "Cigarettes in a pack",
                    icon: "shippingbox.fill",
                    value: $draft.cigarettesPerPack,
                    precision: 0...1
                )

                onboardingDivider

                HStack(spacing: 14) {
                    Image(systemName: "banknote.fill")
                        .foregroundStyle(
                            BuiltTheme.accent
                        )
                        .frame(width: 28)

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {
                        Text("Price per pack")
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
                            "12",
                            value: $draft.packPrice,
                            format:
                                .number.precision(
                                    .fractionLength(0...2)
                                )
                        )
                        .font(
                            .system(
                                size: 20,
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
                        text: $draft.currencyCode
                    )
                    .font(
                        .system(
                            size: 13,
                            weight: .bold,
                            design: .monospaced
                        )
                    )
                    .textInputAutocapitalization(
                        .characters
                    )
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.center)
                    .frame(width: 62)
                    .padding(.vertical, 10)
                    .background(
                        Color.white.opacity(0.07),
                        in: Capsule()
                    )
                    .onChange(
                        of: draft.currencyCode
                    ) { _, newValue in
                        draft.currencyCode = String(
                            newValue
                                .uppercased()
                                .filter(\.isLetter)
                                .prefix(3)
                        )
                    }
                }
                .padding(18)
            }
            .background {
                RoundedRectangle(
                    cornerRadius:
                        BuiltTheme.mediumRadius,
                    style: .continuous
                )
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(
                        cornerRadius:
                            BuiltTheme.mediumRadius,
                        style: .continuous
                    )
                    .stroke(
                        BuiltTheme.hairline,
                        lineWidth: 1
                    )
                }
            }

            if !draft.isSmokingPatternValid {
                Label(
                    "Enter valid values and a three-letter currency code.",
                    systemImage:
                        "exclamationmark.triangle.fill"
                )
                .font(
                    .system(
                        size: 12,
                        weight: .medium
                    )
                )
                .foregroundStyle(BuiltTheme.danger)
            }
        }
    }

    private var fitnessIdentityStep: some View {
        onboardingScroll {
            OnboardingTitleBlock(
                eyebrow: "Fitness identity",
                title: "What are you protecting?",
                message:
                    "Your plan should speak to the version of you that already exists—or the one you are rebuilding."
            )

            VStack(spacing: 11) {
                ForEach(
                    FitnessIdentity.allCases
                ) { identity in
                    OnboardingSelectionCard(
                        title: identity.title,
                        detail: identity.detail,
                        symbolName:
                            identity.symbolName,
                        isSelected:
                            draft.fitnessIdentity
                            == identity,
                        action: {
                            draft.selectFitnessIdentity(
                                identity
                            )
                            Haptics.selection()
                        }
                    )
                }
            }
        }
    }

    private var reasonsStep: some View {
        onboardingScroll {
            OnboardingTitleBlock(
                eyebrow: "Your why",
                title: "Make the reason personal.",
                message:
                    "Choose every reason that matters. BUILT will bring these back when motivation drops."
            )

            LazyVGrid(
                columns: [
                    GridItem(
                        .adaptive(minimum: 142),
                        spacing: 10
                    )
                ],
                spacing: 10
            ) {
                ForEach(QuitReason.allCases) {
                    reason in
                    OnboardingSelectionCard(
                        title: reason.title,
                        detail: nil,
                        symbolName:
                            reason.symbolName,
                        isSelected:
                            draft.quitReasons
                                .contains(reason),
                        action: {
                            draft.toggleReason(reason)
                            Haptics.selection()
                        }
                    )
                }
            }

            VStack(
                alignment: .leading,
                spacing: 12
            ) {
                Text("Say it in your own words")
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                TextField(
                    "Optional personal reason",
                    text: $draft.customReason,
                    axis: .vertical
                )
                .lineLimit(2...4)
                .font(.system(size: 16))
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .padding(15)
                .background(
                    Color.white.opacity(0.06),
                    in: RoundedRectangle(
                        cornerRadius: 17,
                        style: .continuous
                    )
                )
                .onSubmit {
                    draft.applyCustomReasonIfNeeded()
                }
            }
            .builtCard()
        }
    }

    private var triggersStep: some View {
        onboardingScroll {
            OnboardingTitleBlock(
                eyebrow: "Trigger map",
                title: "Know what usually pulls you back.",
                message:
                    "Choose the moments most likely to create an urge. Your preferred triggers will appear first in Rescue."
            )

            flowChips {
                ForEach(
                    CravingTrigger.allCases
                ) { trigger in
                    OnboardingChip(
                        title: trigger.title,
                        symbolName:
                            trigger.symbolName,
                        isSelected:
                            draft.cravingTriggers
                                .contains(trigger),
                        action: {
                            draft.toggleTrigger(
                                trigger
                            )
                            Haptics.selection()
                        }
                    )
                }
            }

            privacyNote(
                icon: "lock.shield.fill",
                title: "Kept on your iPhone",
                message:
                    "BUILT uses these selections only to personalize Rescue and your private insights."
            )
        }
    }

    private var rescuePlanStep: some View {
        onboardingScroll {
            OnboardingTitleBlock(
                eyebrow: "Craving rescue",
                title: "What can you do instead?",
                message:
                    "Choose fast replacement actions you can realistically do during a craving."
            )

            LazyVGrid(
                columns:
                    onboardingColumns,
                spacing: 11
            ) {
                ForEach(RescueAction.allCases) {
                    action in
                    Button {
                        draft.toggleRescueAction(
                            action
                        )
                        Haptics.selection()
                    } label: {
                        VStack(
                            alignment: .leading,
                            spacing: 18
                        ) {
                            Image(
                                systemName:
                                    action.symbolName
                            )
                            .font(
                                .system(
                                    size: 22,
                                    weight: .semibold
                                )
                            )

                            Text(action.title)
                                .font(
                                    .system(
                                        size: 15,
                                        weight: .semibold
                                    )
                                )
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                        }
                        .foregroundStyle(
                            draft.rescueActions
                                .contains(action)
                            ? Color.black
                            : BuiltTheme.textPrimary
                        )
                        .padding(17)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 112,
                            alignment: .leading
                        )
                        .background(
                            draft.rescueActions
                                .contains(action)
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
                                draft.rescueActions
                                    .contains(action)
                                ? Color.clear
                                : BuiltTheme.hairline,
                                lineWidth: 1
                            )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            privacyNote(
                icon: "bolt.heart.fill",
                title: "Rescue stays free",
                message:
                    "The 60-second breathing flow and craving logging will never require BUILT Pro."
            )
        }
    }

    private var motivationPhotoStep: some View {
        onboardingScroll {
            OnboardingTitleBlock(
                eyebrow: "Identity proof",
                title: "Add the photo that reminds you who you are.",
                message:
                    "A gym photo, progress photo, or confident moment can become your Today-screen reminder."
            )

            if let data = draft.motivationPhotoData,
               let image = UIImage(data: data) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            height:
                                onboardingPhotoHeight
                        )
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .overlay {
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black.opacity(0.72)
                                ],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        }
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius:
                                    BuiltTheme.largeRadius,
                                style: .continuous
                            )
                        )

                    Button {
                        draft.motivationPhotoData = nil
                        selectedPhotoItem = nil
                        Haptics.selection()
                    } label: {
                        Image(systemName: "xmark")
                            .font(
                                .system(
                                    size: 14,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(.white)
                            .frame(
                                width: 38,
                                height: 38
                            )
                            .background(
                                .ultraThinMaterial,
                                in: Circle()
                            )
                    }
                    .padding(14)

                    VStack {
                        Spacer()

                        TextField(
                            "Protect what you built.",
                            text:
                                $draft.motivationPhotoCaption,
                            axis: .vertical
                        )
                        .lineLimit(1...3)
                        .font(
                            .system(
                                size: 18,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(.white)
                        .padding(18)
                    }
                }
            } else {
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images
                ) {
                    VStack(spacing: 20) {
                        if isLoadingPhoto {
                            ProgressView()
                                .tint(
                                    BuiltTheme.accent
                                )
                        } else {
                            Image(
                                systemName:
                                    "photo.badge.plus"
                            )
                            .font(
                                .system(
                                    size: 56,
                                    weight: .thin
                                )
                            )
                            .foregroundStyle(
                                BuiltTheme.accent
                            )
                        }

                        VStack(spacing: 7) {
                            Text(
                                isLoadingPhoto
                                ? "Preparing your photo…"
                                : "Choose one motivation photo"
                            )
                            .font(
                                .system(
                                    size: 20,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(
                                BuiltTheme.textPrimary
                            )

                            Text(
                                "The free version includes one private photo. BUILT Pro unlocks an unlimited physique vault."
                            )
                            .font(.system(size: 13))
                            .foregroundStyle(
                                BuiltTheme.textSecondary
                            )
                            .multilineTextAlignment(.center)
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight:
                            onboardingPickerHeight
                    )
                    .builtCard(padding: 24)
                }
                .disabled(isLoadingPhoto)
            }

            privacyNote(
                icon: "photo.on.rectangle.angled",
                title: "You choose what BUILT receives",
                message:
                    "The system photo picker shares only the image you select. Your photo stays inside BUILT on this device."
            )
        }
    }

    private var appleHealthStep: some View {
        onboardingScroll {
            OnboardingTitleBlock(
                eyebrow: "Optional connection",
                title: "Let training become proof.",
                message:
                    "Apple Health can show workouts completed by the version of you that does not smoke."
            )

            VStack(
                alignment: .leading,
                spacing: 20
            ) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(
                            .system(
                                size: 26,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            BuiltTheme.accent
                        )
                        .frame(
                            width: 56,
                            height: 56
                        )
                        .background(
                            BuiltTheme.accent.opacity(0.12),
                            in: Circle()
                        )

                    Spacer()

                    if healthKitManager
                        .hasRequestedAuthorization {
                        Label(
                            "REQUESTED",
                            systemImage:
                                "checkmark.circle.fill"
                        )
                        .font(
                            .system(
                                size: 10,
                                weight: .bold
                            )
                        )
                        .tracking(1.1)
                        .foregroundStyle(
                            BuiltTheme.accent
                        )
                    }
                }

                healthPermissionRow(
                    icon: "figure.run",
                    text: "Completed workouts"
                )

                healthPermissionRow(
                    icon: "flame.fill",
                    text: "Active energy"
                )

                healthPermissionRow(
                    icon: "clock.fill",
                    text: "Apple Exercise Time"
                )

                Divider()
                    .overlay(BuiltTheme.hairline)

                Text(
                    "BUILT reads only the health categories shown above. It never writes to Apple Health or uses health data for advertising."
                )
                .font(.system(size: 13))
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }
            .builtCard(padding: 22)

            Button {
                Task {
                    await healthKitManager
                        .requestAuthorization(
                            since: draft.quitDate
                        )
                }
            } label: {
                HStack {
                    Image(
                        systemName:
                            healthKitManager
                                .hasRequestedAuthorization
                            ? "checkmark"
                            : "heart.text.clipboard"
                    )

                    Text(
                        healthKitManager.isLoading
                        ? "Connecting…"
                        : healthKitManager
                            .hasRequestedAuthorization
                        ? "Apple Health requested"
                        : "Connect Apple Health"
                    )

                    Spacer()

                    if healthKitManager.isLoading {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Image(
                            systemName:
                                healthKitManager
                                    .hasRequestedAuthorization
                                ? "checkmark.circle.fill"
                                : "arrow.right"
                        )
                    }
                }
            }
            .buttonStyle(BuiltPrimaryButtonStyle())
            .disabled(
                healthKitManager.isLoading
                || !healthKitManager.isAvailable
                || healthKitManager
                    .hasRequestedAuthorization
            )

            if let error =
                healthKitManager.errorMessage {
                BuiltStatusCard(
                    kind: .error,
                    title:
                        "Apple Health needs attention",
                    message: error
                )
            }
        }
    }

    private var personalizedPlanStep: some View {
        onboardingScroll {
            OnboardingTitleBlock(
                eyebrow: "Your plan is ready",
                title: "This is bigger than a counter.",
                message:
                    "BUILT now knows what you are protecting, what usually triggers you, and what can help in the moment."
            )

            VStack(
                alignment: .leading,
                spacing: 14
            ) {
                Text("YOUR IDENTITY")
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .tracking(1.7)
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                TextField(
                    "Your identity statement",
                    text: $draft.identityStatement,
                    axis: .vertical
                )
                .lineLimit(2...5)
                .font(
                    .system(
                        size: 24,
                        weight: .semibold
                    )
                )
                .tracking(-0.5)
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .onChange(
                    of: draft.identityStatement
                ) { _, _ in
                    draft.markIdentityEdited()
                }

                Text(
                    "This appears during cravings and on your Today screen."
                )
                .font(.system(size: 12))
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
            }
            .builtCard(padding: 22)

            LazyVGrid(
                columns:
                    onboardingColumns,
                spacing: 11
            ) {
                OnboardingMetricTile(
                    value:
                        "\(draft.projectedThirtyDayCigarettes)",
                    label:
                        "cigarettes rejected in 30 days",
                    symbolName: "nosign"
                )

                OnboardingMetricTile(
                    value:
                        draft.projectedThirtyDaySavings
                        .formatted(
                            .currency(
                                code:
                                    draft
                                        .normalizedCurrencyCode
                            )
                            .precision(
                                .fractionLength(0...2)
                            )
                        ),
                    label:
                        "projected money protected",
                    symbolName: "banknote.fill"
                )
            }

            VStack(
                alignment: .leading,
                spacing: 15
            ) {
                summaryRow(
                    icon: "scope",
                    title: "Triggers prioritized",
                    value:
                        draft.sortedTriggers
                        .prefix(3)
                        .map(\.title)
                        .joined(separator: " · ")
                )

                summaryRow(
                    icon: "bolt.heart.fill",
                    title: "Rescue actions ready",
                    value:
                        draft.sortedRescueActions
                        .prefix(3)
                        .map(\.shortTitle)
                        .joined(separator: " · ")
                )

                summaryRow(
                    icon: "photo.fill",
                    title: "Motivation photo",
                    value:
                        draft.motivationPhotoData == nil
                        ? "Add later"
                        : "Ready"
                )
            }
            .builtCard()

            if storeManager.hasPro {
                HStack(spacing: 13) {
                    Image(
                        systemName:
                            "checkmark.seal.fill"
                    )
                    .font(.system(size: 24))
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {
                        Text("BUILT Pro is active")
                            .font(
                                .system(
                                    size: 16,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(
                                BuiltTheme.textPrimary
                            )

                        Text(
                            "Your lifetime unlock is ready from day one."
                        )
                        .font(.system(size: 12))
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                    }
                }
                .builtCard()
            } else {
                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {
                    HStack {
                        VStack(
                            alignment: .leading,
                            spacing: 5
                        ) {
                            Text("Start free. Go deeper with Pro.")
                                .font(
                                    .system(
                                        size: 18,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(
                                    BuiltTheme.textPrimary
                                )

                            Text(
                                "Craving Rescue and core quitting progress stay free."
                            )
                            .font(.system(size: 12))
                            .foregroundStyle(
                                BuiltTheme.textSecondary
                            )
                        }

                        Spacer()
                        ProBadge()
                    }

                    Button {
                        showingPaywall = true
                    } label: {
                        HStack {
                            Text("Explore lifetime Pro")
                            Spacer()
                            Text(
                                storeManager.displayPrice
                                ?? "Lifetime"
                            )
                            Image(
                                systemName: "arrow.right"
                            )
                        }
                    }
                    .buttonStyle(
                        BuiltSecondaryButtonStyle()
                    )
                }
                .builtCard(padding: 20)
            }
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 9) {
            Button {
                handlePrimaryAction()
            } label: {
                HStack {
                    if isFinishing {
                        ProgressView()
                            .tint(.black)
                    }

                    Text(primaryButtonTitle)

                    Spacer()

                    if !isFinishing {
                        Image(
                            systemName:
                                step == .personalizedPlan
                                ? "checkmark"
                                : "arrow.right"
                        )
                    }
                }
            }
            .buttonStyle(BuiltPrimaryButtonStyle())
            .disabled(
                !canContinue
                || isFinishing
            )
            .opacity(
                canContinue && !isFinishing
                ? 1
                : 0.55
            )

            if step.isOptional {
                Button("Not now") {
                    moveForward()
                }
                .buttonStyle(
                    BuiltTertiaryButtonStyle()
                )
                .accessibilityHint(
                    "Skips this optional setup step"
                )
            }
        }
    }

    private func handlePrimaryAction() {
        guard canContinue else {
            Haptics.warning()
            return
        }

        if step == .reasons {
            draft.applyCustomReasonIfNeeded()
        }

        if step == .personalizedPlan {
            finishOnboarding()
        } else {
            moveForward()
        }
    }

    private func moveForward() {
        guard
            let next = Step(
                rawValue: step.rawValue + 1
            )
        else {
            return
        }

        direction = 1
        step = next
        Haptics.selection()
    }

    private func moveBack() {
        guard
            let previous = Step(
                rawValue: step.rawValue - 1
            )
        else {
            return
        }

        direction = -1
        step = previous
        Haptics.selection()
    }

    @MainActor
    private func loadPhoto(
        from item: PhotosPickerItem
    ) async {
        isLoadingPhoto = true

        defer {
            isLoadingPhoto = false
        }

        do {
            guard
                let data = try await item
                    .loadTransferable(
                        type: Data.self
                    ),
                let optimized =
                    ImageProcessor
                        .optimizedJPEGData(
                            from: data
                        )
            else {
                completionError =
                    "The selected photo could not be prepared. Choose another image."
                return
            }

            draft.motivationPhotoData = optimized
            Haptics.success()
        } catch {
            completionError = error.localizedDescription
        }
    }

    private func finishOnboarding() {
        guard !isFinishing else {
            return
        }

        isFinishing = true

        do {
            let identityStatement = draft
                .identityStatement
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let profile = QuitProfile(
                quitDate: draft.quitDate,
                cigarettesPerDay:
                    draft.cigarettesPerDay,
                cigarettesPerPack:
                    draft.cigarettesPerPack,
                packPrice: draft.packPrice,
                currencyCode:
                    draft.normalizedCurrencyCode,
                identityStatement:
                    identityStatement.isEmpty
                    ? draft
                        .fitnessIdentity
                        .identityStatement
                    : identityStatement
            )

            modelContext.insert(profile)

            if let photoData =
                draft.motivationPhotoData {
                let photo = MotivationPhoto(
                    imageData: photoData,
                    caption:
                        draft
                            .motivationPhotoCaption
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                            .isEmpty
                        ? "Protect what you built."
                        : draft
                            .motivationPhotoCaption,
                    isHero: true
                )

                modelContext.insert(photo)
            }

            try OnboardingPreferencesStore.save(
                draft.makePreferences()
            )

            try modelContext.save()
            Haptics.success()
        } catch {
            isFinishing = false
            completionError = error.localizedDescription
        }
    }

    private func onboardingScroll<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 24
            ) {
                content()
            }
            .padding(
                .horizontal,
                BuiltTheme.Spacing
                    .screenHorizontal
            )
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(
            .interactively
        )
    }

    private func welcomePill(
        icon: String,
        text: String
    ) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(BuiltTheme.accent)

            Text(text)
                .font(
                    .caption
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(
            minHeight:
                BuiltTheme.minimumTapTarget
        )
        .padding(.vertical, 8)
        .background(
            Color.white.opacity(0.055),
            in: RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .stroke(
                BuiltTheme.hairline,
                lineWidth: 1
            )
        }
    }

    private func fieldLabel(
        _ title: String,
        symbol: String
    ) -> some View {
        Label(title, systemImage: symbol)
            .font(
                .headline
                .weight(.semibold)
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
    }

    private func smokingNumberRow(
        title: String,
        icon: String,
        value: Binding<Double>,
        precision: ClosedRange<Int>
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(width: 28)

            VStack(
                alignment: .leading,
                spacing: 6
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
                            .fractionLength(precision)
                        )
                )
                .font(
                    .system(
                        size: 20,
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
        .padding(18)
    }

    private var onboardingDivider: some View {
        Divider()
            .overlay(BuiltTheme.hairline)
            .padding(.leading, 60)
    }

    private func flowChips<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        LazyVGrid(
            columns:
                onboardingChipColumns,
            alignment: .leading,
            spacing: 10
        ) {
            content()
        }
    }

    private func privacyNote(
        icon: String,
        title: String,
        message: String
    ) -> some View {
        HStack(
            alignment: .top,
            spacing: 13
        ) {
            Image(systemName: icon)
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(width: 24)

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(title)
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
        .builtCard()
    }

    private func healthPermissionRow(
        icon: String,
        text: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(width: 24)

            Text(text)
                .font(
                    .system(
                        size: 14,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                        .opacity(0.88)
                )
        }
    }

    private func summaryRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(width: 26)

            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                Text(title)
                    .font(
                        .system(
                            size: 12,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )

                Text(value.isEmpty ? "Ready" : value)
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )
                    .lineLimit(2)
            }

            Spacer()
        }
    }
}
