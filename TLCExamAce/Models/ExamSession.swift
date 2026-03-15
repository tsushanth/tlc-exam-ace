//
//  ExamSession.swift
//  TLCExamAce
//

import Foundation
import SwiftData

// MARK: - Exam Mode
enum ExamMode: String, Codable, CaseIterable {
    case practice = "Practice"
    case timed = "Timed Exam"
    case study = "Study Mode"
    case weakAreas = "Weak Areas"

    var description: String {
        switch self {
        case .practice: return "Practice with immediate feedback"
        case .timed: return "Simulates the real TLC exam with time pressure"
        case .study: return "Learn with detailed explanations"
        case .weakAreas: return "Focus on your weakest topics"
        }
    }

    var icon: String {
        switch self {
        case .practice: return "pencil.circle.fill"
        case .timed: return "timer"
        case .study: return "book.circle.fill"
        case .weakAreas: return "exclamationmark.circle.fill"
        }
    }

    var questionCount: Int {
        switch self {
        case .practice: return 20
        case .timed: return 40
        case .study: return 15
        case .weakAreas: return 20
        }
    }

    var timeLimitMinutes: Int? {
        switch self {
        case .timed: return 60
        default: return nil
        }
    }

    var passingScore: Double {
        switch self {
        case .timed: return 0.70
        default: return 0.0
        }
    }
}

// MARK: - Exam Session Status
enum ExamSessionStatus: String, Codable {
    case inProgress = "In Progress"
    case completed = "Completed"
    case abandoned = "Abandoned"
    case paused = "Paused"
}

// MARK: - Exam Session (SwiftData Model)
@Model
final class ExamSession {
    var id: UUID
    var mode: String            // ExamMode.rawValue
    var licenseType: String     // LicenseType.rawValue
    var questionIDs: [UUID]
    var answerRecords: [Data]   // Encoded [AnswerRecord]
    var status: String          // ExamSessionStatus.rawValue
    var startedAt: Date
    var completedAt: Date?
    var totalTimeSeconds: Double
    var categoryFilter: String? // QuestionCategory.rawValue

    init(
        mode: ExamMode,
        licenseType: LicenseType = .all,
        questionIDs: [UUID] = [],
        categoryFilter: QuestionCategory? = nil
    ) {
        self.id = UUID()
        self.mode = mode.rawValue
        self.licenseType = licenseType.rawValue
        self.questionIDs = questionIDs
        self.answerRecords = []
        self.status = ExamSessionStatus.inProgress.rawValue
        self.startedAt = Date()
        self.completedAt = nil
        self.totalTimeSeconds = 0
        self.categoryFilter = categoryFilter?.rawValue
    }

    // MARK: - Computed
    var examMode: ExamMode { ExamMode(rawValue: mode) ?? .practice }
    var sessionStatus: ExamSessionStatus { ExamSessionStatus(rawValue: status) ?? .inProgress }

    var decodedAnswers: [AnswerRecord] {
        answerRecords.compactMap { data in
            try? JSONDecoder().decode(AnswerRecord.self, from: data)
        }
    }

    var correctCount: Int { decodedAnswers.filter(\.isCorrect).count }
    var totalAnswered: Int { decodedAnswers.count }
    var score: Double {
        guard totalAnswered > 0 else { return 0 }
        return Double(correctCount) / Double(totalAnswered)
    }
    var scorePercent: Int { Int(score * 100) }
    var passed: Bool { score >= examMode.passingScore }

    var averageTimePerQuestion: Double {
        let answers = decodedAnswers
        guard !answers.isEmpty else { return 0 }
        return answers.map(\.timeSpent).reduce(0, +) / Double(answers.count)
    }

    func addAnswer(_ record: AnswerRecord) {
        if let data = try? JSONEncoder().encode(record) {
            answerRecords.append(data)
        }
    }

    func complete() {
        status = ExamSessionStatus.completed.rawValue
        completedAt = Date()
        totalTimeSeconds = Date().timeIntervalSince(startedAt)
    }
}
