import SwiftUI

struct ProBadge: View {
    var compact = false

    var body: some View {
        HStack(spacing: compact ? 5 : 7) {
            Image(systemName: "diamond.fill")
                .font(
                    .system(
                        size: compact ? 8 : 10,
                        weight: .bold
                    )
                )

            Text("PRO")
                .font(
                    .system(
                        size: compact ? 9 : 10,
                        weight: .black
                    )
                )
                .tracking(compact ? 1.0 : 1.4)
        }
        .foregroundStyle(Color.black)
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 5 : 7)
        .background(
            BuiltTheme.accent,
            in: Capsule()
        )
        .accessibilityLabel("BUILT Pro")
    }
}
