import SwiftUI
import UserNotifications
import UIKit

struct NotificationSettingsView: View {
    let profile: QuitProfile

    @Environment(\.openURL)
    private var openURL

    @Environment(\.scenePhase)
    private var scenePhase

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @State private var preferences =
        NotificationPreferencesStore.load()

    @State private var authorizationStatus:
        UNAuthorizationStatus =
            .notDetermined

    @State private var isWorking = false
    @State private var statusMessage: String?
    @State private var statusKind:
        BuiltStatusKind = .neutral

    var body: some View {
        ZStack {
            AmbientBackground()

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing:
                        BuiltTheme.Spacing.xLarge
                ) {
                    introduction
                    permissionSection

                    if canSchedule {
                        reminderSchedule
                        milestoneSection
                    }

                    if let statusMessage {
                        BuiltStatusCard(
                            kind: statusKind,
                            title:
                                statusKind == .success
                                ? "Reminders updated"
                                : "Notification status",
                            message: statusMessage
                        )
                    }
                }
                .padding(
                    .horizontal,
                    BuiltTheme.Spacing
                        .screenHorizontal
                )
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            .ultraThinMaterial,
            for: .navigationBar
        )
        .toolbarBackground(
            .visible,
            for: .navigationBar
        )
        .safeAreaInset(
            edge: .bottom,
            spacing: 0
        ) {
            bottomAction
        }
        .task {
            await refreshAuthorizationStatus()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else {
                return
            }

            Task {
                await refreshAuthorizationStatus()
            }
        }
        .onChange(of: preferences) { _, newValue in
            NotificationPreferencesStore
                .save(newValue)

            statusMessage = nil
        }
        .onDisappear {
            NotificationPreferencesStore
                .save(preferences)

            guard canSchedule else {
                return
            }

            Task {
                await scheduleCurrentPreferences()
            }
        }
    }

    private var introduction: some View {
        BuiltHeroPanel(
            eyebrow: "System presence",
            title:
                "Let BUILT reach you before the craving does.",
            message:
                "Use only the reminders that feel useful. Scheduling stays local to your iPhone.",
            systemName:
                "bell.badge.fill",
            trailingValue:
                permissionShortStatus,
            trailingLabel:
                "Permission"
        )
    }

    @ViewBuilder
    private var permissionSection: some View {
        switch authorizationStatus {
        case .notDetermined:
            BuiltStatusCard(
                kind: .neutral,
                title:
                    "Notifications are optional",
                message:
                    "BUILT can deliver identity, progress, high-risk, and milestone reminders. You choose whether to allow them.",
                primaryActionTitle:
                    "Enable notifications",
                primaryAction: {
                    Task {
                        await requestPermission()
                    }
                }
            )

        case .denied:
            BuiltStatusCard(
                kind: .warning,
                title:
                    "Notifications are off",
                message:
                    "iOS has disabled BUILT notifications. Your schedules remain saved locally and can resume after access is restored.",
                primaryActionTitle:
                    "Open iPhone Settings",
                primaryAction:
                    openAppSettings
            )

        case .authorized,
             .provisional,
             .ephemeral:
            BuiltSettingsSection(
                title:
                    "Notification access",
                symbolName:
                    permissionIcon
            ) {
                BuiltSettingsInfoRow(
                    symbolName:
                        permissionIcon,
                    title:
                        permissionStatusTitle,
                    subtitle:
                        permissionStatusMessage,
                    value:
                        permissionShortStatus,
                    tint:
                        permissionColor
                )

                BuiltSettingsDivider()

                Toggle(
                    isOn:
                        $preferences
                            .masterEnabled
                ) {
                    VStack(
                        alignment: .leading,
                        spacing:
                            BuiltTheme.Spacing.xSmall
                    ) {
                        Text(
                            "Enable BUILT reminders"
                        )
                        .font(
                            .headline
                            .weight(.semibold)
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )

                        Text(
                            "One switch pauses every local reminder without deleting your schedule."
                        )
                        .font(.caption)
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                    }
                }
                .tint(BuiltTheme.accent)
                .frame(
                    minHeight:
                        BuiltTheme.minimumTapTarget
                )
            }

        @unknown default:
            BuiltStatusCard(
                kind: .warning,
                title:
                    "Notification status unavailable",
                message:
                    "BUILT could not interpret the current iOS notification status. Open Settings to review access.",
                primaryActionTitle:
                    "Open iPhone Settings",
                primaryAction:
                    openAppSettings
            )
        }
    }

    private var reminderSchedule: some View {
        BuiltSettingsSection(
            title: "Daily reminders",
            symbolName: "clock"
        ) {
            reminderRow(
                title:
                    "Morning identity",
                subtitle:
                    "Start the day with your reason.",
                symbolName: "sun.max.fill",
                isOn:
                    $preferences.morningEnabled,
                time:
                    timeBinding(
                        hour:
                            $preferences.morningHour,
                        minute:
                            $preferences.morningMinute
                    )
            )

            BuiltSettingsDivider()

            reminderRow(
                title:
                    "Evening progress",
                subtitle:
                    "Recognize another protected day.",
                symbolName:
                    "moon.stars.fill",
                isOn:
                    $preferences.eveningEnabled,
                time:
                    timeBinding(
                        hour:
                            $preferences.eveningHour,
                        minute:
                            $preferences.eveningMinute
                    )
            )

            BuiltSettingsDivider()

            reminderRow(
                title:
                    "High-risk time",
                subtitle:
                    "Set the hour cravings usually appear.",
                symbolName:
                    "bolt.heart.fill",
                isOn:
                    $preferences.riskEnabled,
                time:
                    timeBinding(
                        hour:
                            $preferences.riskHour,
                        minute:
                            $preferences.riskMinute
                    )
            )
        }
        .opacity(
            preferences.masterEnabled
            ? 1
            : 0.48
        )
        .disabled(
            !preferences.masterEnabled
        )
        .accessibilityHint(
            preferences.masterEnabled
            ? ""
            : "Enable BUILT reminders to edit this schedule"
        )
    }

    private var milestoneSection: some View {
        BuiltSettingsSection(
            title: "Milestones",
            symbolName: "trophy"
        ) {
            Toggle(
                isOn:
                    $preferences.milestonesEnabled
            ) {
                HStack(
                    alignment: .top,
                    spacing:
                        BuiltTheme.Spacing.medium
                ) {
                    Image(
                        systemName:
                            "trophy.fill"
                    )
                    .font(.body.weight(.semibold))
                    .foregroundStyle(
                        BuiltTheme.accent
                    )
                    .frame(
                        width: 40,
                        height: 40
                    )
                    .background(
                        BuiltTheme.accent
                            .opacity(0.11),
                        in: Circle()
                    )
                    .accessibilityHidden(true)

                    VStack(
                        alignment: .leading,
                        spacing:
                            BuiltTheme.Spacing.xSmall
                    ) {
                        Text(
                            "Celebrate major streaks"
                        )
                        .font(
                            .headline
                            .weight(.semibold)
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )

                        Text(
                            "2 days, 3 days, 1 week, 30 days, and beyond."
                        )
                        .font(.caption)
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                    }
                }
            }
            .tint(BuiltTheme.accent)
            .frame(
                minHeight:
                    BuiltTheme.minimumTapTarget
            )
        }
        .opacity(
            preferences.masterEnabled
            ? 1
            : 0.48
        )
        .disabled(
            !preferences.masterEnabled
        )
    }

    private var bottomAction: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(
                    BuiltTheme.hairline
                )

            Button {
                Task {
                    await handleBottomAction()
                }
            } label: {
                HStack(spacing: 12) {
                    if isWorking {
                        ProgressView()
                            .tint(
                                bottomButtonForeground
                            )
                            .accessibilityHidden(true)
                    } else {
                        Image(
                            systemName:
                                bottomButtonIcon
                        )
                        .accessibilityHidden(true)
                    }

                    Text(bottomButtonTitle)

                    Spacer()

                    if !isWorking {
                        Image(
                            systemName:
                                "arrow.right"
                        )
                        .accessibilityHidden(true)
                    }
                }
            }
            .modifier(
                NotificationBottomButtonModifier(
                    useSecondaryStyle:
                        authorizationStatus == .denied
                )
            )
            .disabled(isWorking)
            .padding(
                .horizontal,
                BuiltTheme.Spacing
                    .screenHorizontal
            )
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }

    private func reminderRow(
        title: String,
        subtitle: String,
        symbolName: String,
        isOn: Binding<Bool>,
        time: Binding<Date>
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            Toggle(isOn: isOn) {
                HStack(
                    alignment: .top,
                    spacing:
                        BuiltTheme.Spacing.medium
                ) {
                    Image(systemName: symbolName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(
                            BuiltTheme.accent
                        )
                        .frame(
                            width: 40,
                            height: 40
                        )
                        .background(
                            BuiltTheme.accent
                                .opacity(0.11),
                            in: Circle()
                        )
                        .accessibilityHidden(true)

                    VStack(
                        alignment: .leading,
                        spacing:
                            BuiltTheme.Spacing.xSmall
                    ) {
                        Text(title)
                            .font(
                                .headline
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
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    }
                }
            }
            .tint(BuiltTheme.accent)
            .frame(
                minHeight:
                    BuiltTheme.minimumTapTarget
            )

            if isOn.wrappedValue {
                Group {
                    if dynamicTypeSize.isAccessibilitySize {
                        VStack(
                            alignment: .leading,
                            spacing:
                                BuiltTheme.Spacing.small
                        ) {
                            Text("Delivery time")
                                .font(
                                    .subheadline
                                    .weight(.semibold)
                                )
                                .foregroundStyle(
                                    BuiltTheme.textSecondary
                                )

                            DatePicker(
                                "Delivery time",
                                selection: time,
                                displayedComponents:
                                    .hourAndMinute
                            )
                            .labelsHidden()
                        }
                    } else {
                        DatePicker(
                            "Delivery time",
                            selection: time,
                            displayedComponents:
                                .hourAndMinute
                        )
                    }
                }
                .datePickerStyle(.compact)
                .tint(BuiltTheme.accent)
                .padding(14)
                .background(
                    BuiltTheme.elevatedStrong,
                    in: RoundedRectangle(
                        cornerRadius:
                            BuiltTheme.smallRadius,
                        style: .continuous
                    )
                )
            }
        }
    }

    private func timeBinding(
        hour: Binding<Int>,
        minute: Binding<Int>
    ) -> Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour:
                        hour.wrappedValue,
                    minute:
                        minute.wrappedValue,
                    second: 0,
                    of: .now
                ) ?? .now
            },
            set: { newValue in
                let components =
                    Calendar.current
                        .dateComponents(
                            [.hour, .minute],
                            from: newValue
                        )

                hour.wrappedValue =
                    components.hour
                    ?? 8

                minute.wrappedValue =
                    components.minute
                    ?? 0
            }
        )
    }

    private var canSchedule: Bool {
        switch authorizationStatus {
        case .authorized,
             .provisional,
             .ephemeral:
            return true
        default:
            return false
        }
    }

    private var permissionShortStatus: String {
        switch authorizationStatus {
        case .notDetermined:
            return "NOT SET"
        case .denied:
            return "OFF"
        case .authorized:
            return "ALLOWED"
        case .provisional:
            return "QUIET"
        case .ephemeral:
            return "TEMPORARY"
        @unknown default:
            return "UNKNOWN"
        }
    }

    private var permissionStatusTitle: String {
        switch authorizationStatus {
        case .authorized:
            return
                "Notifications are allowed"
        case .provisional:
            return
                "Notifications are delivered quietly"
        case .ephemeral:
            return
                "Notifications are temporarily allowed"
        default:
            return "Notification access"
        }
    }

    private var permissionStatusMessage: String {
        switch authorizationStatus {
        case .authorized:
            return
                "Alerts can appear according to the schedule below."
        case .provisional:
            return
                "iOS may place reminders in Notification Center without interrupting you."
        case .ephemeral:
            return
                "iOS has granted temporary access for this session."
        default:
            return
                "Notification access has not been configured."
        }
    }

    private var permissionIcon: String {
        switch authorizationStatus {
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

    private var permissionColor: Color {
        authorizationStatus == .denied
        ? BuiltTheme.danger
        : BuiltTheme.accent
    }

    private var bottomButtonTitle: String {
        switch authorizationStatus {
        case .notDetermined:
            return
                "Enable notifications"
        case .denied:
            return
                "Open iPhone Settings"
        default:
            return isWorking
                ? "Saving schedule…"
                : "Save reminder schedule"
        }
    }

    private var bottomButtonIcon: String {
        authorizationStatus == .denied
        ? "gear"
        : "bell.badge"
    }

    private var bottomButtonForeground: Color {
        authorizationStatus == .denied
        ? BuiltTheme.textPrimary
        : .black
    }

    @MainActor
    private func handleBottomAction() async {
        switch authorizationStatus {
        case .notDetermined:
            await requestPermission()
        case .denied:
            openAppSettings()
        default:
            await saveSchedule()
        }
    }

    @MainActor
    private func requestPermission() async {
        guard !isWorking else {
            return
        }

        isWorking = true
        statusMessage = nil

        defer {
            isWorking = false
        }

        let granted =
            await NotificationManager.shared
                .requestAuthorization()

        await refreshAuthorizationStatus()

        if granted {
            preferences.masterEnabled = true
            NotificationPreferencesStore
                .save(preferences)

            await scheduleCurrentPreferences()

            statusKind = .success
            statusMessage =
                "Notifications are enabled and your current schedule is active."
            Haptics.success()
        } else {
            statusKind = .warning
            statusMessage =
                "Notification permission was not granted. You can continue using every core BUILT feature without reminders."
            Haptics.warning()
        }
    }

    @MainActor
    private func saveSchedule() async {
        guard !isWorking else {
            return
        }

        isWorking = true
        statusMessage = nil

        defer {
            isWorking = false
        }

        NotificationPreferencesStore
            .save(preferences)

        await scheduleCurrentPreferences()

        statusKind = .success
        statusMessage =
            preferences.masterEnabled
            ? "Your local reminder schedule has been updated."
            : "All BUILT reminders are paused. Your schedule remains saved."

        Haptics.success()
    }

    @MainActor
    private func refreshAuthorizationStatus() async {
        authorizationStatus =
            await NotificationManager.shared
                .authorizationStatus()
    }

    private func openAppSettings() {
        guard let settingsURL = URL(
            string:
                UIApplication.openSettingsURLString
        ) else {
            return
        }

        openURL(settingsURL)
    }

    private func scheduleCurrentPreferences() async {
        let scheduleProfile =
            NotificationScheduleProfile(
                quitDate: profile.quitDate,
                identityStatement:
                    profile.identityStatement
            )

        await NotificationManager.shared
            .schedule(
                preferences: preferences,
                profile: scheduleProfile
            )
    }
}

private struct NotificationBottomButtonModifier:
    ViewModifier {
    let useSecondaryStyle: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if useSecondaryStyle {
            content.buttonStyle(
                BuiltSecondaryButtonStyle()
            )
        } else {
            content.buttonStyle(
                BuiltPrimaryButtonStyle()
            )
        }
    }
}
