import Foundation

struct RecoveryMilestone: Identifiable, Hashable, Sendable {
    let id: String
    let threshold: TimeInterval
    let timeLabel: String
    let title: String
    let summary: String
    let detail: String
    let symbolName: String
    let sourceName: String
    let sourceURLString: String

    var sourceURL: URL? {
        URL(string: sourceURLString)
    }
}

struct RecoveryTimelineSnapshot: Equatable, Sendable {
    let elapsed: TimeInterval
    let completedMilestones: [RecoveryMilestone]
    let nextMilestone: RecoveryMilestone?
    let progressToNext: Double
    let remainingText: String

    var completedCount: Int {
        completedMilestones.count
    }

    var latestCompleted: RecoveryMilestone? {
        completedMilestones.last
    }
}
