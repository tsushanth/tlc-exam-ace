//
//  ProgressTracker.swift
//  TLCExamAce
//

import Foundation
import SwiftData

@MainActor
final class ProgressTracker {
    static let shared = ProgressTracker()
    private init() {}

    // MARK: - Record completed session
    func record(session: ExamSession, in context: ModelContext) {
        let records = session.decodedAnswers
        let questions = records.compactMap { QuestionBank.shared.question(by: $0.questionID) }

        // Group by category
        var categoryMap: [QuestionCategory: (correct: Int, total: Int)] = [:]
        for (record, question) in zip(records, questions) {
            let cat = question.category
            var current = categoryMap[cat] ?? (0, 0)
            current.total += 1
            if record.isCorrect { current.correct += 1 }
            categoryMap[cat] = current
        }

        // Fetch or create TopicProgress for each category
        for (cat, stats) in categoryMap {
            let catRaw = cat.rawValue
            let descriptor = FetchDescriptor<TopicProgress>(
                predicate: #Predicate { $0.category == catRaw }
            )
            let existing = try? context.fetch(descriptor)

            if let progress = existing?.first {
                for i in 0..<stats.total {
                    let correct = i < stats.correct
                    progress.recordAttempt(questionID: UUID(), correct: correct)
                }
                progress.updateStreak()
            } else {
                let newProgress = TopicProgress(category: cat)
                for i in 0..<stats.total {
                    let correct = i < stats.correct
                    newProgress.recordAttempt(questionID: UUID(), correct: correct)
                }
                newProgress.updateStreak()
                context.insert(newProgress)
            }
        }

        try? context.save()
    }

    // MARK: - Fetch all progress
    func fetchAllProgress(in context: ModelContext) -> [TopicProgress] {
        let descriptor = FetchDescriptor<TopicProgress>()
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Identify weak categories
    func weakCategories(in context: ModelContext) -> [QuestionCategory] {
        let allProgress = fetchAllProgress(in: context)
        return allProgress
            .filter { $0.totalAttempted >= 5 && $0.accuracy < 0.7 }
            .compactMap { QuestionCategory(rawValue: $0.category) }
    }

    // MARK: - Overall stats
    func overallStats(from sessions: [ExamSession]) -> OverallStats {
        let completed = sessions.filter { $0.sessionStatus == .completed }
        let totalQuestions = completed.flatMap { $0.decodedAnswers }.count
        let totalCorrect = completed.flatMap { $0.decodedAnswers }.filter(\.isCorrect).count
        let avgScore = completed.isEmpty ? 0 : completed.map(\.score).reduce(0, +) / Double(completed.count)
        let bestScore = completed.map(\.score).max() ?? 0

        return OverallStats(
            totalSessions: completed.count,
            totalQuestionsAnswered: totalQuestions,
            totalCorrect: totalCorrect,
            averageScore: avgScore,
            bestScore: bestScore
        )
    }
}

// MARK: - Overall Stats
struct OverallStats {
    let totalSessions: Int
    let totalQuestionsAnswered: Int
    let totalCorrect: Int
    let averageScore: Double
    let bestScore: Double

    var accuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalQuestionsAnswered)
    }

    var accuracyPercent: Int { Int(accuracy * 100) }
    var averageScorePercent: Int { Int(averageScore * 100) }
    var bestScorePercent: Int { Int(bestScore * 100) }
}
