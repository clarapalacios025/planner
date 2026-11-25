import Foundation
import UserNotifications

final class ReminderManager {
    static let shared = ReminderManager()
    private let center = UNUserNotificationCenter.current()

    func schedule(for item: PlannerItem) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            guard granted else { return }
            self?.scheduleNotification(for: item)
        }
    }

    func cancel(for item: PlannerItem) {
        center.removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
    }

    private func scheduleNotification(for item: PlannerItem) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        guard let date = formatter.date(from: item.time) else { return }

        var components = Calendar.current.dateComponents([.hour, .minute], from: date)
        components.calendar = Calendar.current

        let content = UNMutableNotificationContent()
        content.title = "A little note from Alia"
        content.body = item.title
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}
