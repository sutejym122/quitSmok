import Foundation

@MainActor
enum RecoveryTimelineService {
    private static let minute: TimeInterval = 60
    private static let hour: TimeInterval = 3_600
    private static let day: TimeInterval = 86_400
    private static let year: TimeInterval = 365 * day

    static let milestones: [RecoveryMilestone] = [
        RecoveryMilestone(
            id: "heart-rate-20-minutes",
            threshold: 20 * minute,
            timeLabel: "20 MINUTES",
            title: "Your heart is already responding",
            summary: "Your heart rate starts moving back toward its usual level.",
            detail: "Recovery begins quickly after the last cigarette. This is an early population-level milestone, not a personal medical measurement.",
            symbolName: "heart.fill",
            sourceName: "CDC",
            sourceURLString: "https://archive.cdc.gov/www_cdc_gov/tobacco/sgr/2004/posters/20mins/index.htm"
        ),
        RecoveryMilestone(
            id: "oxygen-8-hours",
            threshold: 8 * hour,
            timeLabel: "8 HOURS",
            title: "More room for oxygen",
            summary: "Oxygen levels are recovering and carbon monoxide in the blood may be reduced by about half.",
            detail: "Carbon monoxide from smoke competes with oxygen in the blood. Stopping exposure lets the balance begin to recover.",
            symbolName: "waveform.path.ecg",
            sourceName: "NHS",
            sourceURLString: "https://www.nhs.uk/better-health/quit-smoking/ready-to-quit-smoking/what-could-happen-when-you-quit-smoking/"
        ),
        RecoveryMilestone(
            id: "carbon-monoxide-12-hours",
            threshold: 12 * hour,
            timeLabel: "12 HOURS",
            title: "Carbon monoxide falls",
            summary: "Carbon monoxide in the blood can fall to a normal level.",
            detail: "This is one of the first major internal changes after quitting and supports normal oxygen transport.",
            symbolName: "drop.fill",
            sourceName: "CDC",
            sourceURLString: "https://archive.cdc.gov/www_cdc_gov/tobacco/sgr/2004/posters/20mins/index.htm"
        ),
        RecoveryMilestone(
            id: "taste-smell-48-hours",
            threshold: 48 * hour,
            timeLabel: "48 HOURS",
            title: "Taste and smell can sharpen",
            summary: "Carbon monoxide reaches nonsmoker levels, while taste and smell may begin improving.",
            detail: "The lungs also begin clearing mucus and smoking debris. Individual experiences vary.",
            symbolName: "sparkles",
            sourceName: "NHS",
            sourceURLString: "https://www.nhs.uk/better-health/quit-smoking/ready-to-quit-smoking/what-could-happen-when-you-quit-smoking/"
        ),
        RecoveryMilestone(
            id: "breathing-72-hours",
            threshold: 72 * hour,
            timeLabel: "72 HOURS",
            title: "Breathing may feel easier",
            summary: "The bronchial tubes begin to relax and energy levels may start to improve.",
            detail: "Some people notice easier breathing around this point, while others need more time.",
            symbolName: "wind",
            sourceName: "NHS",
            sourceURLString: "https://www.nhs.uk/better-health/quit-smoking/ready-to-quit-smoking/what-could-happen-when-you-quit-smoking/"
        ),
        RecoveryMilestone(
            id: "circulation-2-weeks",
            threshold: 14 * day,
            timeLabel: "2 WEEKS",
            title: "Circulation begins improving",
            summary: "You enter the window in which circulation and lung function begin to improve.",
            detail: "The CDC describes this improvement across roughly two weeks to three months after quitting.",
            symbolName: "figure.walk",
            sourceName: "CDC",
            sourceURLString: "https://archive.cdc.gov/www_cdc_gov/tobacco/sgr/2004/posters/20mins/index.htm"
        ),
        RecoveryMilestone(
            id: "lung-function-3-months",
            threshold: 90 * day,
            timeLabel: "3 MONTHS",
            title: "Stronger circulation and lung function",
            summary: "You have completed the CDC's two-week-to-three-month recovery window.",
            detail: "Exercise may feel different as circulation and lung function improve, though the amount varies from person to person.",
            symbolName: "lungs.fill",
            sourceName: "CDC",
            sourceURLString: "https://archive.cdc.gov/www_cdc_gov/tobacco/sgr/2004/posters/20mins/index.htm"
        ),
        RecoveryMilestone(
            id: "coughing-9-months",
            threshold: 270 * day,
            timeLabel: "9 MONTHS",
            title: "Coughing and breathlessness can ease",
            summary: "You complete the one-to-nine-month window in which coughing and shortness of breath often decrease.",
            detail: "Airway recovery is gradual. Persistent or worsening symptoms deserve medical attention.",
            symbolName: "waveform",
            sourceName: "CDC",
            sourceURLString: "https://archive.cdc.gov/www_cdc_gov/tobacco/sgr/2004/posters/20mins/index.htm"
        ),
        RecoveryMilestone(
            id: "heart-disease-1-year",
            threshold: year,
            timeLabel: "1 YEAR",
            title: "A major heart-risk milestone",
            summary: "The added risk of coronary heart disease is about half that of a person who continues smoking.",
            detail: "This milestone reflects population-level risk. Personal risk also depends on health history and other factors.",
            symbolName: "heart.circle.fill",
            sourceName: "CDC",
            sourceURLString: "https://archive.cdc.gov/www_cdc_gov/tobacco/sgr/2004/posters/20mins/index.htm"
        ),
        RecoveryMilestone(
            id: "cancer-stroke-5-years",
            threshold: 5 * year,
            timeLabel: "5 YEARS",
            title: "Long-term risks keep falling",
            summary: "Risks for several smoking-related cancers are substantially lower, and stroke risk continues moving toward that of a nonsmoker.",
            detail: "The exact timing differs by condition. Staying smoke-free keeps these risk reductions moving in the right direction.",
            symbolName: "shield.fill",
            sourceName: "CDC",
            sourceURLString: "https://archive.cdc.gov/www_cdc_gov/tobacco/sgr/2004/posters/20mins/index.htm"
        ),
        RecoveryMilestone(
            id: "lung-cancer-10-years",
            threshold: 10 * year,
            timeLabel: "10 YEARS",
            title: "Lung-cancer risk falls sharply",
            summary: "The risk of dying from lung cancer is about half that of a person who continues smoking.",
            detail: "Risks for cancers of the larynx and pancreas also decrease over time after quitting.",
            symbolName: "lungs",
            sourceName: "CDC",
            sourceURLString: "https://www.cdc.gov/tobacco/about/benefits-of-quitting.html"
        ),
        RecoveryMilestone(
            id: "heart-disease-15-years",
            threshold: 15 * year,
            timeLabel: "15 YEARS",
            title: "Heart-disease risk reaches a landmark",
            summary: "Coronary heart disease risk approaches that of a person who does not smoke.",
            detail: "Fifteen years is a powerful reminder that the benefits of quitting continue for a very long time.",
            symbolName: "checkmark.seal.fill",
            sourceName: "CDC",
            sourceURLString: "https://archive.cdc.gov/www_cdc_gov/tobacco/sgr/2004/posters/20mins/index.htm"
        )
    ]

    static func snapshot(
        quitDate: Date,
        now: Date = .now
    ) -> RecoveryTimelineSnapshot {
        let elapsed = max(0, now.timeIntervalSince(quitDate))
        let completed = milestones.filter { elapsed >= $0.threshold }
        let next = milestones.first { elapsed < $0.threshold }
        let previousThreshold = completed.last?.threshold ?? 0

        let progress: Double
        let remainingText: String

        if let next {
            let interval = max(1, next.threshold - previousThreshold)
            progress = min(
                max((elapsed - previousThreshold) / interval, 0),
                1
            )
            remainingText = formattedDuration(
                max(0, next.threshold - elapsed)
            )
        } else {
            progress = 1
            remainingText = "All listed milestones reached"
        }

        return RecoveryTimelineSnapshot(
            elapsed: elapsed,
            completedMilestones: completed,
            nextMilestone: next,
            progressToNext: progress,
            remainingText: remainingText
        )
    }

    static func formattedDuration(_ interval: TimeInterval) -> String {
        let totalMinutes = max(0, Int((interval / 60).rounded(.up)))
        let totalHours = totalMinutes / 60
        let days = totalHours / 24
        let hours = totalHours % 24
        let minutes = totalMinutes % 60

        if days >= 365 {
            let years = days / 365
            let remainingDays = days % 365
            return remainingDays > 0
                ? "\(years)y \(remainingDays)d remaining"
                : "\(years)y remaining"
        }

        if days >= 30 {
            let months = days / 30
            let remainingDays = days % 30
            return remainingDays > 0
                ? "\(months)mo \(remainingDays)d remaining"
                : "\(months)mo remaining"
        }

        if days > 0 {
            return hours > 0
                ? "\(days)d \(hours)h remaining"
                : "\(days)d remaining"
        }

        if totalHours > 0 {
            return minutes > 0
                ? "\(totalHours)h \(minutes)m remaining"
                : "\(totalHours)h remaining"
        }

        return "\(max(1, minutes))m remaining"
    }
}

@MainActor
enum RecoveryCelebrationStore {
    private static let signatureKey = "built.recovery.celebration.signature.v1"
    private static let seenKey = "built.recovery.celebration.seen.v1"

    static func consumeNewestUnseen(
        quitDate: Date,
        now: Date = .now
    ) -> RecoveryMilestone? {
        let defaults = UserDefaults.standard
        let signature = String(Int(quitDate.timeIntervalSince1970))

        if defaults.string(forKey: signatureKey) != signature {
            defaults.set(signature, forKey: signatureKey)
            defaults.removeObject(forKey: seenKey)
        }

        let completed = RecoveryTimelineService
            .snapshot(quitDate: quitDate, now: now)
            .completedMilestones

        guard !completed.isEmpty else {
            return nil
        }

        var seen = Set(defaults.stringArray(forKey: seenKey) ?? [])
        let unseen = completed.filter { !seen.contains($0.id) }

        guard let newest = unseen.last else {
            return nil
        }

        completed.forEach { seen.insert($0.id) }
        defaults.set(Array(seen), forKey: seenKey)
        return newest
    }

    static func reset() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: signatureKey)
        defaults.removeObject(forKey: seenKey)
    }
}
