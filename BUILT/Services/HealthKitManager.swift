import Foundation
import HealthKit
import Observation

@MainActor
@Observable
final class HealthKitManager {
    enum HealthKitError: LocalizedError {
        case unavailable
        case missingDataTypes
        case authorizationFailed
        case invalidWorkoutSamples

        var errorDescription: String? {
            switch self {
            case .unavailable:
                return "Health data is not available on this device."

            case .missingDataTypes:
                return "BUILT could not prepare the required HealthKit data types."

            case .authorizationFailed:
                return "Health access could not be requested. Please try again."

            case .invalidWorkoutSamples:
                return "BUILT received workout data in an unexpected format."
            }
        }
    }

    private static let authorizationRequestedKey =
        "built.healthkit.authorization.requested.v1"

    private let healthStore = HKHealthStore()

    private(set) var workouts: [WorkoutSummary] = []
    private(set) var totalActiveKilocalories: Double = 0
    private(set) var totalExerciseMinutes: Double = 0
    private(set) var isLoading = false
    private(set) var lastUpdated: Date?
    private(set) var errorMessage: String?

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    var hasRequestedAuthorization: Bool {
        UserDefaults.standard.bool(
            forKey: Self.authorizationRequestedKey
        )
    }

    func prepare(since quitDate: Date) async {
        guard isAvailable else {
            errorMessage = HealthKitError.unavailable.localizedDescription
            return
        }

        guard hasRequestedAuthorization else {
            return
        }

        await refresh(since: quitDate)
    }

    func requestAuthorization(since quitDate: Date) async {
        guard isAvailable else {
            errorMessage = HealthKitError.unavailable.localizedDescription
            return
        }

        guard let types = healthTypes else {
            errorMessage = HealthKitError.missingDataTypes.localizedDescription
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let completed = try await requestAuthorization(
                readTypes: types
            )

            guard completed else {
                throw HealthKitError.authorizationFailed
            }

            UserDefaults.standard.set(
                true,
                forKey: Self.authorizationRequestedKey
            )

            await refresh(since: quitDate)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func refresh(since quitDate: Date) async {
        guard isAvailable else {
            errorMessage = HealthKitError.unavailable.localizedDescription
            return
        }

        isLoading = true
        errorMessage = nil

        let startDate = min(quitDate, Date.now)

        do {
            workouts = try await fetchWorkouts(
                since: startDate
            )

            totalActiveKilocalories = try await fetchCumulativeQuantity(
                identifier: .activeEnergyBurned,
                unit: .kilocalorie(),
                since: startDate
            )

            totalExerciseMinutes = try await fetchCumulativeQuantity(
                identifier: .appleExerciseTime,
                unit: .minute(),
                since: startDate
            )

            lastUpdated = .now
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private var healthTypes: Set<HKObjectType>? {
        guard
            let activeEnergy = HKQuantityType.quantityType(
                forIdentifier: .activeEnergyBurned
            ),
            let exerciseTime = HKQuantityType.quantityType(
                forIdentifier: .appleExerciseTime
            )
        else {
            return nil
        }

        return [
            HKObjectType.workoutType(),
            activeEnergy,
            exerciseTime
        ]
    }

    private func requestAuthorization(
        readTypes: Set<HKObjectType>
    ) async throws -> Bool {
        try await withCheckedThrowingContinuation {
            (
                continuation:
                    CheckedContinuation<Bool, Error>
            ) in

            healthStore.requestAuthorization(
                toShare: Set<HKSampleType>(),
                read: readTypes
            ) { success, error in
                if let error {
                    continuation.resume(
                        throwing: error
                    )
                    return
                }

                continuation.resume(
                    returning: success
                )
            }
        }
    }

    private func fetchWorkouts(
        since startDate: Date
    ) async throws -> [WorkoutSummary] {
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: .now,
            options: .strictStartDate
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )

        return try await withCheckedThrowingContinuation {
            (
                continuation:
                    CheckedContinuation<[WorkoutSummary], Error>
            ) in

            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error {
                    continuation.resume(
                        throwing: error
                    )
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(
                        throwing:
                            HealthKitError.invalidWorkoutSamples
                    )
                    return
                }

                let summaries = workouts.map {
                    WorkoutSummary(workout: $0)
                }

                continuation.resume(
                    returning: summaries
                )
            }

            healthStore.execute(query)
        }
    }

    private func fetchCumulativeQuantity(
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        since startDate: Date
    ) async throws -> Double {
        guard let quantityType = HKQuantityType.quantityType(
            forIdentifier: identifier
        ) else {
            throw HealthKitError.missingDataTypes
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: .now,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation {
            (
                continuation:
                    CheckedContinuation<Double, Error>
            ) in

            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error {
                    continuation.resume(
                        throwing: error
                    )
                    return
                }

                let total = statistics?
                    .sumQuantity()?
                    .doubleValue(for: unit)
                    ?? 0

                continuation.resume(
                    returning: total
                )
            }

            healthStore.execute(query)
        }
    }
}
