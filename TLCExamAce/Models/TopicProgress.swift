//
//  TopicProgress.swift
//  TLCExamAce
//

import Foundation
import SwiftData

// MARK: - Topic Progress (SwiftData Model)
@Model
final class TopicProgress {
    var id: UUID
    var category: String            // QuestionCategory.rawValue
    var totalAttempted: Int
    var totalCorrect: Int
    var lastAttemptedAt: Date?
    var questionHistory: [Data]     // Encoded [QuestionAttempt]
    var streakDays: Int
    var lastStreakDate: Date?

    init(category: QuestionCategory) {
        self.id = UUID()
        self.category = category.rawValue
        self.totalAttempted = 0
        self.totalCorrect = 0
        self.lastAttemptedAt = nil
        self.questionHistory = []
        self.streakDays = 0
        self.lastStreakDate = nil
    }

    var questionCategory: QuestionCategory? {
        QuestionCategory(rawValue: category)
    }

    var accuracy: Double {
        guard totalAttempted > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalAttempted)
    }

    var accuracyPercent: Int { Int(accuracy * 100) }

    var masteryLevel: MasteryLevel {
        switch accuracy {
        case 0.9...: return .mastered
        case 0.75..<0.9: return .proficient
        case 0.5..<0.75: return .developing
        default: return .needsWork
        }
    }

    func recordAttempt(questionID: UUID, correct: Bool) {
        totalAttempted += 1
        if correct { totalCorrect += 1 }
        lastAttemptedAt = Date()
        let attempt = QuestionAttempt(questionID: questionID, correct: correct)
        if let data = try? JSONEncoder().encode(attempt) {
            questionHistory.append(data)
            // Keep last 200 attempts
            if questionHistory.count > 200 {
                questionHistory.removeFirst()
            }
        }
    }

    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = lastStreakDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                streakDays += 1
            } else if diff > 1 {
                streakDays = 1
            }
            // diff == 0 means same day, no change
        } else {
            streakDays = 1
        }
        lastStreakDate = Date()
    }
}

// MARK: - Mastery Level
enum MasteryLevel: String, CaseIterable {
    case needsWork = "Needs Work"
    case developing = "Developing"
    case proficient = "Proficient"
    case mastered = "Mastered"

    var color: String {
        switch self {
        case .needsWork: return "danger"
        case .developing: return "warning"
        case .proficient: return "primary"
        case .mastered: return "success"
        }
    }

    var icon: String {
        switch self {
        case .needsWork: return "xmark.circle.fill"
        case .developing: return "minus.circle.fill"
        case .proficient: return "checkmark.circle.fill"
        case .mastered: return "star.circle.fill"
        }
    }
}

// MARK: - Question Attempt
struct QuestionAttempt: Codable {
    let questionID: UUID
    let correct: Bool
    let date: Date

    init(questionID: UUID, correct: Bool) {
        self.questionID = questionID
        self.correct = correct
        self.date = Date()
    }
}
