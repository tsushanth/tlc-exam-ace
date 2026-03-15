//
//  StudyViewModel.swift
//  TLCExamAce
//

import Foundation
import SwiftData

@MainActor
@Observable
final class StudyViewModel {
    var selectedCategory: QuestionCategory? = nil
    var selectedLicenseType: LicenseType = .all
    var currentQuestions: [Question] = []
    var currentIndex: Int = 0
    var showExplanation: Bool = false
    var isSessionActive: Bool = false
    var sessionAnswers: [UUID: Int] = [:]
    var sessionStartTime: Date = Date()
    var language: AppLanguage = .english

    private var context: ModelContext?

    func configure(context: ModelContext, language: AppLanguage) {
        self.context = context
        self.language = language
    }

    var currentQuestion: Question? {
        guard currentIndex < currentQuestions.count else { return nil }
        return currentQuestions[currentIndex]
    }

    var progress: Double {
        guard !currentQuestions.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(currentQuestions.count)
    }

    var isLastQuestion: Bool { currentIndex >= currentQuestions.count - 1 }

    var answeredCurrent: Int? {
        guard let q = currentQuestion else { return nil }
        return sessionAnswers[q.id]
    }

    // MARK: - Start Study Session
    func startSession(category: QuestionCategory? = nil, licenseType: LicenseType = .all) {
        self.selectedCategory = category
        self.selectedLicenseType = licenseType
        currentQuestions = QuestionBank.shared.questions(
            for: category,
            licenseType: licenseType,
            limit: ExamMode.study.questionCount
        )
        currentIndex = 0
        showExplanation = false
        sessionAnswers = [:]
        sessionStartTime = Date()
        isSessionActive = true
        AnalyticsService.shared.track(.studySessionStarted(category: category?.rawValue ?? "all"))
    }

    func selectAnswer(_ index: Int) {
        guard let question = currentQuestion else { return }
        guard sessionAnswers[question.id] == nil else { return }
        sessionAnswers[question.id] = index
        showExplanation = true
        AnalyticsService.shared.track(.questionAnswered(correct: index == question.correctIndex, category: question.category.rawValue))
    }

    func nextQuestion() {
        showExplanation = false
        if !isLastQuestion {
            currentIndex += 1
        } else {
            endSession()
        }
    }

    func previousQuestion() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        showExplanation = sessionAnswers[currentQuestion?.id ?? UUID()] != nil
    }

    func endSession() {
        let duration = Date().timeIntervalSince(sessionStartTime)
        isSessionActive = false
        AnalyticsService.shared.track(.studySessionCompleted(duration: duration))
        try? context?.save()
    }

    // MARK: - Questions by category for menu
    var categoriesWithCounts: [(category: QuestionCategory, count: Int)] {
        QuestionCategory.allCases.map { cat in
            let count = QuestionBank.shared.questions(for: cat).count
            return (category: cat, count: count)
        }
    }
}
