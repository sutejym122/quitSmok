import Foundation
import Observation

enum AppTab: Hashable {
    case today
    case rescue
    case proof
    case fitness
    case growth
}

enum GrowthSection: String, CaseIterable, Identifiable, Hashable {
    case recovery
    case rewards
    case patterns

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .recovery:
            return "Recovery"

        case .rewards:
            return "Rewards"

        case .patterns:
            return "Patterns"
        }
    }

    var symbolName: String {
        switch self {
        case .recovery:
            return "heart.text.square.fill"

        case .rewards:
            return "gift.fill"

        case .patterns:
            return "chart.xyaxis.line"
        }
    }
}

@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .today
    var selectedGrowthSection: GrowthSection = .recovery
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

        case "growth", "progress", "recovery":
            selectedTab = .growth
            selectedGrowthSection = .recovery

        case "rewards":
            selectedTab = .growth
            selectedGrowthSection = .rewards

        case "insights", "patterns":
            selectedTab = .growth
            selectedGrowthSection = .patterns

        case "today":
            selectedTab = .today

        default:
            selectedTab = .today
        }
    }
}
