//
//  UserProfile.swift
//  TLCExamAce
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var targetLicenseType: String   // LicenseType.rawValue
    var examDate: Date?
    var preferredLanguage: String   // AppLanguage.rawValue
    var totalStudyMinutes: Double
    var totalExamsCompleted: Int
    var bestScore: Double
    var currentStreak: Int
    var longestStreak: Int
    var lastStudyDate: Date?
    var joinedAt: Date
    var isPremium: Bool
    var dailyGoalMinutes: Int

    // Weak category tracking (comma-separated category rawValues)
    var weakCategories: String

    init(name: String = "Student", targetLicenseType: LicenseType = .fhv) {
        self.id = UUID()
        self.name = name
        self.targetLicenseType = targetLicenseType.rawValue
        self.examDate = nil
        self.preferredLanguage = AppLanguage.english.rawValue
        self.totalStudyMinutes = 0
        self.totalExamsCompleted = 0
        self.bestScore = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastStudyDate = nil
        self.joinedAt = Date()
        self.isPremium = false
        self.dailyGoalMinutes = 20
        self.weakCategories = ""
    }

    var targetLicense: LicenseType {
        LicenseType(rawValue: targetLicenseType) ?? .fhv
    }

    var language: AppLanguage {
        AppLanguage(rawValue: preferredLanguage) ?? .english
    }

    var daysUntilExam: Int? {
        guard let examDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0
        return max(0, days)
    }

    var weakCategoryList: [QuestionCategory] {
        weakCategories.split(separator: ",")
            .compactMap { QuestionCategory(rawValue: String($0)) }
    }

    func updateWeakCategories(_ categories: [QuestionCategory]) {
        weakCategories = categories.map(\.rawValue).joined(separator: ",")
    }

    func recordStudySession(minutes: Double, score: Double?) {
        totalStudyMinutes += minutes
        if let score, score > bestScore {
            bestScore = score
        }
        updateStreak()
        lastStudyDate = Date()
    }

    func recordExamCompletion(score: Double) {
        totalExamsCompleted += 1
        if score > bestScore { bestScore = score }
    }

    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = lastStudyDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                currentStreak += 1
            } else if diff > 1 {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
}
