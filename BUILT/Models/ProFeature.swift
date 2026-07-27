import Foundation

enum ProFeature: String, CaseIterable, Identifiable, Sendable {
    case unlimitedMotivationPhotos
    case fitnessIntelligence
    case advancedTriggerPatterns
    case unlimitedRewardGoals
    case fullRecoveryTimeline
    case premiumWidgets
    case customReminders
    case progressSharing
    case premiumThemes

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .unlimitedMotivationPhotos:
            return "Unlimited motivation photos"
        case .fitnessIntelligence:
            return "Complete fitness intelligence"
        case .advancedTriggerPatterns:
            return "Advanced trigger patterns"
        case .unlimitedRewardGoals:
            return "Unlimited reward goals"
        case .fullRecoveryTimeline:
            return "Complete recovery timeline"
        case .premiumWidgets:
            return "Premium widgets"
        case .customReminders:
            return "Custom motivation schedules"
        case .progressSharing:
            return "Milestone sharing"
        case .premiumThemes:
            return "Premium visual themes"
        }
    }

    var detail: String {
        switch self {
        case .unlimitedMotivationPhotos:
            return "Build a private physique and identity vault without photo limits."
        case .fitnessIntelligence:
            return "See active energy, training streaks, workout history, and deeper trends since quitting."
        case .advancedTriggerPatterns:
            return "Understand when cravings happen, what starts them, and which actions help most."
        case .unlimitedRewardGoals:
            return "Turn protected cigarette spending into as many meaningful targets as you need."
        case .fullRecoveryTimeline:
            return "Follow the complete evidence-based recovery journey from minutes to years."
        case .premiumWidgets:
            return "Keep richer progress, rewards, and motivation visible across iOS."
        case .customReminders:
            return "Choose the moments when identity, progress, and rescue reminders matter most."
        case .progressSharing:
            return "Create polished milestone cards without exposing private health details."
        case .premiumThemes:
            return "Personalize BUILT while preserving its focused, premium design."
        }
    }

    var symbolName: String {
        switch self {
        case .unlimitedMotivationPhotos:
            return "photo.stack.fill"
        case .fitnessIntelligence:
            return "figure.strengthtraining.traditional"
        case .advancedTriggerPatterns:
            return "chart.xyaxis.line"
        case .unlimitedRewardGoals:
            return "giftcard.fill"
        case .fullRecoveryTimeline:
            return "heart.text.clipboard.fill"
        case .premiumWidgets:
            return "rectangle.stack.badge.plus"
        case .customReminders:
            return "bell.badge.fill"
        case .progressSharing:
            return "square.and.arrow.up.fill"
        case .premiumThemes:
            return "sparkles"
        }
    }
}

enum PaywallContext: String, Identifiable, Sendable {
    case settings
    case motivationPhotos
    case fitness
    case patterns
    case rewardGoals
    case recovery
    case widgets
    case general

    var id: String {
        rawValue
    }

    var eyebrow: String {
        switch self {
        case .settings, .general:
            return "BUILT PRO"
        case .motivationPhotos:
            return "PHYSIQUE VAULT"
        case .fitness:
            return "FITNESS IDENTITY"
        case .patterns:
            return "TRIGGER INTELLIGENCE"
        case .rewardGoals:
            return "REWARD SYSTEM"
        case .recovery:
            return "RECOVERY JOURNEY"
        case .widgets:
            return "SYSTEM PRESENCE"
        }
    }

    var title: String {
        switch self {
        case .settings, .general:
            return "Go further than a counter."
        case .motivationPhotos:
            return "Keep every reason visible."
        case .fitness:
            return "Turn training into proof."
        case .patterns:
            return "Know what pulls you back."
        case .rewardGoals:
            return "Make quitting pay you."
        case .recovery:
            return "See the complete rebuild."
        case .widgets:
            return "Keep your progress in sight."
        }
    }

    var message: String {
        switch self {
        case .settings, .general:
            return "Unlock the complete fitness-driven quitting system with one lifetime purchase."
        case .motivationPhotos:
            return "Build an unlimited private library of the body, confidence, and life you are protecting."
        case .fitness:
            return "Unlock active-energy insights, training streaks, workout history, and deeper progress intelligence."
        case .patterns:
            return "Reveal repeated triggers and learn which replacement actions are actually working."
        case .rewardGoals:
            return "Create unlimited goals and direct the money you protect toward something real."
        case .recovery:
            return "Follow the evidence-based recovery journey from the first minutes through long-term milestones."
        case .widgets:
            return "Unlock richer Home Screen and Lock Screen progress experiences."
        }
    }

    var highlightedFeatures: [ProFeature] {
        switch self {
        case .motivationPhotos:
            return [
                .unlimitedMotivationPhotos,
                .fitnessIntelligence,
                .progressSharing,
                .premiumThemes
            ]

        case .fitness:
            return [
                .fitnessIntelligence,
                .advancedTriggerPatterns,
                .premiumWidgets,
                .progressSharing
            ]

        case .patterns:
            return [
                .advancedTriggerPatterns,
                .fitnessIntelligence,
                .customReminders,
                .progressSharing
            ]

        case .rewardGoals:
            return [
                .unlimitedRewardGoals,
                .premiumWidgets,
                .progressSharing,
                .premiumThemes
            ]

        case .recovery:
            return [
                .fullRecoveryTimeline,
                .premiumWidgets,
                .progressSharing,
                .customReminders
            ]

        case .widgets:
            return [
                .premiumWidgets,
                .customReminders,
                .progressSharing,
                .premiumThemes
            ]

        case .settings, .general:
            return [
                .unlimitedMotivationPhotos,
                .fitnessIntelligence,
                .advancedTriggerPatterns,
                .unlimitedRewardGoals,
                .fullRecoveryTimeline,
                .premiumWidgets
            ]
        }
    }
}

enum ProAccessPolicy {
    static let freeMotivationPhotoLimit = 1
    static let freeRewardGoalLimit = 1
    static let freeRecoveryMilestoneLimit = 4

    static func canAddMotivationPhoto(
        hasPro: Bool,
        photoCount: Int
    ) -> Bool {
        hasPro || photoCount < freeMotivationPhotoLimit
    }

    static func canCreateRewardGoal(
        hasPro: Bool,
        goalCount: Int
    ) -> Bool {
        hasPro || goalCount < freeRewardGoalLimit
    }
}
