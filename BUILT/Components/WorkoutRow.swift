import SwiftUI

struct WorkoutRow: View {
    let workout: WorkoutSummary

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    @ScaledMetric(relativeTo: .body)
    private var iconContainerSize: CGFloat = 48

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(
                    alignment: .leading,
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    HStack(
                        spacing:
                            BuiltTheme.Spacing.medium
                    ) {
                        icon
                        titleBlock
                    }

                    Divider()
                        .overlay(
                            BuiltTheme.hairline
                        )

                    dateBlock
                }
            } else {
                HStack(
                    spacing: BuiltTheme.Spacing.medium
                ) {
                    icon
                    titleBlock
                    Spacer()
                    dateBlock
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 15)
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            workout.title
        )
        .accessibilityValue(
            [
                workout.formattedDuration,
                workout.formattedEnergy,
                workout.startDate.formatted(
                    date: .abbreviated,
                    time: .shortened
                )
            ]
            .compactMap { $0 }
            .joined(separator: ", ")
        )
    }

    private var icon: some View {
        Image(
            systemName:
                workout.symbolName
        )
        .font(
            .title3
            .weight(.semibold)
        )
        .foregroundStyle(
            BuiltTheme.accent
        )
        .frame(
            width: iconContainerSize,
            height: iconContainerSize
        )
        .background(
            BuiltTheme.accent.opacity(0.11),
            in: Circle()
        )
        .accessibilityHidden(true)
    }

    private var titleBlock: some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.xSmall
        ) {
            Text(workout.title)
                .font(
                    .headline
                    .weight(.semibold)
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            HStack(spacing: 6) {
                Text(
                    workout.formattedDuration
                )

                if let energy =
                    workout.formattedEnergy {
                    Text("·")
                    Text(energy)
                }
            }
            .font(.caption)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
    }

    private var dateBlock: some View {
        VStack(
            alignment:
                dynamicTypeSize.isAccessibilitySize
                ? .leading
                : .trailing,
            spacing: BuiltTheme.Spacing.xSmall
        ) {
            Text(
                workout.startDate,
                format:
                    .dateTime
                    .month(.abbreviated)
                    .day()
            )
            .font(
                .subheadline
                .weight(.semibold)
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )

            Text(
                workout.startDate,
                format:
                    .dateTime
                    .hour()
                    .minute()
            )
            .font(.caption)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
        }
    }
}
