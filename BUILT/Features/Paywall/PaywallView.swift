import SwiftUI

struct PaywallView: View {
    let context: PaywallContext

    @EnvironmentObject
    private var storeManager: StoreManager

    @Environment(\.dismiss)
    private var dismiss

    @State private var showsRestore = false

    private let highlightedFeatures: [ProFeature] = [
        .unlimitedMotivationPhotos,
        .fitnessIntelligence,
        .advancedTriggerPatterns,
        .unlimitedRewardGoals,
        .premiumWidgets,
        .customReminders
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 26
                    ) {
                        hero
                        featureList
                        lifetimeCard
                        purchaseControls
                        trustMessage
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 36)
                }

                if storeManager.presentsPurchaseSuccess {
                    PurchaseSuccessView {
                        storeManager.clearPresentationState()
                        dismiss()
                    }
                    .zIndex(20)
                }
            }
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(
                                .system(
                                    size: 14,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(
                                BuiltTheme.textPrimary
                            )
                            .frame(width: 40, height: 40)
                            .background(
                                .ultraThinMaterial,
                                in: Circle()
                            )
                    }
                    .accessibilityLabel("Close BUILT Pro")
                }
            }
            .toolbarBackground(
                .hidden,
                for: .navigationBar
            )
        }
        .interactiveDismissDisabled(
            storeManager.status == .purchasing
        )
        .sheet(isPresented: $showsRestore) {
            RestorePurchasesView()
                .environmentObject(storeManager)
        }
        .task {
            await storeManager.prepare()
        }
        .onDisappear {
            if !storeManager.presentsPurchaseSuccess {
                storeManager.clearPresentationState()
            }
        }
        .alert(item: $storeManager.purchaseError) {
            error in
            Alert(
                title: Text(
                    error.errorDescription
                    ?? "Purchase unavailable"
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
    }

    private var hero: some View {
        VStack(
            alignment: .leading,
            spacing: 22
        ) {
            HStack {
                ProBadge()

                Spacer()

                Text("LIFETIME")
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .tracking(1.5)
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
            }

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(
                    cornerRadius: BuiltTheme.largeRadius,
                    style: .continuous
                )
                .fill(
                    LinearGradient(
                        colors: [
                            BuiltTheme.accent.opacity(0.30),
                            BuiltTheme.accentSoft.opacity(0.14),
                            BuiltTheme.elevated
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 260)

                Circle()
                    .fill(
                        BuiltTheme.accent.opacity(0.22)
                    )
                    .frame(width: 190, height: 190)
                    .blur(radius: 45)
                    .offset(x: 170, y: -70)

                VStack(
                    alignment: .leading,
                    spacing: 13
                ) {
                    Text(context.eyebrow)
                        .font(
                            .system(
                                size: 11,
                                weight: .bold
                            )
                        )
                        .tracking(1.9)
                        .foregroundStyle(
                            BuiltTheme.accent
                        )

                    Text(context.title)
                        .font(
                            .system(
                                size: 40,
                                weight: .bold
                            )
                        )
                        .tracking(-1.5)
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )
                        .minimumScaleFactor(0.76)

                    Text(context.message)
                        .font(
                            .system(
                                size: 15,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary.opacity(0.72)
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
                .padding(24)
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: BuiltTheme.largeRadius,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: BuiltTheme.largeRadius,
                    style: .continuous
                )
                .stroke(
                    BuiltTheme.hairline,
                    lineWidth: 1
                )
            }
        }
    }

    private var featureList: some View {
        VStack(
            alignment: .leading,
            spacing: 18
        ) {
            Text("THE COMPLETE SYSTEM")
                .font(
                    .system(
                        size: 11,
                        weight: .bold
                    )
                )
                .tracking(1.7)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            VStack(spacing: 18) {
                ForEach(highlightedFeatures) {
                    feature in
                    ProFeatureRow(feature: feature)
                }
            }
            .builtCard(padding: 20)
        }
    }

    private var lifetimeCard: some View {
        HStack(spacing: 16) {
            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text("One purchase")
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                Text("No subscription. No recurring bill.")
                    .font(.system(size: 13))
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
            }

            Spacer()

            Text(
                storeManager.displayPrice
                ?? "Loading…"
            )
            .font(
                .system(
                    size: 26,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                BuiltTheme.accent
            )
        }
        .builtCard(padding: 19)
    }

    private var purchaseControls: some View {
        VStack(spacing: 12) {
            if storeManager.hasPro {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(
                            systemName:
                                "checkmark.seal.fill"
                        )
                        Text("BUILT Pro is active")
                        Spacer()
                    }
                }
                .buttonStyle(
                    BuiltPrimaryButtonStyle()
                )
            } else {
                Button {
                    Task {
                        await storeManager.purchasePro()
                    }
                } label: {
                    HStack {
                        if storeManager.status == .purchasing {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Image(
                                systemName:
                                    "diamond.fill"
                            )
                        }

                        Text(purchaseButtonTitle)
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(
                    BuiltPrimaryButtonStyle()
                )
                .disabled(
                    storeManager.proProduct == nil
                    || storeManager.isBusy
                )
                .opacity(
                    storeManager.proProduct == nil
                    || storeManager.isBusy
                    ? 0.60
                    : 1
                )
            }

            Button("Restore purchases") {
                showsRestore = true
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
            .disabled(storeManager.isBusy)
        }
    }

    private var purchaseButtonTitle: String {
        if storeManager.status == .purchasing {
            return "Completing purchase…"
        }

        if let price = storeManager.displayPrice {
            return "Unlock lifetime access · \(price)"
        }

        return "Loading App Store price…"
    }

    private var trustMessage: some View {
        VStack(spacing: 8) {
            Label(
                "Emergency Rescue and core quitting tools remain free.",
                systemImage: "heart.fill"
            )

            Text(
                "Purchases are processed by Apple. Restore is available on devices using the same Apple Account."
            )
        }
        .font(.system(size: 12))
        .foregroundStyle(
            BuiltTheme.textSecondary
        )
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
    }
}
