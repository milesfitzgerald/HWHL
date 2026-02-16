import Foundation

struct PredictionEngine {
    static let defaultCycleLength = 28
    static let defaultPeriodLength = 5
    static let pmsEarlyDays = 14  // PMS can start up to 14 days before period
    static let pmsLateDays = 7    // PMS typically starts at least 7 days before

    static func predict(from cycles: [CycleRecord], referenceDate: Date = Date()) -> CyclePrediction? {
        guard let lastCycle = cycles.last else { return nil }

        let avgCycleLength = averageCycleLength(from: cycles)
        let avgPeriodLength = averagePeriodLength(from: cycles)
        let calendar = Calendar.current

        // Predict next period
        guard let nextPeriodStart = calendar.date(
            byAdding: .day, value: avgCycleLength, to: lastCycle.periodStartDate
        ) else { return nil }

        // Ovulation ~14 days before next period
        guard let ovulationDate = calendar.date(
            byAdding: .day, value: -14, to: nextPeriodStart
        ) else { return nil }

        // PMS window: 7–14 days before predicted period
        guard let pmsStart = calendar.date(
            byAdding: .day, value: -pmsEarlyDays, to: nextPeriodStart
        ),
        let pmsEnd = calendar.date(
            byAdding: .day, value: -pmsLateDays, to: nextPeriodStart
        ) else { return nil }

        // Determine current phase
        let currentPhase = determinePhase(
            referenceDate: referenceDate,
            lastPeriodStart: lastCycle.periodStartDate,
            periodLength: avgPeriodLength,
            ovulationDate: ovulationDate,
            pmsStart: pmsStart,
            nextPeriodStart: nextPeriodStart
        )

        let daysUntilPeriod = calendar.dateComponents([.day], from: referenceDate, to: nextPeriodStart).day ?? 0
        let daysUntilPMS = calendar.dateComponents([.day], from: referenceDate, to: pmsStart).day ?? 0

        return CyclePrediction(
            nextPeriodStart: nextPeriodStart,
            pmsWindowStart: pmsStart,
            pmsWindowEnd: pmsEnd,
            ovulationDate: ovulationDate,
            currentPhase: currentPhase,
            daysUntilNextPeriod: max(0, daysUntilPeriod),
            daysUntilPMS: max(0, daysUntilPMS),
            averageCycleLength: avgCycleLength
        )
    }

    static func averageCycleLength(from cycles: [CycleRecord]) -> Int {
        let lengths = cycles.compactMap(\.cycleLength)
        guard !lengths.isEmpty else { return defaultCycleLength }
        return lengths.reduce(0, +) / lengths.count
    }

    static func averagePeriodLength(from cycles: [CycleRecord]) -> Int {
        let lengths = cycles.compactMap { cycle -> Int? in
            guard let end = cycle.periodEndDate else { return nil }
            return Calendar.current.dateComponents([.day], from: cycle.periodStartDate, to: end).day
        }
        guard !lengths.isEmpty else { return defaultPeriodLength }
        return lengths.reduce(0, +) / lengths.count
    }

    static func determinePhase(
        referenceDate: Date,
        lastPeriodStart: Date,
        periodLength: Int,
        ovulationDate: Date,
        pmsStart: Date,
        nextPeriodStart: Date
    ) -> CyclePhase {
        let calendar = Calendar.current

        guard let periodEnd = calendar.date(
            byAdding: .day, value: periodLength, to: lastPeriodStart
        ) else { return .follicular }

        if referenceDate >= lastPeriodStart && referenceDate < periodEnd {
            return .menstruation
        } else if referenceDate >= periodEnd && referenceDate < ovulationDate {
            return .follicular
        } else if referenceDate >= ovulationDate && referenceDate < pmsStart {
            return .ovulation
        } else if referenceDate >= pmsStart && referenceDate < nextPeriodStart {
            return .luteal
        } else if referenceDate >= nextPeriodStart {
            return .menstruation
        }

        return .follicular
    }
}
