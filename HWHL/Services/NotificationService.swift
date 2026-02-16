import Foundation
import UserNotifications
import Observation

@Observable
final class NotificationService {
    var isAuthorized = false

    func requestAuthorization() async throws {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        isAuthorized = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }

    func schedulePMSAlert(pmsStartDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "PMS Heads Up"
        content.body = "PMS may start in ~2 days. Check today's tips for some self-care ideas."
        content.sound = .default

        // Alert 2 days before PMS window
        guard let alertDate = Calendar.current.date(byAdding: .day, value: -2, to: pmsStartDate) else { return }
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: alertDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "pms-alert-\(alertDate.timeIntervalSince1970)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func schedulePeriodAlert(periodStartDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Period Coming Soon"
        content.body = "Your period is predicted to start tomorrow. Be prepared!"
        content.sound = .default

        guard let alertDate = Calendar.current.date(byAdding: .day, value: -1, to: periodStartDate) else { return }
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: alertDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "period-alert-\(alertDate.timeIntervalSince1970)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleDailyCheckIn(during phase: CyclePhase) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "How are you feeling today? Tap to log and get tips for your \(phase.displayName) phase."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9 // 9 AM daily

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-checkin", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleNotifications(for prediction: CyclePrediction) {
        cancelAllNotifications()
        schedulePMSAlert(pmsStartDate: prediction.pmsWindowStart)
        schedulePeriodAlert(periodStartDate: prediction.nextPeriodStart)
        scheduleDailyCheckIn(during: prediction.currentPhase)
    }
}
