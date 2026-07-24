import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var profile: QuitProfile

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @Query
    private var cravings: [CravingEntry]

    @Query
    private var photos: [MotivationPhoto]

    @State private var showingResetAlert = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 24
                    ) {
                        identitySection
                        quitDateSection
                        smokingPatternSection
                        systemPresenceSection
                        dataSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(BuiltTheme.accent)
                }
            }
        }
        .onChange(of: profile.currencyCode) { _, newValue in
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
            "Reset your smoke-free timer?",
            isPresented: $showingResetAlert
        ) {
            Button(
                "Reset to now",
                role: .destructive
            ) {
                profile.quitDate = .now
                profile.slipCount += 1

                try? modelContext.save()
                Haptics.warning()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "Your craving history and photos stay saved. Only the current timer restarts."
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

            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "This permanently removes your profile, craving history, imported photo copies, widgets, and scheduled reminders."
            )
        }
    }

    private var identitySection: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            settingTitle(
                "Identity statement",
                icon: "quote.opening"
            )

            TextField(
                "Reason for quitting",
                text: $profile.identityStatement,
                axis: .vertical
            )
            .lineLimit(3...6)
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
        }
        .builtCard()
    }

    private var quitDateSection: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            settingTitle(
                "Smoke-free start",
                icon: "calendar"
            )

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

            Button {
                showingResetAlert = true
            } label: {
                Text("Reset counter to now")
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(BuiltTheme.danger)
            }
        }
        .builtCard()
    }

    private var smokingPatternSection: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            settingTitle(
                "Calculation settings",
                icon: "function"
            )

            editableNumberRow(
                title: "Cigarettes per day",
                value: $profile.cigarettesPerDay
            )

            Divider()
                .overlay(BuiltTheme.hairline)

            editableNumberRow(
                title: "Cigarettes per pack",
                value: $profile.cigarettesPerPack
            )

            Divider()
                .overlay(BuiltTheme.hairline)

            HStack {
                Text("Pack price")
                    .font(
                        .system(
                            size: 15,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(BuiltTheme.textPrimary)

                Spacer()

                TextField(
                    "15",
                    value: $profile.packPrice,
                    format: .number.precision(
                        .fractionLength(0...2)
                    )
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(
                    .system(
                        size: 17,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .frame(width: 88)

                TextField(
                    "USD",
                    text: $profile.currencyCode
                )
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .multilineTextAlignment(.center)
                .font(
                    .system(
                        size: 13,
                        weight: .bold,
                        design: .monospaced
                    )
                )
                .frame(width: 56)
                .padding(.vertical, 8)
                .background(
                    Color.white.opacity(0.07),
                    in: Capsule()
                )
            }
        }
        .builtCard()
    }

    private var systemPresenceSection: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            settingTitle(
                "System presence",
                icon: "iphone.gen3.radiowaves.left.and.right"
            )

            NavigationLink {
                NotificationSettingsView(profile: profile)
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(BuiltTheme.accent)
                        .frame(width: 30)

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {
                        Text("Notifications")
                            .font(
                                .system(
                                    size: 15,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(BuiltTheme.textPrimary)

                        Text("Identity, progress, and high-risk reminders")
                            .font(.system(size: 12))
                            .foregroundStyle(BuiltTheme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(
                            .system(
                                size: 13,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(BuiltTheme.textSecondary)
                }
            }
            .buttonStyle(.plain)

            Divider()
                .overlay(BuiltTheme.hairline)

            HStack(spacing: 14) {
                Image(systemName: "rectangle.stack.badge.plus")
                    .foregroundStyle(BuiltTheme.accent)
                    .frame(width: 30)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text("Widgets and Live Activity")
                        .font(
                            .system(
                                size: 15,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(BuiltTheme.textPrimary)

                    Text("Add BUILT from the Home Screen or Lock Screen gallery.")
                        .font(.system(size: 12))
                        .foregroundStyle(BuiltTheme.textSecondary)
                }
            }
        }
        .builtCard()
    }

    private var dataSection: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            settingTitle(
                "Your data",
                icon: "lock.shield"
            )

            HStack {
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text("Stored on this device")
                        .font(
                            .system(
                                size: 15,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(BuiltTheme.textPrimary)

                    Text(
                        "\(cravings.count) cravings · \(photos.count) photos"
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(BuiltTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "iphone")
                    .foregroundStyle(BuiltTheme.accent)
            }

            Divider()
                .overlay(BuiltTheme.hairline)

            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete all app data")
                    Spacer()
                }
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .foregroundStyle(BuiltTheme.danger)
            }
        }
        .builtCard()
    }

    private func settingTitle(
        _ title: String,
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

    private func editableNumberRow(
        title: String,
        value: Binding<Double>
    ) -> some View {
        HStack {
            Text(title)
                .font(
                    .system(
                        size: 15,
                        weight: .medium
                    )
                )
                .foregroundStyle(BuiltTheme.textPrimary)

            Spacer()

            TextField(
                "0",
                value: value,
                format: .number.precision(
                    .fractionLength(0...1)
                )
            )
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .font(
                .system(
                    size: 17,
                    weight: .semibold,
                    design: .rounded
                )
            )
            .frame(width: 88)
        }
    }

    private func deleteEverything() {
        for craving in cravings {
            modelContext.delete(craving)
        }

        for photo in photos {
            modelContext.delete(photo)
        }

        modelContext.delete(profile)
        try? modelContext.save()

        WidgetSyncService.clear()
        NotificationPreferencesStore.reset()

        Task {
            await NotificationManager.shared.cancelAll()
            await LiveActivityManager.shared.cancel()
        }

        dismiss()
    }
}
