import Foundation
import HealthKit

struct WorkoutSummary: Identifiable, Hashable, Sendable {
    let id: UUID
    let activityTypeRawValue: UInt
    let title: String
    let symbolName: String
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let activeKilocalories: Double?

    init(workout: HKWorkout) {
        let presentation = Self.presentation(
            for: workout.workoutActivityType
        )

        id = workout.uuid
        activityTypeRawValue = workout.workoutActivityType.rawValue
        title = presentation.title
        symbolName = presentation.symbolName
        startDate = workout.startDate
        endDate = workout.endDate
        duration = workout.duration

        if let activeEnergyType = HKQuantityType.quantityType(
            forIdentifier: .activeEnergyBurned
        ) {
            activeKilocalories = workout
                .statistics(for: activeEnergyType)?
                .sumQuantity()?
                .doubleValue(for: .kilocalorie())
        } else {
            activeKilocalories = nil
        }
    }

    var durationMinutes: Int {
        max(1, Int((duration / 60).rounded()))
    }

    var formattedDuration: String {
        let totalMinutes = durationMinutes
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }

    var formattedEnergy: String? {
        guard let activeKilocalories,
              activeKilocalories > 0 else {
            return nil
        }

        return "\(Int(activeKilocalories.rounded())) kcal"
    }

    private static func presentation(
        for activityType: HKWorkoutActivityType
    ) -> (title: String, symbolName: String) {
        switch activityType {
        case .traditionalStrengthTraining:
            return ("Strength Training", "dumbbell.fill")

        case .functionalStrengthTraining:
            return ("Functional Strength", "figure.strengthtraining.functional")

        case .running:
            return ("Running", "figure.run")

        case .walking:
            return ("Walking", "figure.walk")

        case .cycling:
            return ("Cycling", "bicycle")

        case .swimming:
            return ("Swimming", "figure.pool.swim")

        case .highIntensityIntervalTraining:
            return ("HIIT", "bolt.heart.fill")

        case .coreTraining:
            return ("Core Training", "figure.core.training")

        case .crossTraining:
            return ("Cross Training", "figure.cross.training")

        case .elliptical:
            return ("Elliptical", "figure.elliptical")

        case .stairClimbing:
            return ("Stair Climbing", "figure.stairs")

        case .rowing:
            return ("Rowing", "figure.rower")

        case .yoga:
            return ("Yoga", "figure.yoga")

        case .flexibility:
            return ("Flexibility", "figure.flexibility")

        case .dance:
            return ("Dance", "figure.dance")

        case .hiking:
            return ("Hiking", "figure.hiking")

        case .mixedCardio:
            return ("Mixed Cardio", "heart.circle.fill")

        case .cooldown:
            return ("Cooldown", "figure.cooldown")

        case .pilates:
            return ("Pilates", "figure.pilates")

        case .kickboxing:
            return ("Kickboxing", "figure.kickboxing")

        case .boxing:
            return ("Boxing", "figure.boxing")

        case .basketball:
            return ("Basketball", "figure.basketball")

        case .soccer:
            return ("Soccer", "figure.soccer")

        case .tennis:
            return ("Tennis", "figure.tennis")

        case .badminton:
            return ("Badminton", "figure.badminton")

        case .pickleball:
            return ("Pickleball", "figure.pickleball")

        default:
            return ("Workout", "figure.mixed.cardio")
        }
    }
}
