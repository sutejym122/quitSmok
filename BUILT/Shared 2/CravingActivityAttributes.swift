import Foundation
import ActivityKit

public struct CravingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var endDate: Date
        public var phase: String
        public var message: String
        public var isComplete: Bool

        public init(
            endDate: Date,
            phase: String,
            message: String,
            isComplete: Bool
        ) {
            self.endDate = endDate
            self.phase = phase
            self.message = message
            self.isComplete = isComplete
        }
    }

    public var startedAt: Date
    public var trigger: String
    public var identityStatement: String

    public init(
        startedAt: Date,
        trigger: String,
        identityStatement: String
    ) {
        self.startedAt = startedAt
        self.trigger = trigger
        self.identityStatement = identityStatement
    }
}
