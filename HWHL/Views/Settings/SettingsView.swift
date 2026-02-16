import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(HealthKitService.self) private var healthKitService
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.modelContext) private var modelContext

    @State private var showManualEntry = false
    @State private var manualPeriodDate = Date()
    @State private var manualCycleLength = 28

    var body: some View {
        NavigationStack {
            List {
                // HealthKit Section
                Section("HealthKit") {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                        Text("HealthKit Status")
                        Spacer()
                        Text(healthKitService.isAuthorized ? "Connected" : "Not Connected")
                            .foregroundStyle(healthKitService.isAuthorized ? .green : .secondary)
                    }

                    if !healthKitService.isAuthorized {
                        Button("Connect HealthKit") {
                            Task {
                                try? await healthKitService.requestAuthorization()
                            }
                        }
                    }
                }

                // Notifications Section
                Section("Notifications") {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.orange)
                        Text("Notifications")
                        Spacer()
                        Text(notificationService.isAuthorized ? "Enabled" : "Disabled")
                            .foregroundStyle(notificationService.isAuthorized ? .green : .secondary)
                    }

                    if !notificationService.isAuthorized {
                        Button("Enable Notifications") {
                            Task {
                                try? await notificationService.requestAuthorization()
                            }
                        }
                    }
                }

                // Manual Entry Section
                Section("Manual Entry") {
                    Button("Log Period Start") {
                        showManualEntry = true
                    }
                }

                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Data Sources")
                        Spacer()
                        Text("HealthKit, Manual")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showManualEntry) {
                ManualEntrySheet(
                    periodDate: $manualPeriodDate,
                    cycleLength: $manualCycleLength
                ) {
                    let record = CycleRecord(
                        periodStartDate: manualPeriodDate,
                        cycleLength: manualCycleLength,
                        source: .manual
                    )
                    modelContext.insert(record)
                    showManualEntry = false
                }
            }
        }
    }
}

// MARK: - Manual Entry Sheet

private struct ManualEntrySheet: View {
    @Binding var periodDate: Date
    @Binding var cycleLength: Int
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Period Start Date", selection: $periodDate, displayedComponents: .date)

                Stepper("Cycle Length: \(cycleLength) days", value: $cycleLength, in: 20...45)
            }
            .navigationTitle("Log Period")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                }
            }
        }
    }
}
