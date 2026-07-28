import SwiftUI

struct PurchaseSuccessView: View {
    let onContinue: () -> Void

    @State private var appears = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.82)
                .ignoresSafeArea()
                .onTapGesture {}

            VStack(spacing: 26) {
                ZStack {
                    Circle()
                        .fill(BuiltTheme.accent)
                        .frame(width: 112, height: 112)
                        .scaleEffect(appears ? 1 : 0.72)

                    Image(systemName: "checkmark")
                        .font(
                            .system(
                                size: 42,
                                weight: .black
                            )
                        )
                        .foregroundStyle(Color.black)
                }

                VStack(spacing: 10) {
                    Text("BUILT Pro unlocked.")
                        .font(
                            .system(
                                size: 34,
                                weight: .bold
                            )
                        )
                        .tracking(-1)
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )
                        .multilineTextAlignment(.center)

                    Text(
                        "One purchase. Lifetime access. Keep building the version of you that does not smoke."
                    )
                    .font(
                        .system(
                            size: 16,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                    .multilineTextAlignment(.center)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                }

                Button("Continue") {
                    onContinue()
                }
                .buttonStyle(BuiltPrimaryButtonStyle())
            }
            .padding(26)
            .frame(maxWidth: 420)
            .background(
                RoundedRectangle(
                    cornerRadius: BuiltTheme.largeRadius,
                    style: .continuous
                )
                .fill(BuiltTheme.elevated)
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
            )
            .padding(.horizontal, 22)
            .scaleEffect(appears ? 1 : 0.96)
            .opacity(appears ? 1 : 0)
        }
        .onAppear {
            withAnimation(
                .spring(
                    response: 0.45,
                    dampingFraction: 0.78
                )
            ) {
                appears = true
            }
        }
        .accessibilityAddTraits(.isModal)
    }
}
