//
//  ResultsView.swift
//  TLCExamAce
//

import SwiftUI

struct ResultsView: View {
    let engine: ExamEngine
    let onDone: () -> Void

    @State private var showIncorrect: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                scoreHero
                statsGrid
                categoryBreakdown
                incorrectQuestionsSection
                actionButtons
            }
            .padding()
        }
        .background(TLCColors.surface)
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Score Hero
    private var scoreHero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(engine.passed ? TLCColors.success.opacity(0.2) : TLCColors.danger.opacity(0.2), lineWidth: 16)
                    .frame(width: 140, height: 140)
                Circle()
                    .trim(from: 0, to: engine.score)
                    .stroke(engine.passed ? TLCColors.success : TLCColors.danger,
                            style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0), value: engine.score)

                VStack(spacing: 2) {
                    Text("\(engine.scorePercent)%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(engine.passed ? TLCColors.success : TLCColors.danger)
                    Text(engine.passed ? "PASSED" : "FAILED")
                        .font(.caption.bold())
                        .foregroundStyle(engine.passed ? TLCColors.success : TLCColors.danger)
                }
            }

            Text(engine.passed ? "Congratulations! You passed!" : "Keep studying — you'll get there!")
                .font(.headline)
                .multilineTextAlignment(.center)

            if engine.mode == .timed {
                Text("Passing score: \(Int(engine.mode.passingScore * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical)
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            resultStat(value: "\(engine.correctCount)", label: "Correct", color: TLCColors.success)
            resultStat(value: "\(engine.answeredCount - engine.correctCount)", label: "Wrong", color: TLCColors.danger)
            resultStat(value: formatTime(engine.answeredCount > 0 ? engine.answerRecords.map(\.timeSpent).reduce(0, +) : 0),
                       label: "Total Time", color: TLCColors.primary)
        }
    }

    private func resultStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Category Breakdown
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Category")
                .font(.headline)

            ForEach(engine.categoryBreakdown(), id: \.category) { item in
                let pct = item.total > 0 ? Double(item.correct) / Double(item.total) : 0
                HStack(spacing: 12) {
                    Image(systemName: item.category.icon)
                        .foregroundStyle(TLCColors.primary)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.category.rawValue)
                                .font(.subheadline)
                            Spacer()
                            Text("\(item.correct)/\(item.total)")
                                .font(.caption.bold())
                                .foregroundStyle(pct >= 0.7 ? TLCColors.success : TLCColors.danger)
                        }
                        ProgressView(value: pct)
                            .tint(pct >= 0.7 ? TLCColors.success : TLCColors.danger)
                    }
                }
            }
        }
        .padding()
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Incorrect Questions
    private var incorrectQuestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation { showIncorrect.toggle() }
            } label: {
                HStack {
                    Text("Review Incorrect Answers")
                        .font(.headline)
                    Spacer()
                    Text("\(engine.incorrectQuestions().count)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(TLCColors.danger)
                        .clipShape(Capsule())
                    Image(systemName: showIncorrect ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)

            if showIncorrect {
                ForEach(engine.incorrectQuestions()) { question in
                    IncorrectQuestionCard(question: question, engine: engine)
                }
            }
        }
        .padding()
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: onDone) {
                Label("Back to Menu", systemImage: "house.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 { return "\(mins)m \(secs)s" }
        return "\(secs)s"
    }
}

// MARK: - Incorrect Question Card
struct IncorrectQuestionCard: View {
    let question: Question
    let engine: ExamEngine
    @State private var showExp: Bool = false

    var yourAnswer: String? {
        guard let idx = engine.answers[question.id], idx < question.options.count else { return nil }
        return question.options[idx]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(question.text)
                .font(.subheadline.bold())
                .fixedSize(horizontal: false, vertical: true)

            if let yours = yourAnswer {
                Label("Your answer: \(yours)", systemImage: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(TLCColors.danger)
            }
            Label("Correct: \(question.correctAnswer)", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(TLCColors.success)

            Button { withAnimation { showExp.toggle() } } label: {
                Text(showExp ? "Hide explanation" : "Show explanation")
                    .font(.caption)
                    .foregroundStyle(TLCColors.primary)
            }

            if showExp {
                Text(question.explanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(10)
                    .background(TLCColors.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(TLCColors.danger.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(TLCColors.danger.opacity(0.2), lineWidth: 1))
    }
}
