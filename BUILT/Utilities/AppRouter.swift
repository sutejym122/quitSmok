import Foundation
import Observation

enum AppTab: Hashable {
    case today
    case rescue
    case proof
    case fitness
    case insights
}

@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .today
    var presentsRescue = false

    func handle(_ url: URL) {
        guard url.scheme?.lowercased() == BuiltSharedConstants.urlScheme else {
            return
        }

        switch url.host?.lowercased() {
        case "rescue":
            selectedTab = .rescue
            presentsRescue = true

        case "proof":
            selectedTab = .proof

        case "fitness":
            selectedTab = .fitness

        case "insights":
            selectedTab = .insights

        case "today":
            selectedTab = .today

        default:
            selectedTab = .today
        }
    }
}
