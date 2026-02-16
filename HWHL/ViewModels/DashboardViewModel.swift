import Foundation
import SwiftData
import Observation

@Observable
final class DashboardViewModel {
    var prediction: CyclePrediction?
    var todaysTip: TipsService.Tip?
    var cycles: [CycleRecord] = []
    var isLoading = false
    var error: String?

    func load(healthKitService: HealthKitService, modelContext: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Try HealthKit first
            if healthKitService.isAuthorized {
                let hkCycles = try await healthKitService.fetchRecentCycles()
                if !hkCycles.isEmpty {
                    cycles = hkCycles
                }
            }

            // Fall back to local data if no HealthKit cycles
            if cycles.isEmpty {
                let descriptor = FetchDescriptor<CycleRecord>(
                    sortBy: [SortDescriptor(\.periodStartDate, order: .forward)]
                )
                cycles = (try? modelContext.fetch(descriptor)) ?? []
            }

            // Generate prediction
            prediction = PredictionEngine.predict(from: cycles)

            // Get tip of the day
            if let phase = prediction?.currentPhase {
                todaysTip = TipsService.tipOfTheDay(for: phase)
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
