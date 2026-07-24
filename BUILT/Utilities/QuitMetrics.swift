import Foundation

struct QuitMetrics {
    let elapsed: TimeInterval
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
    let cigarettesAvoided: Int
    let moneySaved: Double

    init(
        profile: QuitProfile,
        now: Date = .now
    ) {
        let elapsed = max(
            0,
            now.timeIntervalSince(
                profile.quitDate
            )
        )

        self.elapsed = elapsed

        let totalSeconds = Int(elapsed)

        self.days = totalSeconds / 86_400

        self.hours =
            (totalSeconds % 86_400) / 3_600

        self.minutes =
            (totalSeconds % 3_600) / 60

        self.seconds =
            totalSeconds % 60

        let avoided =
            (elapsed / 86_400)
            * max(
                0,
                profile.cigarettesPerDay
            )

        self.cigarettesAvoided =
            Int(floor(avoided))

        let packSize = max(
            1,
            profile.cigarettesPerPack
        )

        self.moneySaved =
            avoided
            / packSize
            * max(
                0,
                profile.packPrice
            )
    }

    var timerText: String {
        String(
            format: "%02d:%02d:%02d",
            hours,
            minutes,
            seconds
        )
    }

    var dayLabel: String {
        days == 1 ? "DAY" : "DAYS"
    }
}
