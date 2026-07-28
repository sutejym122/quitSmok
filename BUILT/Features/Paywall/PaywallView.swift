import SwiftUI

struct PaywallView: View {
    let context: PaywallContext

    @EnvironmentObject
    private var storeManager: StoreManager

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @State private var showsRestore = false

    private var highlightedFeatures:
        [ProFeature] {
        context.highlightedFeatures
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing:
                            BuiltTheme.Spacing
                                .xLarge
                    ) {
                        hero
                        featureList
                        lifetimeCard
                        purchaseControls
                        trustMessage
                    }
                    .padding(
                        .horizontal,
                        BuiltTheme.Spacing
                            .screenHorizontal
                    )
                    .padding(.top, 10)
                    .padding(.bottom, 38)
                }
                .scrollIndicators(.hidden)

                if storeManager
                    .presentsPurchaseSuccess {
                    PurchaseSuccessView {
                        storeManager
                            .clearPresentationState()
                        dismiss()
                    }
                    .zIndex(20)
                }
            }
            .toolbar {
                ToolbarItem(
                    placement: .topBarLeading
                ) {
                    BuiltIconButton(
                        systemName: "xmark",
                        accessibilityLabel:
                            "Close BUILT Pro",
                        isEnabled:
                            storeManager.status
                            != .purchasing
                    ) {
                        dismiss()
                    }
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
        .sheet(
            isPresented: $showsRestore
        ) {
            RestorePurchasesView()
                .environmentObject(
                    storeManager
                )
        }
        .task {
            await storeManager.prepare()
        }
        .onDisappear {
            if !storeManager
                .presentsPurchaseSuccess {
                storeManager
                    .clearPresentationState()
            }
        }
        .alert(
            item:
                $storeManager.purchaseError
        ) { error in
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
            spacing: BuiltTheme.Spacing.large
        ) {
            if dynamicTypeSize
                .isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing:
                        BuiltTheme.Spacing.medium
                ) {
                    ProBadge()
                    lifetimeLabel
                }
            } else {
                HStack {
                    ProBadge()
                    Spacer()
                    lifetimeLabel
                }
            }

            ZStack(
                alignment: .bottomLeading
            ) {
                RoundedRectangle(
                    cornerRadius:
                        BuiltTheme.largeRadius,
                    style: .continuous
                )
                .fill(
                    LinearGradient(
                        colors: [
                            BuiltTheme.accent
                                .opacity(0.32),
                            BuiltTheme.accentSoft
                                .opacity(0.16),
                            BuiltTheme.elevated
                        ],
                        startPoint:
                            .topLeading,
                        endPoint:
                            .bottomTrailing
                    )
                )

                Circle()
                    .fill(
                        BuiltTheme.accent
                            .opacity(0.20)
                    )
                    .frame(
                        width: 190,
                        height: 190
                    )
                    .blur(radius: 45)
                    .offset(
                        x: 170,
                        y: -70
                    )
                    .accessibilityHidden(true)

                VStack(
                    alignment: .leading,
                    spacing:
                        BuiltTheme.Spacing.medium
                ) {
                    Text(context.eyebrow)
                        .font(
                            .caption
                            .weight(.bold)
                        )
                        .tracking(
                            dynamicTypeSize
                                .isAccessibilitySize
                            ? 0.7
                            : 1.6
                        )
                        .foregroundStyle(
                            BuiltTheme.accent
                        )

                    Text(context.title)
                        .font(
                            dynamicTypeSize
                                .isAccessibilitySize
                            ? .title.weight(.bold)
                            : .largeTitle
                                .weight(.bold)
                        )
                        .tracking(
                            dynamicTypeSize
                                .isAccessibilitySize
                            ? 0
                            : -1.2
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    Text(context.message)
                        .font(.body)
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                                .opacity(0.78)
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
                .padding(24)
            }
            .frame(
                minHeight:
                    dynamicTypeSize
                        .isAccessibilitySize
                    ? 330
                    : 270
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius:
                        BuiltTheme.largeRadius,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius:
                        BuiltTheme.largeRadius,
                    style: .continuous
                )
                .stroke(
                    BuiltTheme.hairline,
                    lineWidth: 1
                )
            }
            .accessibilityElement(
                children: .combine
            )
        }
    }

    private var lifetimeLabel: some View {
        Text("LIFETIME")
            .font(
                .caption2
                .weight(.bold)
            )
            .tracking(1.3)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
    }

    private var featureList: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.large
        ) {
            SectionHeader(
                eyebrow:
                    "The complete system",
                title:
                    "Everything BUILT protects"
            )

            LazyVStack(
                spacing:
                    BuiltTheme.Spacing.large
            ) {
                ForEach(
                    highlightedFeatures
                ) { feature in
                    ProFeatureRow(
                        feature: feature
                    )
                }
            }
            .builtCard(padding: 20)
        }
    }

    private var lifetimeCard: some View {
        Group {
            if dynamicTypeSize
                .isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing:
                        BuiltTheme.Spacing.medium
                ) {
                    lifetimeCopy
                    priceLabel
                }
            } else {
                HStack(
                    spacing:
                        BuiltTheme.Spacing.medium
                ) {
                    lifetimeCopy
                    Spacer()
                    priceLabel
                }
            }
        }
        .builtCard(padding: 19)
        .accessibilityElement(
            children: .combine
        )
    }

    private var lifetimeCopy: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.xSmall
        ) {
            Text("One purchase")
                .font(
                    .headline
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            Text(
                "No subscription. No recurring bill."
            )
            .font(.subheadline)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
    }

    private var priceLabel: some View {
        Text(
            storeManager.displayPrice
            ?? "Loading…"
        )
        .font(
            .title2
            .weight(.bold)
            .monospacedDigit()
        )
        .foregroundStyle(
            BuiltTheme.accent
        )
    }

    private var purchaseControls: some View {
        VStack(
            spacing: BuiltTheme.Spacing.small
        ) {
            if storeManager.hasPro {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(
                            systemName:
                                "checkmark.seal.fill"
                        )
                        .accessibilityHidden(true)

                        Text(
                            "BUILT Pro is active"
                        )

                        Spacer()

                        Image(
                            systemName:
                                "arrow.right"
                        )
                        .accessibilityHidden(true)
                    }
                }
                .buttonStyle(
                    BuiltPrimaryButtonStyle()
                )
            } else {
                Button {
                    Task {
                        await storeManager
                            .purchasePro()
                    }
                } label: {
                    HStack(spacing: 12) {
                        if storeManager.status
                            == .purchasing {
                            ProgressView()
                                .tint(.black)
                                .accessibilityHidden(
                                    true
                                )
                        } else {
                            Image(
                                systemName:
                                    "diamond.fill"
                            )
                            .accessibilityHidden(
                                true
                            )
                        }

                        Text(
                            purchaseButtonTitle
                        )

                        Spacer()

                        Image(
                            systemName:
                                "arrow.right"
                        )
                        .accessibilityHidden(true)
                    }
                }
                .buttonStyle(
                    BuiltPrimaryButtonStyle()
                )
                .disabled(
                    storeManager.proProduct == nil
                    || storeManager.isBusy
                )
            }

            Button {
                showsRestore = true
            } label: {
                Label(
                    "Restore purchases",
                    systemImage:
                        "arrow.clockwise"
                )
            }
            .buttonStyle(
                BuiltTertiaryButtonStyle()
            )
            .disabled(storeManager.isBusy)
        }
    }

    private var purchaseButtonTitle: String {
        if storeManager.status
            == .purchasing {
            return "Completing purchase…"
        }

        if let price =
            storeManager.displayPrice {
            return
                "Unlock lifetime access · \(price)"
        }

        return "Loading App Store price…"
    }

    private var trustMessage: some View {
        VStack(
            spacing: BuiltTheme.Spacing.small
        ) {
            Label(
                "Emergency Rescue and core quitting tools remain free.",
                systemImage: "heart.fill"
            )
            .font(
                .footnote
                .weight(.semibold)
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )

            Text(
                "Purchases are processed by Apple. Restore is available on devices using the same Apple Account."
            )
            .font(.footnote)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .accessibilityElement(
            children: .combine
        )
    }
}
