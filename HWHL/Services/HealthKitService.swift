import Foundation
import HealthKit
import Observation

@Observable
final class HealthKitService {
    private let healthStore = HKHealthStore()

    var isAuthorized = false
    var menstrualFlowRecords: [HKCategorySample] = []

    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isHealthKitAvailable else { return }

        let readTypes: Set<HKSampleType> = [
            HKCategoryType(.menstrualFlow),
            HKCategoryType(.ovulationTestResult),
            HKQuantityType(.basalBodyTemperature),
        ]

        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
        isAuthorized = true
    }

    func fetchMenstrualFlow(from startDate: Date, to endDate: Date) async throws -> [HKCategorySample] {
        let sampleType = HKCategoryType(.menstrualFlow)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let categorySamples = (samples as? [HKCategorySample]) ?? []
                continuation.resume(returning: categorySamples)
            }
            healthStore.execute(query)
        }
    }

    func fetchRecentCycles(monthsBack: Int = 12) async throws -> [CycleRecord] {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .month, value: -monthsBack, to: endDate) else {
            return []
        }

        let samples = try await fetchMenstrualFlow(from: startDate, to: endDate)
        return groupSamplesIntoCycles(samples)
    }

    private func groupSamplesIntoCycles(_ samples: [HKCategorySample]) -> [CycleRecord] {
        guard !samples.isEmpty else { return [] }

        var cycles: [CycleRecord] = []
        var currentPeriodStart: Date?
        var currentPeriodEnd: Date?

        for sample in samples {
            let flowLevel = HKCategoryValueMenstrualFlow(rawValue: sample.value)
            guard flowLevel != .none else { continue }

            if let periodStart = currentPeriodStart, let periodEnd = currentPeriodEnd {
                let daysSinceLastFlow = Calendar.current.dateComponents(
                    [.day], from: periodEnd, to: sample.startDate
                ).day ?? 0

                if daysSinceLastFlow > 2 {
                    // New period started — save previous one
                    let record = CycleRecord(
                        periodStartDate: periodStart,
                        periodEndDate: periodEnd,
                        source: .healthKit
                    )
                    cycles.append(record)
                    currentPeriodStart = sample.startDate
                    currentPeriodEnd = sample.endDate
                } else {
                    currentPeriodEnd = sample.endDate
                }
            } else {
                currentPeriodStart = sample.startDate
                currentPeriodEnd = sample.endDate
            }
        }

        // Save last period
        if let periodStart = currentPeriodStart {
            let record = CycleRecord(
                periodStartDate: periodStart,
                periodEndDate: currentPeriodEnd,
                source: .healthKit
            )
            cycles.append(record)
        }

        // Calculate cycle lengths
        for i in 1..<cycles.count {
            let days = Calendar.current.dateComponents(
                [.day],
                from: cycles[i - 1].periodStartDate,
                to: cycles[i].periodStartDate
            ).day
            cycles[i].cycleLength = days
        }

        return cycles
    }
}
