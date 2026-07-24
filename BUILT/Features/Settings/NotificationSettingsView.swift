import SwiftUI
import UserNotifications
import UIKit

struct NotificationSettingsView: View {
    let profile: QuitProfile

    @Environment(\.openURL)
    private var openURL

    @State private var preferences = NotificationPreferencesStore.load()
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isWorking = false
    @State private var statusMessage: String?

    var body: some View {
        ZStack {
            AmbientBackground()

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {
                    introduction
                    permissionCard
                    reminderSchedule
                    milestoneCard
                    primaryAction
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await refreshAuthorizationStatus()
        }
        .onChange(of: preferences) { _, newValue in
            NotificationPreferencesStore.save(newValue)
        }
        .onDisappear {
            NotificationPreferencesStore.save(preferences)

            Task {
                await scheduleCurrentPreferences()
            }
        }
    }

    private var introduction: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text("SYSTEM PRESENCE")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1.8)
                .foregroundStyle(BuiltTheme.accent)

            Text("Let BUILT reach you before the craving does.")
                .font(
                    .system(
                        size: 34,
                        weight: .bold
                    )
                )
                .tracking(-1.1)
                .foregroundStyle(BuiltTheme.textPrimary)

            Text(
                "Use only the reminders that feel useful. Everything is scheduled locally on your iPhone."
            )
            .font(.system(size: 15))
            .foregroundStyle(BuiltTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var permissionCard: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            HStack(spacing: 14) {
                Image(systemName: permissionIcon)
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(permissionColor)
                    .frame(width: 42, height: 42)
                    .background(
                        permissionColor.opacity(0.12),
                        in: Circle()
                    )

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text("Notification access")
                        .font(
                            .system(
                                size: 17,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(BuiltTheme.textPrimary)

                    Text(permissionStatusText)
                        .font(.system(size: 13))
                        .foregroundStyle(BuiltTheme.textSecondary)
                }

                Spacer()
            }

            if isAuthorized {
                Toggle(
                    "Enable BUILT reminders",
                    isOn: $preferences.masterEnabled
                )
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .tint(BuiltTheme.accent)
            }
        }
        .builtCard()
    }

    private var reminderSchedule: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            sectionTitle(
                title: "Daily reminders",
                icon: "clock"
            )

            reminderRow(
                title: "Morning identity",
                subtitle: "Start the day with your reason.",
                isOn: $preferences.morningEnabled,
                time: timeBinding(
                    hour: $preferences.morningHour,
                    minute: $preferences.morningMinute
                )
            )

            Divider()
                .overlay(BuiltTheme.hairline)

            reminderRow(
                title: "Evening progress",
                subtitle: "Recognize another protected day.",
                isOn: $preferences.eveningEnabled,
                time: timeBinding(
                    hour: $preferences.eveningHour,
                    minute: $preferences.eveningMinute
                )
            )

            Divider()
                .overlay(BuiltTheme.hairline)

            reminderRow(
                title: "High-risk time",
                subtitle: "Set the hour cravings usually appear.",
                isOn: $preferences.riskEnabled,
                time: timeBinding(
                    hour: $preferences.riskHour,
                    minute: $preferences.riskMinute
                )
            )
        }
        .opacity(preferences.masterEnabled ? 1 : 0.48)
        .disabled(!preferences.masterEnabled)
        .builtCard()
    }

    private var milestoneCard: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            sectionTitle(
                title: "Milestones",
                icon: "trophy"
            )

            Toggle(
                isOn: $preferences.milestonesEnabled
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text("Celebrate major streaks")
                        .font(
                            .system(
                                size: 15,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(BuiltTheme.textPrimary)

                    Text("2 days, 3 days, 1 week, 30 days, and beyond.")
                        .font(.system(size: 12))
                        .foregroundStyle(BuiltTheme.textSecondary)
                }
            }
            .tint(BuiltTheme.accent)
        }
        .opacity(preferences.masterEnabled ? 1 : 0.48)
        .disabled(!preferences.masterEnabled)
        .builtCard()
    }

    private var primaryAction: some View {
        VStack(spacing: 12) {
            if authorizationStatus == .denied {
                Button {
                    Task {
                        await handlePrimaryAction()
                    }
                } label: {
                    primaryActionLabel
                }
                .buttonStyle(BuiltSecondaryButtonStyle())
                .disabled(isWorking)
            } else {
                Button {
                    Task {
                        await handlePrimaryAction()
                    }
                } label: {
                    primaryActionLabel
                }
                .buttonStyle(BuiltPrimaryButtonStyle())
                .disabled(isWorking)
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(
                        .system(
                            size: 12,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(BuiltTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var primaryActionLabel: some View {
        HStack {
            if isWorking {
                ProgressView()
                    .tint(primaryButtonForeground)
            } else {
                Image(systemName: primaryButtonIcon)
            }

            Text(primaryButtonTitle)

            Spacer()

            if !isWorking {
                Image(systemName: "arrow.right")
            }
        }
    }

    private func reminderRow(
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        time: Binding<Date>
    ) -> some View {
        VStack(spacing: 14) {
            Toggle(isOn: isOn) {
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(title)
                        .font(
                            .system(
                                size: 15,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(BuiltTheme.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(BuiltTheme.textSecondary)
                }
            }
            .tint(BuiltTheme.accent)

            if isOn.wrappedValue {
                DatePicker(
                    "Delivery time",
                    selection: time,
                    displayedComponents: .hourAndMinute
                )
                .font(
                    .system(
                        size: 13,
                        weight: .medium
                    )
                )
                .datePickerStyle(.compact)
                .tint(BuiltTheme.accent)
            }
        }
    }

    private func sectionTitle(
        title: String,
        icon: String
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(BuiltTheme.accent)
                .frame(width: 24)

            Text(title)
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundStyle(BuiltTheme.textPrimary)
        }
    }

    private func timeBinding(
        hour: Binding<Int>,
        minute: Binding<Int>
    ) -> Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: hour.wrappedValue,
                    minute: minute.wrappedValue,
                    second: 0,
                    of: .now
                ) ?? .now
            },
            set: { newValue in
                let components = Calendar.current.dateComponents(
                    [.hour, .minute],
                    from: newValue
                )

                hour.wrappedValue = components.hour ?? 8
                minute.wrappedValue = components.minute ?? 0
            }
        )
    }

    private var isAuthorized: Bool {
        authorizationStatus == .authorized
            || authorizationStatus == .provisional
    }

    private var permissionStatusText: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Not requested yet"
        case .denied:
            return "Disabled in iPhone Settings"
        case .authorized:
            return "Allowed"
        case .provisional:
            return "Delivered quietly"
        case .ephemeral:
            return "Temporarily allowed"
        @unknown default:
            return "Unknown"
        }
    }

    private var permissionIcon: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "bell.badge.fill"
        case .denied:
            return "bell.slash.fill"
        default:
            return "bell.fill"
        }
    }

    private var permissionColor: Color {
        authorizationStatus == .denied
            ? BuiltTheme.danger
            : BuiltTheme.accent
    }

    private var primaryButtonTitle: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Enable notifications"
        case .denied:
            return "Open iPhone Settings"
        default:
            return "Save reminder schedule"
        }
    }

    private var primaryButtonIcon: String {
        authorizationStatus == .denied
            ? "gear"
            : "bell.badge"
    }

    private var primaryButtonForeground: Color {
        authorizationStatus == .denied
            ? BuiltTheme.textPrimary
            : .black
    }

    @MainActor
    private func handlePrimaryAction() async {
        isWorking = true
        statusMessage = nil

        defer {
            isWorking = false
        }

        switch authorizationStatus {
        case .notDetermined:
            let granted = await NotificationManager.shared.requestAuthorization()
            await refreshAuthorizationStatus()

            if granted {
                preferences.masterEnabled = true
                NotificationPreferencesStore.save(preferences)
                await scheduleCurrentPreferences()
                statusMessage = "Notifications are enabled and scheduled."
                Haptics.success()
            } else {
                statusMessage = "Notification permission was not granted."
                Haptics.warning()
            }

        case .denied:
            guard let settingsURL = URL(
                string: UIApplication.openSettingsURLString
            ) else {
                return
            }

            openURL(settingsURL)

        default:
            NotificationPreferencesStore.save(preferences)
            await scheduleCurrentPreferences()
            statusMessage = preferences.masterEnabled
                ? "Your reminders have been updated."
                : "BUILT reminders are turned off."
            Haptics.success()
        }
    }

    @MainActor
    private func refreshAuthorizationStatus() async {
        authorizationStatus = await NotificationManager.shared.authorizationStatus()
    }

    private func scheduleCurrentPreferences() async {
        let scheduleProfile = NotificationScheduleProfile(
            quitDate: profile.quitDate,
            identityStatement: profile.identityStatement
        )

        await NotificationManager.shared.schedule(
            preferences: preferences,
            profile: scheduleProfile
        )
    }
}
