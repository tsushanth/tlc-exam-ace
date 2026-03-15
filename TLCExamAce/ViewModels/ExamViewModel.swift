//
//  ExamViewModel.swift
//  TLCExamAce
//

import Foundation
import SwiftData

@MainActor
@Observable
final class ExamViewModel {
    let engine = ExamEngine()
    var showResults: Bool = false
    var showPaywall: Bool = false
    var session: ExamSession?

    private var context: ModelContext?
    private var storeKit: StoreKitManager?

    func configure(context: ModelContext, storeKit: StoreKitManager) {
        self.context = context
        self.storeKit = storeKit
    }

    func startExam(mode: ExamMode, licenseType: LicenseType = .all, category: QuestionCategory? = nil) {
        guard let storeKit else { return }

        // Paywall gate: timed exam requires premium
        if mode == .timed && !storeKit.isPremium {
            showPaywall = true
            return
        }

        // Create session
        let newSession = ExamSession(mode: mode, licenseType: licenseType)
        session = newSession
        context?.insert(newSession)

        // Fetch weak categories if needed
        var weakCats: [QuestionCategory] = []
        if mode == .weakAreas, let ctx = context {
            weakCats = ProgressTracker.shared.weakCategories(in: ctx)
        }

        engine.setup(mode: mode, licenseType: licenseType, category: category, weakCategories: weakCats)

        if mode == .timed {
            engine.startTimer()
        }

        showResults = false
        AnalyticsService.shared.track(.examStarted(mode: mode.rawValue, category: category?.rawValue))
    }

    func submitAnswer(_ index: Int) {
        engine.selectAnswer(index)

        if engine.mode == .practice || engine.mode == .timed {
            // Auto-advance after brief delay handled in view
        }
    }

    func advance() {
        if engine.isLastQuestion && engine.selectedAnswerForCurrent != nil {
            finishExam()
        } else {
            engine.nextQuestion()
        }
    }

    func finishExam() {
        engine.finishExam()

        // Save session
        if let session, let context {
            for record in engine.answerRecords {
                session.addAnswer(record)
            }
            session.complete()

            ProgressTracker.shared.record(session: session, in: context)
            try? context.save()
        }

        let score = engine.scorePercent
        let passed = engine.passed
        AnalyticsService.shared.track(.examCompleted(mode: engine.mode.rawValue, score: score, passed: passed))
        showResults = true
    }

    func reset() {
        showResults = false
        session = nil
    }
}
