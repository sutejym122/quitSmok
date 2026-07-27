import SwiftUI

struct RestorePurchasesView: View {
    @EnvironmentObject
    private var storeManager: StoreManager

    @Environment(\.dismiss)
    private var dismiss

    private var title: String {
        switch storeManager.status {
        case .restoring:
            return "Checking your purchases…"

        case .restored:
            return "BUILT Pro restored"

        default:
            return storeManager.hasPro
                ? "BUILT Pro is active"
                : "Restore BUILT Pro"
        }
    }

    private var message: String {
        switch storeManager.status {
        case .restoring:
            return "BUILT is securely refreshing purchase history from the App Store."

        case .restored:
            return "Your lifetime purchase is available on this device."

        default:
            return storeManager.hasPro
                ? "You can recheck the App Store at any time. Restoring never charges you again."
                : "Use the same Apple Account that originally purchased BUILT Pro."
        }
    }

    private var symbolName: String {
        switch storeManager.status {
        case .restoring:
            return "arrow.triangle.2.circlepath"

        case .restored:
            return "checkmark.seal.fill"

        default:
            return storeManager.hasPro
                ? "checkmark.seal.fill"
                : "arrow.clockwise.circle.fill"
        }
    }

    private var restoreButtonTitle: String {
        if storeManager.status == .restoring {
            return "Restoring…"
        }

        return storeManager.hasPro
            ? "Check App Store purchases"
            : "Restore purchases"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                VStack(spacing: 26) {
                    Spacer()

                    Image(systemName: symbolName)
                        .font(
                            .system(
                                size: 64,
                                weight: .light
                            )
                        )
                        .foregroundStyle(
                            BuiltTheme.accent
                        )

                    VStack(spacing: 10) {
                        Text(title)
                            .font(
                                .system(
                                    size: 30,
                                    weight: .bold
                                )
                            )
                            .tracking(-0.8)
                            .foregroundStyle(
                                BuiltTheme.textPrimary
                            )
                            .multilineTextAlignment(
                                .center
                            )

                        Text(message)
                            .font(.system(size: 15))
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

                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await storeManager
                                    .restorePurchases()
                            }
                        } label: {
                            HStack {
                                if storeManager.status
                                    == .restoring {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Image(
                                        systemName:
                                            "arrow.clockwise"
                                    )
                                }

                                Text(
                                    restoreButtonTitle
                                )

                                Spacer()

                                if storeManager.status
                                    == .restored {
                                    Image(
                                        systemName:
                                            "checkmark"
                                    )
                                }
                            }
                        }
                        .buttonStyle(
                            BuiltPrimaryButtonStyle()
                        )
                        .disabled(storeManager.isBusy)
                        .opacity(
                            storeManager.isBusy
                            ? 0.65
                            : 1
                        )

                        if storeManager.hasPro {
                            Button("Done") {
                                dismiss()
                            }
                            .buttonStyle(
                                BuiltSecondaryButtonStyle()
                            )
                        }
                    }

                    Text(
                        "Restoring does not create a new purchase or charge your Apple Account. It only refreshes an existing lifetime entitlement."
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 30)
            }
            .navigationTitle("Restore")
            .navigationBarTitleDisplayMode(
                .inline
            )
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
                    placement: .topBarLeading
                ) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                }
            }
        }
        .interactiveDismissDisabled(
            storeManager.status == .restoring
        )
        .alert(item: $storeManager.purchaseError) {
            error in
            Alert(
                title: Text(
                    error.errorDescription
                    ?? "Restore unavailable"
                ),
                message: Text(
                    error.recoverySuggestion
                    ?? ""
                ),
                dismissButton: .default(
                    Text("OK")
                )
            )
        }
        .onDisappear {
            storeManager.clearPresentationState()
        }
    }
}
