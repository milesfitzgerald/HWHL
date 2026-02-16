import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(HealthKitService.self) private var healthKitService
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate = Date()
    @State private var cycles: [CycleRecord] = []
    @State private var prediction: CyclePrediction?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(.pink)
                .padding()

                Divider()

                if let prediction {
                    phaseForDateView
                } else {
                    Text("No cycle data available")
                        .foregroundStyle(.secondary)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle("Calendar")
            .task {
                await loadData()
            }
        }
    }

    private var phaseForDateView: some View {
        let phase = PredictionEngine.determinePhase(
            referenceDate: selectedDate,
            lastPeriodStart: cycles.last?.periodStartDate ?? Date(),
            periodLength: PredictionEngine.averagePeriodLength(from: cycles),
            ovulationDate: prediction?.ovulationDate ?? Date(),
            pmsStart: prediction?.pmsWindowStart ?? Date(),
            nextPeriodStart: prediction?.nextPeriodStart ?? Date()
        )

        return VStack(spacing: 12) {
            Text(phase.emoji)
                .font(.system(size: 36))
            Text(phase.displayName)
                .font(.headline)
            Text(phase.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    private func loadData() async {
        do {
            if healthKitService.isAuthorized {
                cycles = try await healthKitService.fetchRecentCycles()
            }
            if cycles.isEmpty {
                let descriptor = FetchDescriptor<CycleRecord>(
                    sortBy: [SortDescriptor(\.periodStartDate, order: .forward)]
                )
                cycles = (try? modelContext.fetch(descriptor)) ?? []
            }
            prediction = PredictionEngine.predict(from: cycles)
        } catch {
            // Fall back to local data
            let descriptor = FetchDescriptor<CycleRecord>(
                sortBy: [SortDescriptor(\.periodStartDate, order: .forward)]
            )
            cycles = (try? modelContext.fetch(descriptor)) ?? []
            prediction = PredictionEngine.predict(from: cycles)
        }
    }
}
