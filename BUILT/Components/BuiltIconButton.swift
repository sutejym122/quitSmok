import SwiftUI

struct BuiltIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    var accessibilityHint: String? = nil
    var isEnabled = true
    let action: () -> Void

    @Environment(\.accessibilityReduceTransparency)
    private var reduceTransparency

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(
                    .body
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary.opacity(
                        isEnabled ? 1 : 0.42
                    )
                )
                .frame(
                    width:
                        BuiltTheme.minimumTapTarget,
                    height:
                        BuiltTheme.minimumTapTarget
                )
                .background {
                    Circle()
                        .fill(
                            reduceTransparency
                            ? BuiltTheme.elevatedStrong
                            : BuiltTheme.elevated
                                .opacity(0.70)
                        )
                        .background {
                            if !reduceTransparency {
                                Circle()
                                    .fill(
                                        .ultraThinMaterial
                                    )
                            }
                        }
                        .overlay {
                            Circle()
                                .stroke(
                                    BuiltTheme.hairline,
                                    lineWidth: 1
                                )
                        }
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(
            accessibilityLabel
        )
        .accessibilityHint(
            accessibilityHint ?? ""
        )
    }
}
