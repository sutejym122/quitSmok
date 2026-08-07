import Foundation

struct BuiltPlanEngine {
    static func makePlan(
        preferences: OnboardingPreferences,
        generatedAt: Date = .now
    ) -> BuiltPlan {
        let primaryTrigger =
            preferences.cravingTriggers.first ?? .habit

        let secondaryTrigger =
            preferences.cravingTriggers.dropFirst().first
            ?? fallbackTrigger(excluding: primaryTrigger)

        let primaryRescue =
            preferences.rescueActions.first ?? .drinkWater

        let secondaryRescue =
            preferences.rescueActions.dropFirst().first
            ?? fallbackRescue(excluding: primaryRescue)

        let primaryReason =
            preferences.quitReasons.first ?? .takeControl

        let identity = preferences.fitnessIdentity

        return BuiltPlan(
            generatedAt: generatedAt,
            title: "Your first 7 days are BUILT.",
            subtitle: planSubtitle(
                identity: identity,
                primaryTrigger: primaryTrigger
            ),
            missions: [
                dayOne(
                    trigger: primaryTrigger
                ),
                dayTwo(
                    rescue: primaryRescue,
                    trigger: primaryTrigger
                ),
                dayThree(
                    identity: identity
                ),
                dayFour(
                    reason: primaryReason
                ),
                dayFive(
                    trigger: secondaryTrigger,
                    rescue: secondaryRescue
                ),
                daySix(
                    trigger: primaryTrigger,
                    rescue: primaryRescue
                ),
                daySeven(
                    identity: identity,
                    reason: primaryReason
                )
            ]
        )
    }

    private static func planSubtitle(
        identity: FitnessIdentity,
        primaryTrigger: CravingTrigger
    ) -> String {
        "Built around \(primaryTrigger.title.lowercased()), "
            + "your rescue plan, and the person you are becoming."
    }

    private static func dayOne(
        trigger: CravingTrigger
    ) -> BuiltPlanMission {
        BuiltPlanMission(
            dayNumber: 1,
            focus: .awareness,
            title: "Catch the cue before it decides for you.",
            detail:
                "Your first pattern to watch is \(trigger.title.lowercased()). "
                + triggerInsight(trigger),
            action:
                "The next time \(trigger.title.lowercased()) shows up, "
                + "pause for ten seconds before doing anything. "
                + "Name the urge in BUILT instead of reacting automatically.",
            reason:
                "You cannot break a loop you only notice after it wins.",
            symbolName: trigger.symbolName
        )
    }

    private static func dayTwo(
        rescue: RescueAction,
        trigger: CravingTrigger
    ) -> BuiltPlanMission {
        BuiltPlanMission(
            dayNumber: 2,
            focus: .replacement,
            title: "Make \(rescue.shortTitle.lowercased()) automatic.",
            detail:
                "A craving needs a replacement action, not an argument. "
                + "\(rescue.title) is your first move when "
                + "\(trigger.title.lowercased()) hits.",
            action:
                "Do \(rescue.title.lowercased()) once today even if you are "
                + "not craving. Rehearse the replacement before you need it.",
            reason:
                "Practiced actions are easier to reach under pressure.",
            symbolName: rescue.symbolName
        )
    }

    private static func dayThree(
        identity: FitnessIdentity
    ) -> BuiltPlanMission {
        BuiltPlanMission(
            dayNumber: 3,
            focus: .identity,
            title: identityMissionTitle(identity),
            detail: identity.detail,
            action: identityAction(identity),
            reason: identity.identityStatement,
            symbolName: identity.symbolName
        )
    }

    private static func dayFour(
        reason: QuitReason
    ) -> BuiltPlanMission {
        BuiltPlanMission(
            dayNumber: 4,
            focus: .motivation,
            title: reasonMissionTitle(reason),
            detail: reason.identityStatement,
            action: reasonAction(reason),
            reason:
                "Motivation is stronger when the reason is specific enough "
                + "to picture.",
            symbolName: reason.symbolName
        )
    }

    private static func dayFive(
        trigger: CravingTrigger,
        rescue: RescueAction
    ) -> BuiltPlanMission {
        BuiltPlanMission(
            dayNumber: 5,
            focus: .preparation,
            title: "Pre-decide the next hard moment.",
            detail:
                "\(trigger.title) is another situation worth preparing for. "
                + "Do not wait until the craving arrives to invent a plan.",
            action:
                "Make this decision now: when \(trigger.title.lowercased()) "
                + "shows up, your first action is "
                + "\(rescue.title.lowercased()).",
            reason:
                "Pre-commitment removes one decision from a difficult moment.",
            symbolName: "checkmark.shield.fill"
        )
    }

    private static func daySix(
        trigger: CravingTrigger,
        rescue: RescueAction
    ) -> BuiltPlanMission {
        BuiltPlanMission(
            dayNumber: 6,
            focus: .environment,
            title: "Make the old habit inconvenient.",
            detail:
                "Willpower should not have to do all the work. "
                + "Change the environment around your strongest cue.",
            action: environmentAction(
                trigger: trigger,
                rescue: rescue
            ),
            reason:
                "Small amounts of friction can interrupt an automatic habit "
                + "long enough for you to choose differently.",
            symbolName: "door.left.hand.closed"
        )
    }

    private static func daySeven(
        identity: FitnessIdentity,
        reason: QuitReason
    ) -> BuiltPlanMission {
        BuiltPlanMission(
            dayNumber: 7,
            focus: .proof,
            title: "Read the evidence.",
            detail:
                "A week is not proof that cravings disappeared. "
                + "It is proof that you can make decisions while they exist.",
            action:
                "Open BUILT and review your smoke-free time, cravings "
                + "defeated, money protected, and training. Pick the one "
                + "number that makes you want to protect the next seven days.",
            reason:
                "\(identity.identityStatement) \(reason.identityStatement)",
            symbolName: "chart.line.uptrend.xyaxis"
        )
    }

    private static func triggerInsight(
        _ trigger: CravingTrigger
    ) -> String {
        switch trigger {
        case .stress:
            return "Stress can make the cigarette feel like relief before "
                + "you have evaluated what you actually need."
        case .afterFood:
            return "The end of a meal can act like a learned start signal "
                + "for smoking."
        case .coffee:
            return "Coffee and smoking can become one combined routine even "
                + "when the nicotine urge itself is weak."
        case .alcohol:
            return "Alcohol can lower the friction between an urge and an "
                + "automatic decision."
        case .boredom:
            return "Boredom can make stimulation feel like a need rather "
                + "than a choice."
        case .social:
            return "Social cues can trigger the ritual before you consciously "
                + "decide whether you want it."
        case .driving:
            return "Repeated routes can make smoking feel attached to the "
                + "drive itself."
        case .habit:
            return "Automatic habits often start moving before conscious "
                + "motivation enters the conversation."
        }
    }

    private static func identityMissionTitle(
        _ identity: FitnessIdentity
    ) -> String {
        switch identity {
        case .seriousTraining:
            return "Train like smoking is not part of the program."
        case .buildingConsistency:
            return "Add quitting to the routine you are building."
        case .returningToFitness:
            return "Make this part of the comeback."
        case .healthFirst:
            return "Protect tomorrow's energy."
        }
    }

    private static func identityAction(
        _ identity: FitnessIdentity
    ) -> String {
        switch identity {
        case .seriousTraining:
            return "Complete your planned training or recovery work today. "
                + "When you finish, explicitly connect that effort to staying "
                + "smoke-free."
        case .buildingConsistency:
            return "Do one piece of intentional movement today, even if it "
                + "is short. The goal is to vote for the same identity twice: "
                + "movement and no cigarette."
        case .returningToFitness:
            return "Choose a workout or walk that is easy enough to complete. "
                + "The comeback needs evidence, not punishment."
        case .healthFirst:
            return "Do ten intentional minutes of movement and notice how "
                + "your breathing and energy feel without judging the numbers."
        }
    }

    private static func reasonMissionTitle(
        _ reason: QuitReason
    ) -> String {
        switch reason {
        case .protectBody:
            return "Put the body first."
        case .breatheBetter:
            return "Protect the breath you train with."
        case .saveMoney:
            return "Stop funding the old habit."
        case .lookHealthier:
            return "Choose the version of you that looks alive."
        case .takeControl:
            return "Practice being the one who decides."
        case .bePresent:
            return "Protect the time people get with you."
        }
    }

    private static func reasonAction(
        _ reason: QuitReason
    ) -> String {
        switch reason {
        case .protectBody:
            return "Write one physical outcome you want smoking to stop "
                + "taking from you. Keep it concrete."
        case .breatheBetter:
            return "During a walk or workout, notice one moment when breathing "
                + "matters. Use that moment as today's reason."
        case .saveMoney:
            return "Open your protected-money total and name one thing that "
                + "money should build instead."
        case .lookHealthier:
            return "Choose one visible or felt change you want to protect: "
                + "skin, energy, teeth, smell, confidence, or recovery."
        case .takeControl:
            return "When one urge appears today, deliberately wait two minutes "
                + "before taking any action. Make the decision yours."
        case .bePresent:
            return "Picture one person or future moment you want more healthy "
                + "time for. Make it specific."
        }
    }

    private static func environmentAction(
        trigger: CravingTrigger,
        rescue: RescueAction
    ) -> String {
        switch trigger {
        case .stress:
            return "Put \(rescue.title.lowercased()) within easy reach and "
                + "move cigarettes, lighters, or smoking cues out of your "
                + "default stress path."
        case .afterFood:
            return "Change what happens immediately after your next meal. "
                + "Stand up, leave the usual smoking spot, and "
                + "\(rescue.title.lowercased())."
        case .coffee:
            return "Have your next coffee in a different place or pair it "
                + "with \(rescue.title.lowercased()) instead of the old ritual."
        case .alcohol:
            return "Decide your smoking boundary before drinking starts and "
                + "keep \(rescue.title.lowercased()) as your exit action."
        case .boredom:
            return "Place one five-minute activity where cigarettes used to "
                + "fill empty time. Start with \(rescue.title.lowercased())."
        case .social:
            return "Decide where you will stand or what you will do when "
                + "others smoke. Your first move is "
                + "\(rescue.title.lowercased())."
        case .driving:
            return "Remove smoking cues from the car and put what you need for "
                + "\(rescue.title.lowercased()) where the old cue used to be."
        case .habit:
            return "Remove one object, location, or routine that makes smoking "
                + "automatic and replace it with a visible cue for "
                + "\(rescue.title.lowercased())."
        }
    }

    private static func fallbackTrigger(
        excluding trigger: CravingTrigger
    ) -> CravingTrigger {
        CravingTrigger.allCases.first {
            $0 != trigger
        } ?? .stress
    }

    private static func fallbackRescue(
        excluding rescue: RescueAction
    ) -> RescueAction {
        RescueAction.allCases.first {
            $0 != rescue
        } ?? .walk
    }
}
