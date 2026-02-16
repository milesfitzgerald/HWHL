import SwiftUI
import SwiftData

@main
struct HWHLApp: App {
    @State private var healthKitService = HealthKitService()
    @State private var notificationService = NotificationService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CycleRecord.self,
            TipEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(healthKitService)
                .environment(notificationService)
        }
        .modelContainer(sharedModelContainer)
    }
}
