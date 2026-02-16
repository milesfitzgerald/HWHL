import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(HealthKitService.self) private var healthKitService
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Loading cycle data...")
                            .padding(.top, 40)
                    } else if let prediction = viewModel.prediction {
                        PhaseCard(prediction: prediction)
                        CountdownCard(prediction: prediction)
                        if let tip = viewModel.todaysTip {
                            TipCard(tip: tip, phase: prediction.currentPhase)
                        }
                    } else {
                        EmptyStateView()
                    }
                }
                .padding()
            }
            .navigationTitle("HWHL")
            .task {
                await viewModel.load(healthKitService: healthKitService, modelContext: modelContext)
            }
            .refreshable {
                await viewModel.load(healthKitService: healthKitService, modelContext: modelContext)
            }
        }
    }
}

// MARK: - Phase Card

private struct PhaseCard: View {
    let prediction: CyclePrediction

    var body: some View {
        VStack(spacing: 12) {
            Text(prediction.currentPhase.emoji)
                .font(.system(size: 48))
            Text(prediction.currentPhase.displayName)
                .font(.title2.bold())
            Text(prediction.currentPhase.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Countdown Card

private struct CountdownCard: View {
    let prediction: CyclePrediction

    var body: some View {
        HStack(spacing: 16) {
            CountdownItem(
                value: prediction.daysUntilNextPeriod,
                label: "Days to Period",
                color: .pink
            )
            Divider()
            CountdownItem(
                value: prediction.daysUntilPMS,
                label: "Days to PMS",
                color: .purple
            )
            Divider()
            CountdownItem(
                value: prediction.averageCycleLength,
                label: "Avg Cycle",
                color: .blue
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct CountdownItem: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tip Card

private struct TipCard: View {
    let tip: TipsService.Tip
    let phase: CyclePhase

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Tip of the Day")
                    .font(.headline)
                Spacer()
                Text(tip.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.pink.opacity(0.15))
                    .clipShape(Capsule())
            }
            Text(tip.title)
                .font(.subheadline.bold())
            Text(tip.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Empty State

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle")
                .font(.system(size: 64))
                .foregroundStyle(.pink.opacity(0.5))
            Text("No Cycle Data Yet")
                .font(.title3.bold())
            Text("Connect HealthKit or manually log your period to get started with predictions and tips.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}
