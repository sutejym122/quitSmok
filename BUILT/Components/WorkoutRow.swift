import SwiftUI

struct WorkoutRow: View {
    let workout: WorkoutSummary

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: workout.symbolName)
                .font(
                    .system(
                        size: 20,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )
                .frame(
                    width: 46,
                    height: 46
                )
                .background(
                    BuiltTheme.accent.opacity(0.11),
                    in: Circle()
                )

            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text(workout.title)
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.textPrimary
                    )

                HStack(spacing: 6) {
                    Text(workout.formattedDuration)

                    if let energy = workout.formattedEnergy {
                        Text("·")
                        Text(energy)
                    }
                }
                .font(.system(size: 12))
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
            }

            Spacer()

            VStack(
                alignment: .trailing,
                spacing: 4
            ) {
                Text(
                    workout.startDate,
                    format: .dateTime
                        .month(.abbreviated)
                        .day()
                )
                .font(
                    .system(
                        size: 13,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

                Text(
                    workout.startDate,
                    format: .dateTime
                        .hour()
                        .minute()
                )
                .font(.system(size: 11))
                .foregroundStyle(
                    BuiltTheme.textSecondary
                )
            }
        }
        .builtCard(padding: 14)
    }
}
