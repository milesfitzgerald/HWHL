import Foundation

enum CyclePhase: String, CaseIterable {
    case menstruation
    case follicular
    case ovulation
    case luteal

    var displayName: String {
        switch self {
        case .menstruation: "Period"
        case .follicular: "Follicular"
        case .ovulation: "Ovulation"
        case .luteal: "Luteal (PMS)"
        }
    }

    var description: String {
        switch self {
        case .menstruation:
            "Your period is here. Focus on rest and comfort."
        case .follicular:
            "Energy is rising. Great time for new projects."
        case .ovulation:
            "Peak energy and sociability."
        case .luteal:
            "Winding down. Practice extra self-care."
        }
    }

    var emoji: String {
        switch self {
        case .menstruation: "🩸"
        case .follicular: "🌱"
        case .ovulation: "☀️"
        case .luteal: "🌙"
        }
    }

    var color: String {
        switch self {
        case .menstruation: "phaseRed"
        case .follicular: "phaseGreen"
        case .ovulation: "phaseYellow"
        case .luteal: "phasePurple"
        }
    }
}
