import SwiftUI

struct TipsView: View {
    @State private var selectedPhase: CyclePhase = .luteal

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Phase picker
                Picker("Phase", selection: $selectedPhase) {
                    ForEach(CyclePhase.allCases, id: \.self) { phase in
                        Text("\(phase.emoji) \(phase.displayName)").tag(phase)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                List {
                    ForEach(TipsService.tips(for: selectedPhase)) { tip in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(tip.title)
                                    .font(.headline)
                                Spacer()
                                Text(tip.category)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.pink.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            Text(tip.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Tips")
        }
    }
}
