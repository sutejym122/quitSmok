import Foundation

struct WorkoutDaySummary: Identifiable, Hashable {
    let date: Date
    let workoutCount: Int
    let workoutMinutes: Int

    var id: Date {
        date
    }
}

struct WorkoutMetrics {
    let workouts: [WorkoutSummary]
    let now: Date
    let calendar: Calendar

    init(
        workouts: [WorkoutSummary],
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        self.workouts = workouts
        self.now = now
        self.calendar = calendar
    }

    var totalWorkouts: Int {
        workouts.count
    }

    var totalWorkoutMinutes: Int {
        Int(
            workouts.reduce(0) {
                $0 + $1.duration
            } / 60
        )
    }

    var workoutsThisWeek: Int {
        guard let interval = calendar.dateInterval(
            of: .weekOfYear,
            for: now
        ) else {
            return 0
        }

        return workouts.filter {
            interval.contains($0.startDate)
        }
        .count
    }

    var currentStreak: Int {
        let days = workoutDays

        guard !days.isEmpty else {
            return 0
        }

        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(
            byAdding: .day,
            value: -1,
            to: today
        )!

        var cursor: Date

        if days.contains(today) {
            cursor = today
        } else if days.contains(yesterday) {
            cursor = yesterday
        } else {
            return 0
        }

        var streak = 0

        while days.contains(cursor) {
            streak += 1

            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: cursor
            ) else {
                break
            }

            cursor = previousDay
        }

        return streak
    }

    var longestStreak: Int {
        let sortedDays = workoutDays.sorted()

        guard !sortedDays.isEmpty else {
            return 0
        }

        var longest = 1
        var current = 1

        for index in 1..<sortedDays.count {
            let previous = sortedDays[index - 1]
            let currentDay = sortedDays[index]

            let difference = calendar.dateComponents(
                [.day],
                from: previous,
                to: currentDay
            ).day ?? 0

            if difference == 1 {
                current += 1
                longest = max(longest, current)
            } else if difference > 1 {
                current = 1
            }
        }

        return longest
    }

    var mostFrequentWorkout: String {
        let grouped = Dictionary(
            grouping: workouts,
            by: \.title
        )

        return grouped.max {
            lhs,
            rhs in

            if lhs.value.count == rhs.value.count {
                return lhs.key > rhs.key
            }

            return lhs.value.count < rhs.value.count
        }?.key ?? "No workouts"
    }

    var lastSevenDays: [WorkoutDaySummary] {
        let today = calendar.startOfDay(for: now)

        return (0..<7)
            .reversed()
            .compactMap { offset in
                guard
                    let date = calendar.date(
                        byAdding: .day,
                        value: -offset,
                        to: today
                    ),
                    let nextDate = calendar.date(
                        byAdding: .day,
                        value: 1,
                        to: date
                    )
                else {
                    return nil
                }

                let dayWorkouts = workouts.filter {
                    $0.startDate >= date
                    && $0.startDate < nextDate
                }

                let minutes = Int(
                    dayWorkouts.reduce(0) {
                        $0 + $1.duration
                    } / 60
                )

                return WorkoutDaySummary(
                    date: date,
                    workoutCount: dayWorkouts.count,
                    workoutMinutes: minutes
                )
            }
    }

    private var workoutDays: Set<Date> {
        Set(
            workouts.map {
                calendar.startOfDay(
                    for: $0.startDate
                )
            }
        )
    }
}
