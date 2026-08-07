import Foundation

struct BuiltPlanCompletion: Codable, Equatable, Identifiable, Sendable {
    let dayNumber: Int
    let completedAt: Date

    var id: Int {
        dayNumber
    }
}

struct BuiltPlanProgress: Codable, Equatable, Sendable {
    let plan: BuiltPlan
    private(set) var completions: [BuiltPlanCompletion]

    init(
        plan: BuiltPlan,
        completions: [BuiltPlanCompletion] = []
    ) {
        self.plan = plan
        self.completions = completions
    }

    var completedDayNumbers: Set<Int> {
        Set(completions.map(\.dayNumber))
    }

    var completedCount: Int {
        completedDayNumbers.count
    }

    var isFinished: Bool {
        completedCount >= plan.missions.count
    }

    var nextDayNumber: Int? {
        plan.missions
            .map(\.dayNumber)
            .first {
                !isCompleted(dayNumber: $0)
            }
    }

    var nextMission: BuiltPlanMission? {
        guard let nextDayNumber else {
            return nil
        }

        return plan.missions.first {
            $0.dayNumber == nextDayNumber
        }
    }

    func isCompleted(
        dayNumber: Int
    ) -> Bool {
        completedDayNumbers.contains(dayNumber)
    }

    func canAccess(
        dayNumber: Int,
        hasPro: Bool
    ) -> Bool {
        guard
            plan.missions.contains(
                where: {
                    $0.dayNumber == dayNumber
                }
            )
        else {
            return false
        }

        if dayNumber == 1 {
            return true
        }

        guard hasPro else {
            return false
        }

        return (1..<dayNumber)
            .allSatisfy {
                isCompleted(dayNumber: $0)
            }
    }

    mutating func complete(
        dayNumber: Int,
        at date: Date = .now
    ) {
        guard
            plan.missions.contains(
                where: {
                    $0.dayNumber == dayNumber
                }
            ),
            !isCompleted(dayNumber: dayNumber)
        else {
            return
        }

        completions.append(
            BuiltPlanCompletion(
                dayNumber: dayNumber,
                completedAt: date
            )
        )

        completions.sort {
            $0.dayNumber < $1.dayNumber
        }
    }
}
