import Foundation

struct CyclePrediction {
    let nextPeriodStart: Date
    let pmsWindowStart: Date
    let pmsWindowEnd: Date
    let ovulationDate: Date
    let currentPhase: CyclePhase
    let daysUntilNextPeriod: Int
    let daysUntilPMS: Int
    let averageCycleLength: Int

    var daysIntoPeriod: Int? {
        guard currentPhase == .menstruation else { return nil }
        return Calendar.current.dateComponents([.day], from: pmsWindowEnd, to: Date()).day
    }
}
