//
//  ProgressView.swift
//  TLCExamAce
//

import SwiftUI
import SwiftData

struct TLCProgressView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ExamSession.startedAt, order: .reverse) private var sessions: [ExamSession]
    @Query private var topicProgress: [TopicProgress]

    @State private var viewModel = ProgressViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    overallStatsSection
                    streakSection
                    weeklyActivitySection
                    topicsSection
                    recentSessionsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(TLCColors.surface)
            .navigationTitle("My Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.load(context: context)
        }
        .onChange(of: sessions.count) { _, _ in viewModel.load(context: context) }
    }

    // MARK: - Overall Stats
    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overall Stats")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statCard(value: "\(viewModel.overallStats.totalSessions)", label: "Exams Taken", icon: "checkmark.seal.fill", color: TLCColors.primary)
                statCard(value: "\(viewModel.overallStats.totalQuestionsAnswered)", label: "Questions Answered", icon: "questionmark.circle.fill", color: TLCColors.accent)
                statCard(value: "\(viewModel.overallStats.averageScorePercent)%", label: "Average Score", icon: "chart.line.uptrend.xyaxis", color: TLCColors.success)
                statCard(value: "\(viewModel.overallStats.bestScorePercent)%", label: "Best Score", icon: "star.fill", color: TLCColors.warning)
            }
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Streak
    private var streakSection: some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.currentStreak) Day Streak")
                    .font(.title2.bold())
                Text(viewModel.currentStreak > 0 ? "Keep it up! Study daily to maintain your streak." : "Start studying today to build your streak!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Weekly Activity
    private var weeklyActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(viewModel.weeklyActivity) { day in
                    VStack(spacing: 4) {
                        let maxQ = viewModel.weeklyActivity.map(\.questionsAnswered).max() ?? 1
                        let h = max(4, CGFloat(day.questionsAnswered) / CGFloat(max(maxQ, 1)) * 60)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(day.isToday ? TLCColors.primary : (day.questionsAnswered > 0 ? TLCColors.primary.opacity(0.5) : TLCColors.surface))
                            .frame(height: h)
                            .animation(.easeOut, value: day.questionsAnswered)

                        Text(day.dayLabel)
                            .font(.caption2)
                            .foregroundStyle(day.isToday ? TLCColors.primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 80, alignment: .bottom)
            .padding()
            .background(TLCColors.cardBG)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Topics
    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Topics")
                .font(.headline)

            if topicProgress.isEmpty {
                Text("Complete some practice sessions to see your topic progress.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(TLCColors.cardBG)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                ForEach(topicProgress.sorted { $0.accuracy < $1.accuracy }, id: \.id) { progress in
                    TopicProgressRow(progress: progress)
                }
            }
        }
    }

    // MARK: - Recent Sessions
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Exams")
                .font(.headline)

            let completed = sessions.filter { $0.sessionStatus == .completed }

            if completed.isEmpty {
                Text("No completed exams yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(TLCColors.cardBG)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                ForEach(completed.prefix(10)) { session in
                    DetailedSessionRow(session: session)
                }
            }
        }
    }
}

// MARK: - Topic Progress Row
struct TopicProgressRow: View {
    let progress: TopicProgress

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: QuestionCategory(rawValue: progress.category)?.icon ?? "circle.fill")
                .foregroundStyle(masteryColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(progress.category)
                        .font(.subheadline.bold())
                    Spacer()
                    Text("\(progress.accuracyPercent)%")
                        .font(.caption.bold())
                        .foregroundStyle(masteryColor)
                }
                ProgressView(value: progress.accuracy)
                    .tint(masteryColor)
                HStack {
                    Text(progress.masteryLevel.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(progress.totalAttempted) attempts")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var masteryColor: Color {
        switch progress.masteryLevel {
        case .needsWork: return TLCColors.danger
        case .developing: return TLCColors.warning
        case .proficient: return TLCColors.primary
        case .mastered: return TLCColors.success
        }
    }
}

// MARK: - Detailed Session Row
struct DetailedSessionRow: View {
    let session: ExamSession

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(session.passed ? TLCColors.success.opacity(0.15) : TLCColors.danger.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Text("\(session.scorePercent)%")
                        .font(.caption.bold())
                        .foregroundStyle(session.passed ? TLCColors.success : TLCColors.danger)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(session.examMode.rawValue)
                    .font(.subheadline.bold())
                Text("\(session.correctCount)/\(session.totalAnswered) correct")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(session.startedAt, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
