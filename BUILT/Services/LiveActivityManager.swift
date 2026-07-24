import Foundation
import ActivityKit

actor LiveActivityManager {
    static let shared = LiveActivityManager()

    private var currentActivity: Activity<CravingActivityAttributes>?
    private var currentEndDate: Date?

    func start(
        trigger: String,
        identityStatement: String,
        duration: TimeInterval = 60
    ) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        await end(
            message: "Rescue replaced by a new session.",
            immediate: true
        )

        let startedAt = Date.now
        let endDate = startedAt.addingTimeInterval(duration)

        let attributes = CravingActivityAttributes(
            startedAt: startedAt,
            trigger: trigger,
            identityStatement: identityStatement
        )

        let state = CravingActivityAttributes.ContentState(
            endDate: endDate,
            phase: "Breathe",
            message: "Slow inhale. Longer exhale.",
            isComplete: false
        )

        let content = ActivityContent(
            state: state,
            staleDate: endDate.addingTimeInterval(30)
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            currentEndDate = endDate
        } catch {
            currentActivity = nil
            currentEndDate = nil
        }
    }

    func moveToAction() async {
        guard
            let activity = currentActivity,
            let endDate = currentEndDate
        else {
            return
        }

        let state = CravingActivityAttributes.ContentState(
            endDate: endDate,
            phase: "Replace",
            message: "Choose one action and do it now.",
            isComplete: false
        )

        await activity.update(
            ActivityContent(
                state: state,
                staleDate: Date.now.addingTimeInterval(120)
            )
        )
    }

    func finish(didDefeatCraving: Bool) async {
        let message = didDefeatCraving
            ? "Craving defeated. Promise kept."
            : "Continue from the next decision."

        await end(message: message, immediate: false)
    }

    func cancel() async {
        await end(
            message: "Rescue ended.",
            immediate: true
        )
    }

    private func end(
        message: String,
        immediate: Bool
    ) async {
        guard let activity = currentActivity else {
            currentEndDate = nil
            return
        }

        let endDate = currentEndDate ?? .now
        let state = CravingActivityAttributes.ContentState(
            endDate: endDate,
            phase: "Complete",
            message: message,
            isComplete: true
        )

        let content = ActivityContent(
            state: state,
            staleDate: nil
        )

        await activity.end(
            content,
            dismissalPolicy: immediate
                ? .immediate
                : .after(Date.now.addingTimeInterval(4))
        )

        currentActivity = nil
        currentEndDate = nil
    }
}
