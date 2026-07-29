import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Bindable var profile: QuitProfile

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.scenePhase)
    private var scenePhase

    @EnvironmentObject
    private var storeManager: StoreManager

    @Query
    private var cravings: [CravingEntry]

    @Query
    private var photos: [MotivationPhoto]

    @Query
    private var rewardGoals: [RewardGoal]

    @State private var showingResetAlert = false
    @State private var showingDeleteAlert = false
    @State private var showingPaywall = false
    @State private var showingRestorePurchases = false
    @State private var saveErrorMessage: String?
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isSaving = false

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    private var appVersion: String {
        let version = Bundle.main
            .object(
                forInfoDictionaryKey:
                    "CFBundleShortVersionString"
            ) as? String
            ?? "1.0"

        let build = Bundle.main
            .object(
                forInfoDictionaryKey:
                    "CFBundleVersion"
            ) as? String
            ?? "1"

        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing:
                            BuiltTheme.Spacing.xLarge
                    ) {
                        settingsHero
                        identitySection
                        quitJourneySection
                        calculationSection
                        proSection
                        systemPresenceSection
                        privacySection
                        aboutSection
                    }
                    .padding(
                        .horizontal,
                        BuiltTheme.Spacing
                            .screenHorizontal
                    )
                    .padding(.top, 16)
                    .padding(.bottom, 42)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(
                    .interactively
                )
            }
            .navigationTitle("Settings")
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
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button {
                        saveAndDismiss()
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(
                                    BuiltTheme.accent
                                )
                        } else {
                            Text("Done")
                                .fontWeight(
                                    .semibold
                                )
                        }
                    }
                    .foregroundStyle(
                        BuiltTheme.accent
                    )
                    .disabled(isSaving)
                    .accessibilityHint(
                        "Saves your changes and closes Settings"
                    )
                }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(context: .settings)
                .environmentObject(storeManager)
        }
        .sheet(
            isPresented:
                $showingRestorePurchases
        ) {
            RestorePurchasesView()
                .environmentObject(storeManager)
        }
        .task {
            await storeManager.prepare()
            await refreshNotificationStatus()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else {
                return
            }

            Task {
                await refreshNotificationStatus()
            }
        }
        .onChange(
            of: profile.currencyCode
        ) { _, newValue in
            let cleaned = String(
                newValue
                    .uppercased()
                    .filter(\.isLetter)
                    .prefix(3)
            )

            if cleaned != newValue {
                profile.currencyCode = cleaned
            }
        }
        .alert(
            "Restart your smoke-free timer?",
            isPresented: $showingResetAlert
        ) {
            Button(
                "Restart from now",
                role: .destructive
            ) {
                restartTimer()
            }

            Button(
                "Cancel",
                role: .cancel
            ) {}
        } message: {
            Text(
                "Your craving history, photos, rewards, and preferences stay saved. BUILT records one restart and begins the current timer again."
            )
        }
        .alert(
            "Delete all BUILT data?",
            isPresented: $showingDeleteAlert
        ) {
            Button(
                "Delete everything",
                role: .destructive
            ) {
                deleteEverything()
            }

            Button(
                "Cancel",
                role: .cancel
            ) {}
        } message: {
            Text(
                "This permanently removes your profile, craving history, imported photo copies, reward goals, widgets, and scheduled reminders. Your App Store purchase remains attached to your Apple Account."
            )
        }
        .alert(
            "Changes could not be saved",
            isPresented: Binding(
                get: {
                    saveErrorMessage != nil
                },
                set: { presented in
                    if !presented {
                        saveErrorMessage = nil
                    }
                }
            )
        ) {
            Button(
                "OK",
                role: .cancel
            ) {
                saveErrorMessage = nil
            }
        } message: {
            Text(
                saveErrorMessage
                ?? "Please try again."
            )
        }
    }

    private var settingsHero: some View {
        BuiltHeroPanel(
            eyebrow: "BUILT control center",
            title: "Your quit. Your rules.",
            message:
                "Update the numbers, identity, permissions, and system presence behind your smoke-free plan.",
            systemName:
                "slider.horizontal.3",
            trailingValue:
                storeManager.hasPro
                ? "PRO"
                : "FREE",
            trailingLabel:
                "Current access"
        )
    }

    private var identitySection: some View {
        BuiltSettingsSection(
            title: "Identity statement",
            symbolName: "quote.opening"
        ) {
            TextField(
                "Reason for quitting",
                text: $profile.identityStatement,
                axis: .vertical
            )
            .lineLimit(3...7)
            .font(.title3.weight(.semibold))
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .padding(16)
            .background(
                BuiltTheme.elevatedStrong,
                in: RoundedRectangle(
                    cornerRadius:
                        BuiltTheme.smallRadius,
                    style: .continuous
                )
            )
            .accessibilityLabel(
                "Identity statement"
            )
            .accessibilityHint(
                "This appears on Today and during cravings"
            )

            Text(
                "Write the sentence you need to hear when motivation drops."
            )
            .font(.footnote)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
    }

    private var quitJourneySection: some View {
        BuiltSettingsSection(
            title: "Smoke-free journey",
            symbolName: "calendar"
        ) {
            DatePicker(
                "Last cigarette",
                selection: $profile.quitDate,
                in: ...Date.now,
                displayedComponents: [
                    .date,
                    .hourAndMinute
                ]
            )
            .datePickerStyle(.compact)
            .tint(BuiltTheme.accent)

            BuiltSettingsDivider()

            BuiltSettingsInfoRow(
                symbolName:
                    "arrow.counterclockwise",
                title:
                    "Recorded restarts",
                subtitle:
                    "A restart does not erase the evidence you already built.",
                value:
                    "\(profile.slipCount)",
                tint:
                    profile.slipCount == 0
                    ? BuiltTheme.accent
                    : BuiltTheme.warning
            )

            Button {
                showingResetAlert = true
            } label: {
                Label(
                    "Restart counter from now",
                    systemImage:
                        "arrow.counterclockwise"
                )
            }
            .buttonStyle(
                BuiltDestructiveButtonStyle()
            )
            .accessibilityHint(
                "Keeps your history and starts the current timer again"
            )
        }
    }

    private var calculationSection: some View {
        BuiltSettingsSection(
            title:
                "Calculation settings",
            symbolName: "function"
        ) {
            editableNumberRow(
                title:
                    "Cigarettes per day",
                subtitle:
                    "Your old daily average",
                value:
                    $profile.cigarettesPerDay,
                precision: 0...1
            )

            BuiltSettingsDivider()

            editableNumberRow(
                title:
                    "Cigarettes per pack",
                subtitle:
                    "Used for money calculations",
                value:
                    $profile.cigarettesPerPack,
                precision: 0...1
            )

            BuiltSettingsDivider()

            packPriceRow

            if !calculationValuesAreValid {
                BuiltStatusCard(
                    kind: .warning,
                    title:
                        "Check these values",
                    message:
                        "Daily cigarettes, pack size, and pack price must be greater than zero. Currency must use a three-letter code such as USD."
                )
            }
        }
    }

    @ViewBuilder
    private var proSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            if storeManager.hasPro {
                BuiltSettingsSection(
                    title: "BUILT Pro",
                    symbolName: "diamond.fill"
                ) {
                    Group {
                        if dynamicTypeSize
                            .isAccessibilitySize {
                            VStack(
                                alignment: .leading,
                                spacing:
                                    BuiltTheme.Spacing.medium
                            ) {
                                ProBadge()
                                proActiveCopy
                            }
                        } else {
                            HStack(
                                alignment: .top
                            ) {
                                proActiveCopy
                                Spacer()
                                ProBadge()
                            }
                        }
                    }

                    BuiltSettingsDivider()

                    BuiltSettingsInfoRow(
                        symbolName:
                            "checkmark.seal.fill",
                        title:
                            "Lifetime access active",
                        subtitle:
                            "Your entitlement is available on devices using the same Apple Account.",
                        value: "Unlocked"
                    )
                }
            } else {
                UpgradeCard(
                    title: "BUILT Pro",
                    message:
                        "One lifetime purchase unlocks the complete fitness-driven quitting system.",
                    action: {
                        showingPaywall = true
                    }
                )
            }

            Button {
                showingRestorePurchases = true
            } label: {
                BuiltSettingsNavigationRow(
                    symbolName:
                        "arrow.clockwise",
                    title:
                        "Restore purchases",
                    subtitle:
                        "Recheck lifetime access using the same Apple Account",
                    value:
                        storeManager.isBusy
                        ? "Checking…"
                        : nil
                )
                .padding(18)
                .background {
                    RoundedRectangle(
                        cornerRadius:
                            BuiltTheme.mediumRadius,
                        style: .continuous
                    )
                    .fill(
                        BuiltTheme.elevated
                            .opacity(0.80)
                    )
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
            }
            .buttonStyle(.plain)
            .disabled(storeManager.isBusy)
            .opacity(
                storeManager.isBusy
                ? 0.58
                : 1
            )
        }
    }

    private var proActiveCopy: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.xSmall
        ) {
            Text(
                "The complete system is active."
            )
            .font(.title3.weight(.bold))
            .foregroundStyle(
                BuiltTheme.textPrimary
            )

            Text(
                "Thank you for supporting an independent, privacy-first quitting app."
            )
            .font(.subheadline)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
    }

    private var systemPresenceSection:
        some View {
        BuiltSettingsSection(
            title: "System presence",
            symbolName:
                "iphone.gen3.radiowaves.left.and.right"
        ) {
            NavigationLink {
                NotificationSettingsView(
                    profile: profile
                )
            } label: {
                BuiltSettingsNavigationRow(
                    symbolName:
                        notificationSymbolName,
                    title: "Notifications",
                    subtitle:
                        "Identity, progress, and high-risk reminders",
                    value:
                        notificationStatusText,
                    tint:
                        notificationStatus == .denied
                        ? BuiltTheme.danger
                        : BuiltTheme.accent
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(
                "built.settings.notifications"
            )

            BuiltSettingsDivider()

            BuiltSettingsInfoRow(
                symbolName:
                    "rectangle.stack.badge.plus",
                title:
                    "Widgets and Live Activity",
                subtitle:
                    "Add BUILT from the Home Screen or Lock Screen gallery.",
                value: "Available"
            )

            BuiltSettingsDivider()

            BuiltSettingsInfoRow(
                symbolName:
                    "heart.text.clipboard",
                title: "Apple Health",
                subtitle:
                    "Workout access is managed by iOS and remains optional.",
                value: "Read only"
            )
        }
    }

    private var privacySection: some View {
        BuiltSettingsSection(
            title: "Privacy and data",
            symbolName: "lock.shield"
        ) {
            BuiltSettingsInfoRow(
                symbolName: "iphone",
                title:
                    "Stored on this device",
                subtitle:
                    "\(cravings.count) cravings · \(photos.count) photos · \(rewardGoals.count) rewards",
                value: "Local"
            )

            BuiltSettingsDivider()

            BuiltSettingsInfoRow(
                symbolName:
                    "hand.raised.fill",
                title:
                    "Private by design",
                subtitle:
                    "BUILT does not require an account, show ads, or upload your quitting and fitness data.",
                value: "No account"
            )

            BuiltSettingsDivider()

            Button(
                role: .destructive
            ) {
                showingDeleteAlert = true
            } label: {
                HStack(
                    spacing:
                        BuiltTheme.Spacing.medium
                ) {
                    Image(systemName: "trash")
                        .accessibilityHidden(true)

                    VStack(
                        alignment: .leading,
                        spacing:
                            BuiltTheme.Spacing.xSmall
                    ) {
                        Text(
                            "Delete all app data"
                        )
                        .font(
                            .headline
                            .weight(.semibold)
                        )

                        Text(
                            "Permanently remove local BUILT content and reminders"
                        )
                        .font(.caption)
                    }

                    Spacer()
                }
                .foregroundStyle(
                    BuiltTheme.danger
                )
                .frame(
                    minHeight:
                        BuiltTheme.minimumTapTarget
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint(
                "Shows a confirmation before deleting anything"
            )
        }
    }

    private var aboutSection: some View {
        BuiltSettingsSection(
            title: "About BUILT",
            symbolName: "info.circle"
        ) {
            BuiltSettingsInfoRow(
                symbolName: "hammer.fill",
                title: "Built, not burned",
                subtitle:
                    "A fitness-identity system for quitting smoking.",
                value:
                    "Version \(appVersion)"
            )

            BuiltSettingsDivider()

            Text(
                "BUILT supports behavior change and personal tracking. It does not diagnose, treat, or replace medical care."
            )
            .font(.footnote)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
    }

    private var packPriceRow: some View {
        Group {
            if dynamicTypeSize
                .isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing:
                        BuiltTheme.Spacing.medium
                ) {
                    settingsFieldCopy(
                        title: "Pack price",
                        subtitle:
                            "Used to calculate money protected"
                    )

                    HStack(
                        spacing:
                            BuiltTheme.Spacing.small
                    ) {
                        packPriceField
                        currencyField
                    }
                }
            } else {
                HStack(
                    spacing:
                        BuiltTheme.Spacing.medium
                ) {
                    settingsFieldCopy(
                        title: "Pack price",
                        subtitle:
                            "Used to calculate money protected"
                    )

                    Spacer()
                    packPriceField
                    currencyField
                }
            }
        }
        .frame(
            minHeight:
                BuiltTheme.minimumTapTarget
        )
    }

    private var packPriceField: some View {
        TextField(
            "15",
            value: $profile.packPrice,
            format:
                .number.precision(
                    .fractionLength(0...2)
                )
        )
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.trailing)
        .font(
            .headline
            .weight(.semibold)
            .monospacedDigit()
        )
        .foregroundStyle(
            BuiltTheme.textPrimary
        )
        .padding(.horizontal, 12)
        .frame(
            width:
                dynamicTypeSize.isAccessibilitySize
                ? nil
                : 92
        )
        .frame(minHeight: 44)
        .background(
            BuiltTheme.elevatedStrong,
            in: RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
        )
        .accessibilityLabel("Pack price")
    }

    private var currencyField: some View {
        TextField(
            "USD",
            text: $profile.currencyCode
        )
        .textInputAutocapitalization(.characters)
        .autocorrectionDisabled()
        .multilineTextAlignment(.center)
        .font(
            .subheadline
            .weight(.bold)
            .monospaced()
        )
        .foregroundStyle(
            BuiltTheme.textPrimary
        )
        .frame(width: 68)
        .frame(minHeight: 44)
        .background(
            BuiltTheme.elevatedStrong,
            in: Capsule()
        )
        .accessibilityLabel(
            "Three-letter currency code"
        )
    }

    @ViewBuilder
    private func editableNumberRow(
        title: String,
        subtitle: String,
        value: Binding<Double>,
        precision: ClosedRange<Int>
    ) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(
                alignment: .leading,
                spacing:
                    BuiltTheme.Spacing.medium
            ) {
                settingsFieldCopy(
                    title: title,
                    subtitle: subtitle
                )

                numberField(
                    title: title,
                    value: value,
                    precision: precision
                )
            }
        } else {
            HStack(
                spacing:
                    BuiltTheme.Spacing.medium
            ) {
                settingsFieldCopy(
                    title: title,
                    subtitle: subtitle
                )

                Spacer()

                numberField(
                    title: title,
                    value: value,
                    precision: precision
                )
            }
            .frame(
                minHeight:
                    BuiltTheme.minimumTapTarget
            )
        }
    }

    private func settingsFieldCopy(
        title: String,
        subtitle: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.xSmall
        ) {
            Text(title)
                .font(
                    .subheadline
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
        }
    }

    private func numberField(
        title: String,
        value: Binding<Double>,
        precision: ClosedRange<Int>
    ) -> some View {
        TextField(
            "0",
            value: value,
            format:
                .number.precision(
                    .fractionLength(precision)
                )
        )
        .keyboardType(.decimalPad)
        .multilineTextAlignment(.trailing)
        .font(
            .headline
            .weight(.semibold)
            .monospacedDigit()
        )
        .foregroundStyle(
            BuiltTheme.textPrimary
        )
        .padding(.horizontal, 12)
        .frame(
            width:
                dynamicTypeSize.isAccessibilitySize
                ? nil
                : 96
        )
        .frame(minHeight: 44)
        .background(
            BuiltTheme.elevatedStrong,
            in: RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
        )
        .accessibilityLabel(title)
    }

    private var calculationValuesAreValid:
        Bool {
        profile.cigarettesPerDay > 0
        && profile.cigarettesPerPack > 0
        && profile.packPrice > 0
        && profile.currencyCode.count == 3
    }

    private var notificationStatusText:
        String {
        switch notificationStatus {
        case .notDetermined:
            return "Not set"
        case .denied:
            return "Off"
        case .authorized:
            return "Allowed"
        case .provisional:
            return "Quiet"
        case .ephemeral:
            return "Temporary"
        @unknown default:
            return "Unknown"
        }
    }

    private var notificationSymbolName:
        String {
        switch notificationStatus {
        case .denied:
            return "bell.slash.fill"
        case .authorized,
             .provisional,
             .ephemeral:
            return "bell.badge.fill"
        default:
            return "bell.fill"
        }
    }

    @MainActor
    private func refreshNotificationStatus()
        async {
        notificationStatus =
            await NotificationManager
                .shared
                .authorizationStatus()
    }

    private func saveAndDismiss() {
        guard !isSaving else {
            return
        }

        isSaving = true

        defer {
            isSaving = false
        }

        guard saveChanges() else {
            return
        }

        dismiss()
    }

    @discardableResult
    private func saveChanges() -> Bool {
        guard calculationValuesAreValid
        else {
            saveErrorMessage =
                "Enter positive smoking values and a valid three-letter currency code before saving."
            Haptics.warning()
            return false
        }

        do {
            try modelContext.save()

            WidgetSyncService.sync(
                profile: profile,
                cravings: cravings,
                rewardGoals: rewardGoals
            )

            return true
        } catch {
            saveErrorMessage =
                "BUILT could not save these changes to the local database. \(error.localizedDescription)"
            Haptics.warning()
            return false
        }
    }

    private func restartTimer() {
        let oldDate = profile.quitDate
        let oldCount = profile.slipCount

        profile.quitDate = .now
        profile.slipCount += 1
        RecoveryCelebrationStore.reset()

        guard saveChanges() else {
            profile.quitDate = oldDate
            profile.slipCount = oldCount
            return
        }

        Haptics.warning()
    }

    private func deleteEverything() {
        for craving in cravings {
            modelContext.delete(craving)
        }

        for photo in photos {
            modelContext.delete(photo)
        }

        for goal in rewardGoals {
            modelContext.delete(goal)
        }

        modelContext.delete(profile)

        do {
            try modelContext.save()
        } catch {
            saveErrorMessage =
                "BUILT could not delete the local database. Nothing outside the database was cleared."
            Haptics.warning()
            return
        }

        WidgetSyncService.clear()
        NotificationPreferencesStore.reset()
        RecoveryCelebrationStore.reset()

        Task {
            await NotificationManager.shared
                .cancelAll()

            await LiveActivityManager.shared
                .cancel()
        }

        dismiss()
    }
}
