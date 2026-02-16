import Foundation

struct TipsService {
    struct Tip: Identifiable {
        let id = UUID()
        let title: String
        let body: String
        let category: String
    }

    static func tips(for phase: CyclePhase) -> [Tip] {
        switch phase {
        case .menstruation:
            return menstruationTips
        case .follicular:
            return follicularTips
        case .ovulation:
            return ovulationTips
        case .luteal:
            return lutealTips
        }
    }

    static func tipOfTheDay(for phase: CyclePhase) -> Tip {
        let phaseTips = tips(for: phase)
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return phaseTips[dayOfYear % phaseTips.count]
    }

    // MARK: - Tip Banks

    private static let menstruationTips: [Tip] = [
        Tip(title: "Warm Comfort", body: "A heating pad or warm bath can help ease cramps. Give yourself permission to slow down.", category: "Comfort"),
        Tip(title: "Iron-Rich Foods", body: "Reach for spinach, lentils, or dark chocolate to replenish iron levels during your period.", category: "Nutrition"),
        Tip(title: "Gentle Movement", body: "Light yoga or a slow walk can actually help with cramp relief. No need to push hard.", category: "Exercise"),
        Tip(title: "Hydrate Extra", body: "Your body needs more water during menstruation. Herbal teas count too!", category: "Nutrition"),
        Tip(title: "Rest is Productive", body: "Your body is doing important work. Resting now isn't lazy — it's necessary.", category: "Mindset"),
        Tip(title: "Magnesium Boost", body: "Magnesium-rich foods like bananas, nuts, and avocados can help reduce cramps.", category: "Nutrition"),
    ]

    private static let follicularTips: [Tip] = [
        Tip(title: "Try Something New", body: "Rising estrogen boosts creativity and openness. Great time to start a new project or hobby.", category: "Mindset"),
        Tip(title: "High-Energy Workouts", body: "Your energy is climbing — take advantage with HIIT, running, or dancing.", category: "Exercise"),
        Tip(title: "Plan Ahead", body: "This is your strategic phase. Use this clarity to plan your week and set goals.", category: "Productivity"),
        Tip(title: "Social Energy", body: "You may feel more social now. Schedule catch-ups or collaborative work.", category: "Social"),
        Tip(title: "Protein Focus", body: "Support rising energy with lean proteins and complex carbs.", category: "Nutrition"),
    ]

    private static let ovulationTips: [Tip] = [
        Tip(title: "Peak Communication", body: "Verbal skills peak around ovulation. Great day for important conversations or presentations.", category: "Social"),
        Tip(title: "Strength Training", body: "Testosterone peaks briefly — you may hit PRs in the gym. Go for it!", category: "Exercise"),
        Tip(title: "Skin Glow", body: "Estrogen peaks make skin look its best. Enjoy the natural glow.", category: "Self-Care"),
        Tip(title: "Connection Time", body: "Oxytocin is high. Nurture your important relationships today.", category: "Social"),
    ]

    private static let lutealTips: [Tip] = [
        Tip(title: "Be Patient With Yourself", body: "Mood shifts are hormonal, not personal. Acknowledge feelings without judgment.", category: "Mindset"),
        Tip(title: "Comfort Foods Done Right", body: "Craving carbs? Try sweet potatoes, whole grains, or oatmeal with fruit.", category: "Nutrition"),
        Tip(title: "Steady-State Cardio", body: "Swap intense workouts for steady walks, swimming, or cycling.", category: "Exercise"),
        Tip(title: "Wind Down Earlier", body: "Progesterone can make you sleepy. Honor that — earlier bedtime helps.", category: "Self-Care"),
        Tip(title: "Boundary Check", body: "You may feel more sensitive. It's okay to say no and protect your energy.", category: "Mindset"),
        Tip(title: "Calcium & B6", body: "These nutrients may reduce PMS symptoms. Found in dairy, bananas, and chickpeas.", category: "Nutrition"),
        Tip(title: "Journaling", body: "Writing out your thoughts can help process the emotional intensity of the luteal phase.", category: "Mindset"),
        Tip(title: "Warm Drinks", body: "Herbal teas like chamomile or ginger can soothe PMS bloating and anxiety.", category: "Comfort"),
    ]
}
