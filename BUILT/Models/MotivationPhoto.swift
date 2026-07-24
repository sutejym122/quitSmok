import Foundation
import SwiftData

@Model
final class MotivationPhoto {
    @Attribute(.externalStorage)
    var imageData: Data

    var caption: String
    var isHero: Bool
    var createdAt: Date

    init(
        imageData: Data,
        caption: String = "I protect what I built.",
        isHero: Bool = false,
        createdAt: Date = .now
    ) {
        self.imageData = imageData
        self.caption = caption
        self.isHero = isHero
        self.createdAt = createdAt
    }
}
