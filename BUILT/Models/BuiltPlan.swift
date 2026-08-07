import Foundation

struct BuiltPlan: Codable, Equatable, Sendable {
    let generatedAt: Date
    let title: String
    let subtitle: String
    let missions: [BuiltPlanMission]

    var durationDays: Int {
        missions.count
    }
}

struct BuiltPlanMission: Codable, Equatable, Identifiable, Sendable {
    let dayNumber: Int
    let focus: BuiltPlanFocus
    let title: String
    let detail: String
    let action: String
    let reason: String
    let symbolName: String

    var id: Int {
        dayNumber
    }
}

enum BuiltPlanFocus: String, Codable, Equatable, Sendable {
    case awareness
    case replacement
    case identity
    case motivation
    case preparation
    case environment
    case proof
}
