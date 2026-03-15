//
//  ExamEngine.swift
//  TLCExamAce
//
//  Core exam logic: question selection, scoring, and session management
//

import Foundation
import Combine

// MARK: - Exam Engine
@MainActor
@Observable
final class ExamEngine {
    // MARK: - State
    private(set) var questions: [Question] = []
    private(set) var currentIndex: Int = 0
    private(set) var answers: [UUID: Int] = [:]          // questionID -> selectedIndex
    private(set) var answerRecords: [AnswerRecord] = []
    private(set) var mode: ExamMode = .practice
    private(set) var isComplete: Bool = false
    private(set) var timeRemaining: TimeInterval = 0
    private(set) var isTimerRunning: Bool = false
    private(set) var showExplanation: Bool = false
    private(set) var questionStartTime: Date = Date()

    private var timerTask: Task<Void, Never>?

    // MARK: - Computed
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var answeredCount: Int { answerRecords.count }
    var correctCount: Int { answerRecords.filter(\.isCorrect).count }
    var totalCount: Int { questions.count }

    var score: Double {
        guard answeredCount > 0 else { return 0 }
        return Double(correctCount) / Double(answeredCount)
    }

    var scorePercent: Int { Int(score * 100) }

    var passed: Bool { score >= mode.passingScore }

    var isLastQuestion: Bool { currentIndex >= questions.count - 1 }

    var selectedAnswerForCurrent: Int? {
        guard let q = currentQuestion else { return nil }
        return answers[q.id]
    }

    var timeRemainingFormatted: String {
        let mins = Int(timeRemaining) / 60
        let secs = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    // MARK: - Setup
    func setup(mode: ExamMode, licenseType: LicenseType = .all, category: QuestionCategory? = nil, weakCategories: [QuestionCategory] = []) {
        self.mode = mode
        isComplete = false
        currentIndex = 0
        answers = [:]
        answerRecords = []
        showExplanation = false

        let bank = QuestionBank.shared

        switch mode {
        case .weakAreas:
            questions = bank.weakAreaQuestions(weak: weakCategories.isEmpty ? QuestionCategory.allCases : weakCategories, limit: mode.questionCount)
        default:
            questions = bank.questions(for: category, licenseType: licenseType, limit: mode.questionCount)
        }

        if let timeLimit = mode.timeLimitMinutes {
            timeRemaining = TimeInterval(timeLimit * 60)
        }

        questionStartTime = Date()
    }

    // MARK: - Answer
    func selectAnswer(_ index: Int) {
        guard let question = currentQuestion, !isComplete else { return }
        guard answers[question.id] == nil else { return } // Don't re-answer

        let timeSpent = Date().timeIntervalSince(questionStartTime)
        answers[question.id] = index

        let record = AnswerRecord(
            questionID: question.id,
            selectedIndex: index,
            correctIndex: question.correctIndex,
            timeSpent: timeSpent
        )
        answerRecords.append(record)

        if mode == .study {
            showExplanation = true
        }
    }

    func toggleExplanation() {
        showExplanation.toggle()
    }

    // MARK: - Navigation
    func nextQuestion() {
        showExplanation = false
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            questionStartTime = Date()
        } else {
            finishExam()
        }
    }

    func previousQuestion() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        showExplanation = false
    }

    func jumpToQuestion(_ index: Int) {
        guard index >= 0 && index < questions.count else { return }
        currentIndex = index
        showExplanation = false
    }

    // MARK: - Timer
    func startTimer() {
        guard mode.timeLimitMinutes != nil else { return }
        isTimerRunning = true
        timerTask = Task {
            while !Task.isCancelled && timeRemaining > 0 && !isComplete {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
                if timeRemaining <= 0 {
                    finishExam()
                }
            }
        }
    }

    func pauseTimer() {
        isTimerRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    // MARK: - Finish
    func finishExam() {
        pauseTimer()
        isComplete = true
    }

    // MARK: - Results
    func categoryBreakdown() -> [(category: QuestionCategory, correct: Int, total: Int)] {
        var breakdown: [QuestionCategory: (correct: Int, total: Int)] = [:]

        for (idx, question) in questions.enumerated() {
            let cat = question.category
            var current = breakdown[cat] ?? (0, 0)
            current.1 += 1
            if idx < answerRecords.count && answerRecords[idx].isCorrect {
                current.0 += 1
            }
            breakdown[cat] = current
        }

        return breakdown.map { (category: $0.key, correct: $0.value.correct, total: $0.value.total) }
            .sorted { $0.category.rawValue < $1.category.rawValue }
    }

    func weakCategories() -> [QuestionCategory] {
        categoryBreakdown()
            .filter { $0.total > 0 && Double($0.correct) / Double($0.total) < 0.7 }
            .map(\.category)
    }

    func incorrectQuestions() -> [Question] {
        let incorrectIDs = Set(answerRecords.filter { !$0.isCorrect }.map(\.questionID))
        return questions.filter { incorrectIDs.contains($0.id) }
    }
}
