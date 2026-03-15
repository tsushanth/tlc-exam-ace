//
//  ProgressViewModel.swift
//  TLCExamAce
//

import Foundation
import SwiftData

@MainActor
@Observable
final class ProgressViewModel {
    var topicProgress: [TopicProgress] = []
    var recentSessions: [ExamSession] = []
    var overallStats: OverallStats = OverallStats(totalSessions: 0, totalQuestionsAnswered: 0, totalCorrect: 0, averageScore: 0, bestScore: 0)
    var weeklyActivity: [DayActivity] = []

    func load(context: ModelContext) {
        // Fetch topic progress
        let progressDescriptor = FetchDescriptor<TopicProgress>()
        topicProgress = (try? context.fetch(progressDescriptor)) ?? []

        // Fetch sessions (last 50)
        var sessionDescriptor = FetchDescriptor<ExamSession>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        sessionDescriptor.fetchLimit = 50
        let sessions = (try? context.fetch(sessionDescriptor)) ?? []
        recentSessions = sessions.filter { $0.sessionStatus == .completed }

        // Overall stats
        overallStats = ProgressTracker.shared.overallStats(from: recentSessions)

        // Weekly activity
        weeklyActivity = buildWeeklyActivity(from: recentSessions)
    }

    var weakCategories: [TopicProgress] {
        topicProgress
            .filter { $0.totalAttempted >= 5 && $0.accuracy < 0.7 }
            .sorted { $0.accuracy < $1.accuracy }
    }

    var strongCategories: [TopicProgress] {
        topicProgress
            .filter { $0.totalAttempted >= 5 && $0.accuracy >= 0.8 }
            .sorted { $0.accuracy > $1.accuracy }
    }

    var currentStreak: Int {
        // Calculate consecutive days with at least one session
        var streak = 0
        var checkDate = Calendar.current.startOfDay(for: Date())

        for _ in 0..<365 {
            let hasActivity = recentSessions.contains { session in
                Calendar.current.startOfDay(for: session.startedAt) == checkDate
            }
            if hasActivity {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        return streak
    }

    private func buildWeeklyActivity(from sessions: [ExamSession]) -> [DayActivity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).map { daysAgo in
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let daySessions = sessions.filter {
                calendar.startOfDay(for: $0.startedAt) == day
            }
            let questionsAnswered = daySessions.flatMap { $0.decodedAnswers }.count
            return DayActivity(date: day, questionsAnswered: questionsAnswered, sessionsCount: daySessions.count)
        }.reversed()
    }
}

// MARK: - Day Activity
struct DayActivity: Identifiable {
    let id = UUID()
    let date: Date
    let questionsAnswered: Int
    let sessionsCount: Int

    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}
