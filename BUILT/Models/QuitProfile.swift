import Foundation
import SwiftData

@Model
final class QuitProfile {
    var quitDate: Date
    var cigarettesPerDay: Double
    var cigarettesPerPack: Double
    var packPrice: Double
    var currencyCode: String
    var identityStatement: String
    var slipCount: Int
    var createdAt: Date

    init(
        quitDate: Date,
        cigarettesPerDay: Double,
        cigarettesPerPack: Double,
        packPrice: Double,
        currencyCode: String,
        identityStatement: String,
        slipCount: Int = 0,
        createdAt: Date = .now
    ) {
        self.quitDate = quitDate
        self.cigarettesPerDay = cigarettesPerDay
        self.cigarettesPerPack = cigarettesPerPack
        self.packPrice = packPrice
        self.currencyCode = currencyCode
        self.identityStatement = identityStatement
        self.slipCount = slipCount
        self.createdAt = createdAt
    }
}
