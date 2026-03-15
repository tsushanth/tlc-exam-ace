//
//  NotificationManager.swift
//  TLCExamAce
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    var isAuthorized: Bool = false

    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            if granted {
                scheduleDailyStudyReminder()
            }
        } catch {
            print("Notification permission error: \(error)")
        }
    }

    func scheduleDailyStudyReminder(hour: Int = 19, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Study! 📚"
        content.body = "Keep your streak going — practice TLC questions for 10 minutes."
        content.sound = .default
        content.badge = 1

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_study", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("Schedule notification error: \(error)") }
        }
    }

    func scheduleExamReminder(examDate: Date) {
        let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: examDate) ?? examDate

        let content = UNMutableNotificationContent()
        content.title = "Exam Tomorrow! 🚖"
        content.body = "Your TLC exam is tomorrow. Review your weak areas and get a good night's sleep!"
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: oneDayBefore)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "exam_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("Exam reminder error: \(error)") }
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func updateBadge(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count) { _ in }
    }
}
