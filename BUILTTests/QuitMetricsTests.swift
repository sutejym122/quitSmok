import Foundation
import Testing

@testable import BUILT

@Suite("Quit Metrics")
struct QuitMetricsTests {
    @Test(
        "Calculates elapsed time cigarettes and money"
    )
    func calculatesCoreMetrics() {
        let oneDay: TimeInterval = 86_400
        let twoHours: TimeInterval = 7_200
        let threeMinutes: TimeInterval = 180
        let fourSeconds: TimeInterval = 4

        let elapsed =
            oneDay
            + twoHours
            + threeMinutes
            + fourSeconds

        let quitDate =
            BuiltTestFixtures
                .referenceDate
                .addingTimeInterval(
                    -elapsed
                )

        let profile =
            BuiltTestFixtures.makeProfile(
                quitDate: quitDate,
                cigarettesPerDay: 20,
                cigarettesPerPack: 20,
                packPrice: 15
            )

        let metrics = QuitMetrics(
            profile: profile,
            now:
                BuiltTestFixtures
                    .referenceDate
        )

        #expect(metrics.elapsed == elapsed)
        #expect(metrics.days == 1)
        #expect(metrics.hours == 2)
        #expect(metrics.minutes == 3)
        #expect(metrics.seconds == 4)
        #expect(metrics.timerText == "02:03:04")
        #expect(metrics.dayLabel == "DAY")

        let elapsedDays =
            elapsed / oneDay

        let cigarettesAvoidedExact =
            elapsedDays * 20.0

        let expectedCigarettesAvoided =
            Int(
                floor(
                    cigarettesAvoidedExact
                )
            )

        #expect(
            metrics.cigarettesAvoided
            == expectedCigarettesAvoided
        )

        let packsAvoided =
            cigarettesAvoidedExact
            / 20.0

        let expectedMoney =
            packsAvoided * 15.0

        let moneyMatches =
            BuiltTestFixtures
                .approximatelyEqual(
                    metrics.moneySaved,
                    expectedMoney
                )

        #expect(moneyMatches)
    }

    @Test(
        "Future quit dates clamp every metric to zero"
    )
    func futureQuitDateClampsToZero() {
        let futureDate =
            BuiltTestFixtures
                .referenceDate
                .addingTimeInterval(
                    3_600
                )

        let profile =
            BuiltTestFixtures.makeProfile(
                quitDate: futureDate
            )

        let metrics = QuitMetrics(
            profile: profile,
            now:
                BuiltTestFixtures
                    .referenceDate
        )

        #expect(metrics.elapsed == 0)
        #expect(metrics.days == 0)
        #expect(metrics.hours == 0)
        #expect(metrics.minutes == 0)
        #expect(metrics.seconds == 0)
        #expect(metrics.cigarettesAvoided == 0)
        #expect(metrics.moneySaved == 0)
        #expect(metrics.timerText == "00:00:00")
        #expect(metrics.dayLabel == "DAYS")
    }

    @Test(
        "Negative smoking values never create negative progress"
    )
    func negativeInputsClampSafely() {
        let quitDate =
            BuiltTestFixtures
                .referenceDate
                .addingTimeInterval(
                    -86_400
                )

        let profile =
            BuiltTestFixtures.makeProfile(
                quitDate: quitDate,
                cigarettesPerDay: -20,
                cigarettesPerPack: -5,
                packPrice: -15
            )

        let metrics = QuitMetrics(
            profile: profile,
            now:
                BuiltTestFixtures
                    .referenceDate
        )

        #expect(metrics.cigarettesAvoided == 0)
        #expect(metrics.moneySaved == 0)
    }

    @Test(
        "Zero pack size uses the safe minimum denominator"
    )
    func zeroPackSizeIsSafe() {
        let quitDate =
            BuiltTestFixtures
                .referenceDate
                .addingTimeInterval(
                    -86_400
                )

        let profile =
            BuiltTestFixtures.makeProfile(
                quitDate: quitDate,
                cigarettesPerDay: 10,
                cigarettesPerPack: 0,
                packPrice: 2
            )

        let metrics = QuitMetrics(
            profile: profile,
            now:
                BuiltTestFixtures
                    .referenceDate
        )

        #expect(metrics.cigarettesAvoided == 10)
        #expect(metrics.moneySaved == 20)
    }

    @Test(
        "Day label becomes plural outside exactly one day"
    )
    func dayLabelPluralization() {
        let oneDayQuitDate =
            BuiltTestFixtures
                .referenceDate
                .addingTimeInterval(
                    -86_400
                )

        let twoDayQuitDate =
            BuiltTestFixtures
                .referenceDate
                .addingTimeInterval(
                    -172_800
                )

        let oneDayProfile =
            BuiltTestFixtures.makeProfile(
                quitDate: oneDayQuitDate
            )

        let twoDayProfile =
            BuiltTestFixtures.makeProfile(
                quitDate: twoDayQuitDate
            )

        let oneDayMetrics =
            QuitMetrics(
                profile: oneDayProfile,
                now:
                    BuiltTestFixtures
                        .referenceDate
            )

        let twoDayMetrics =
            QuitMetrics(
                profile: twoDayProfile,
                now:
                    BuiltTestFixtures
                        .referenceDate
            )

        let oneDayLabel =
            oneDayMetrics.dayLabel

        let twoDayLabel =
            twoDayMetrics.dayLabel

        #expect(oneDayLabel == "DAY")
        #expect(twoDayLabel == "DAYS")
    }
}
