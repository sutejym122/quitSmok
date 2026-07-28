import Foundation

struct OnboardingPreferences: Codable, Equatable, Sendable {
    var fitnessIdentity: FitnessIdentity
    var quitReasons: [QuitReason]
    var cravingTriggers: [CravingTrigger]
    var rescueActions: [RescueAction]
    var completedAt: Date

    static let defaults = OnboardingPreferences(
        fitnessIdentity: .buildingConsistency,
        quitReasons: [.protectBody, .takeControl],
        cravingTriggers: [.stress, .habit],
        rescueActions: [.drinkWater, .walk],
        completedAt: .now
    )
}

enum FitnessIdentity: String, Codable, CaseIterable, Identifiable, Sendable {
    case seriousTraining
    case buildingConsistency
    case returningToFitness
    case healthFirst

    var id: String { rawValue }

    var title: String {
        switch self {
        case .seriousTraining:
            return "Training is part of who I am"
        case .buildingConsistency:
            return "I’m building a stronger routine"
        case .returningToFitness:
            return "I’m getting back into fitness"
        case .healthFirst:
            return "I want to feel healthy again"
        }
    }

    var detail: String {
        switch self {
        case .seriousTraining:
            return "Protect performance, recovery, confidence, and the physique you earned."
        case .buildingConsistency:
            return "Make quitting one of the habits that strengthens everything else."
        case .returningToFitness:
            return "Use quitting as the clean starting point for your comeback."
        case .healthFirst:
            return "Build more energy, control, and confidence before chasing numbers."
        }
    }

    var symbolName: String {
        switch self {
        case .seriousTraining:
            return "figure.strengthtraining.traditional"
        case .buildingConsistency:
            return "calendar.badge.checkmark"
        case .returningToFitness:
            return "arrow.counterclockwise.circle.fill"
        case .healthFirst:
            return "heart.fill"
        }
    }

    var identityStatement: String {
        switch self {
        case .seriousTraining:
            return "I protect the body, performance, and discipline I worked to build."
        case .buildingConsistency:
            return "I choose the habits that build the person I want to become."
        case .returningToFitness:
            return "This is the beginning of my strongest comeback."
        case .healthFirst:
            return "I protect my health, energy, and future one decision at a time."
        }
    }
}

enum QuitReason: String, Codable, CaseIterable, Identifiable, Sendable {
    case protectBody
    case breatheBetter
    case saveMoney
    case lookHealthier
    case takeControl
    case bePresent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .protectBody:
            return "Protect my body"
        case .breatheBetter:
            return "Breathe and perform better"
        case .saveMoney:
            return "Stop burning money"
        case .lookHealthier:
            return "Look and feel healthier"
        case .takeControl:
            return "Take back control"
        case .bePresent:
            return "Be present for my people"
        }
    }

    var symbolName: String {
        switch self {
        case .protectBody:
            return "figure.strengthtraining.traditional"
        case .breatheBetter:
            return "lungs.fill"
        case .saveMoney:
            return "banknote.fill"
        case .lookHealthier:
            return "sparkles"
        case .takeControl:
            return "hand.raised.fill"
        case .bePresent:
            return "person.2.fill"
        }
    }

    var identityStatement: String {
        switch self {
        case .protectBody:
            return "I protect the body and life I am building."
        case .breatheBetter:
            return "I choose the breath, energy, and performance my body deserves."
        case .saveMoney:
            return "My money builds my future instead of feeding an old habit."
        case .lookHealthier:
            return "I choose the version of me that looks alive, strong, and in control."
        case .takeControl:
            return "A craving does not get to make decisions for me."
        case .bePresent:
            return "I stay healthy and present for the people who matter to me."
        }
    }
}

enum CravingTrigger: String, Codable, CaseIterable, Identifiable, Sendable {
    case stress
    case afterFood
    case coffee
    case alcohol
    case boredom
    case social
    case driving
    case habit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stress:
            return "Stress"
        case .afterFood:
            return "After food"
        case .coffee:
            return "Coffee"
        case .alcohol:
            return "Alcohol"
        case .boredom:
            return "Boredom"
        case .social:
            return "Social"
        case .driving:
            return "Driving"
        case .habit:
            return "Habit"
        }
    }

    var symbolName: String {
        switch self {
        case .stress:
            return "brain.head.profile"
        case .afterFood:
            return "fork.knife"
        case .coffee:
            return "cup.and.saucer.fill"
        case .alcohol:
            return "wineglass.fill"
        case .boredom:
            return "clock.fill"
        case .social:
            return "person.3.fill"
        case .driving:
            return "car.fill"
        case .habit:
            return "repeat"
        }
    }
}

enum RescueAction: String, Codable, CaseIterable, Identifiable, Sendable {
    case drinkWater
    case walk
    case pushUps
    case chewGum
    case leaveRoom
    case textSomeone

    var id: String { rawValue }

    var title: String {
        switch self {
        case .drinkWater:
            return "Drink water"
        case .walk:
            return "Walk 5 minutes"
        case .pushUps:
            return "20 push-ups"
        case .chewGum:
            return "Chew gum"
        case .leaveRoom:
            return "Leave the room"
        case .textSomeone:
            return "Text someone"
        }
    }

    var shortTitle: String {
        switch self {
        case .drinkWater:
            return "Water"
        case .walk:
            return "Walk"
        case .pushUps:
            return "Push-ups"
        case .chewGum:
            return "Gum"
        case .leaveRoom:
            return "Leave"
        case .textSomeone:
            return "Text"
        }
    }

    var symbolName: String {
        switch self {
        case .drinkWater:
            return "drop.fill"
        case .walk:
            return "figure.walk"
        case .pushUps:
            return "figure.strengthtraining.traditional"
        case .chewGum:
            return "mouth.fill"
        case .leaveRoom:
            return "door.left.hand.open"
        case .textSomeone:
            return "message.fill"
        }
    }
}
