import ActivityKit
import WidgetKit
import SwiftUI

struct CravingLiveActivityWidget: Widget {
    private let accent = Color(
        red: 0.64,
        green: 1.00,
        blue: 0.62
    )

    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: CravingActivityAttributes.self
        ) { context in
            lockScreenView(context: context)
                .activityBackgroundTint(
                    Color(
                        red: 0.025,
                        green: 0.027,
                        blue: 0.035
                    )
                )
                .activitySystemActionForegroundColor(.white)
                .widgetURL(BuiltSharedConstants.rescueURL)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "bolt.heart.fill")
                        .foregroundStyle(accent)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    if shouldShowTimer(context.state) {
                        Text(context.state.endDate, style: .timer)
                            .font(
                                .system(
                                    size: 15,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .monospacedDigit()
                            .foregroundStyle(accent)
                    } else {
                        Image(systemName: "checkmark")
                            .foregroundStyle(accent)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    Text("CRAVING RESCUE")
                        .font(
                            .system(
                                size: 11,
                                weight: .bold
                            )
                        )
                        .tracking(1.2)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 5) {
                        Text(context.state.message)
                            .font(
                                .system(
                                    size: 14,
                                    weight: .semibold
                                )
                            )
                            .multilineTextAlignment(.center)

                        Text(context.attributes.identityStatement)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                Image(systemName: "bolt.heart.fill")
                    .foregroundStyle(accent)
            } compactTrailing: {
                if shouldShowTimer(context.state) {
                    Text(context.state.endDate, style: .timer)
                        .font(
                            .system(
                                size: 12,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .monospacedDigit()
                        .foregroundStyle(accent)
                        .frame(width: 42)
                } else {
                    Image(systemName: "checkmark")
                        .foregroundStyle(accent)
                }
            } minimal: {
                Image(systemName: "bolt.heart.fill")
                    .foregroundStyle(accent)
            }
            .widgetURL(BuiltSharedConstants.rescueURL)
            .keylineTint(accent)
        }
    }

    private func lockScreenView(
        context: ActivityViewContext<CravingActivityAttributes>
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "bolt.heart.fill")
                .font(
                    .system(
                        size: 22,
                        weight: .semibold
                    )
                )
                .foregroundStyle(accent)
                .frame(width: 48, height: 48)
                .background(
                    accent.opacity(0.13),
                    in: Circle()
                )

            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text("BUILT RESCUE")
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )
                    .tracking(1.4)
                    .foregroundStyle(accent)

                Text(context.state.message)
                    .font(
                        .system(
                            size: 15,
                            weight: .semibold
                        )
                    )
                    .lineLimit(2)

                Text("Trigger: \(context.attributes.trigger)")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            if shouldShowTimer(context.state) {
                Text(context.state.endDate, style: .timer)
                    .font(
                        .system(
                            size: 24,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .monospacedDigit()
                    .foregroundStyle(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(accent)
            }
        }
        .padding(16)
    }

    private func shouldShowTimer(
        _ state: CravingActivityAttributes.ContentState
    ) -> Bool {
        !state.isComplete && state.phase == "Breathe"
    }
}
