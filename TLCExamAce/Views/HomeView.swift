//
//  HomeView.swift
//  TLCExamAce
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppStateManager.self) private var appState
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.modelContext) private var context
    @Query(sort: \ExamSession.startedAt, order: .reverse) private var sessions: [ExamSession]
    @Query private var topicProgress: [TopicProgress]

    @State private var showPaywall = false
    @State private var showExamPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    quickStatsRow
                    quickActionsGrid
                    if !weakCategories.isEmpty {
                        weakAreasSection
                    }
                    recentActivitySection
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(TLCColors.surface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("TLC Exam Ace")
                        .font(.headline)
                        .foregroundStyle(TLCColors.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !storeKit.isPremium {
                        Button("Premium") { showPaywall = true }
                            .font(.caption.bold())
                            .foregroundStyle(TLCColors.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(TLCColors.primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ready to ace your exam?")
                        .font(.title2.bold())
                    Text("NYC TLC License Practice")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "car.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(TLCColors.primary)
            }

            if let streak = currentStreak, streak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(streak) day streak!")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding()
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Quick Stats
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "\(completedSessions)", label: "Exams Taken", icon: "checkmark.seal.fill", color: TLCColors.primary)
            statCard(value: "\(bestScorePercent)%", label: "Best Score", icon: "star.fill", color: TLCColors.accent)
            statCard(value: "\(QuestionBank.shared.allQuestions.count)+", label: "Questions", icon: "list.bullet", color: TLCColors.success)
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Quick Actions
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(ExamMode.allCases, id: \.self) { mode in
                    NavigationLink {
                        ExamView(initialMode: mode)
                    } label: {
                        modeCard(mode)
                    }
                }
            }
        }
    }

    private func modeCard(_ mode: ExamMode) -> some View {
        HStack(spacing: 12) {
            Image(systemName: mode.icon)
                .font(.title3)
                .foregroundStyle(TLCColors.primary)
                .frame(width: 36, height: 36)
                .background(TLCColors.primary.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(mode.rawValue)
                        .font(.caption.bold())
                        .foregroundStyle(.primary)
                    if (mode == .timed || mode == .weakAreas) && !storeKit.isPremium {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(TLCColors.accent)
                    }
                }
                Text("\(mode.questionCount) Qs")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Weak Areas
    private var weakAreasSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Focus Areas")
                    .font(.headline)
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(TLCColors.warning)
                Spacer()
            }

            ForEach(weakCategories.prefix(3), id: \.category) { item in
                WeakAreaRow(progress: item.progress)
            }
        }
    }

    // MARK: - Recent Activity
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Activity")
                .font(.headline)

            if recentSessions.isEmpty {
                Text("No exams taken yet. Start practicing!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(TLCColors.cardBG)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(recentSessions.prefix(3)) { session in
                    SessionRow(session: session)
                }
            }
        }
    }

    // MARK: - Computed
    private var completedSessions: Int {
        sessions.filter { $0.sessionStatus == .completed }.count
    }

    private var bestScorePercent: Int {
        sessions.filter { $0.sessionStatus == .completed }.map(\.scorePercent).max() ?? 0
    }

    private var recentSessions: [ExamSession] {
        sessions.filter { $0.sessionStatus == .completed }
    }

    private var weakCategories: [(category: String, progress: TopicProgress)] {
        topicProgress
            .filter { $0.totalAttempted >= 3 && $0.accuracy < 0.7 }
            .sorted { $0.accuracy < $1.accuracy }
            .map { (category: $0.category, progress: $0) }
    }

    private var currentStreak: Int? {
        var streak = 0
        var checkDate = Calendar.current.startOfDay(for: Date())
        for _ in 0..<30 {
            let hasActivity = sessions.contains {
                Calendar.current.startOfDay(for: $0.startedAt) == checkDate
            }
            if hasActivity {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else { break }
        }
        return streak > 0 ? streak : nil
    }
}

// MARK: - Weak Area Row
struct WeakAreaRow: View {
    let progress: TopicProgress

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: QuestionCategory(rawValue: progress.category)?.icon ?? "questionmark.circle")
                .foregroundStyle(TLCColors.warning)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(progress.category)
                    .font(.subheadline.bold())
                ProgressView(value: progress.accuracy)
                    .tint(progress.accuracy < 0.5 ? TLCColors.danger : TLCColors.warning)
            }

            Text("\(progress.accuracyPercent)%")
                .font(.caption.bold())
                .foregroundStyle(TLCColors.warning)
        }
        .padding(12)
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Session Row
struct SessionRow: View {
    let session: ExamSession

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(session.examMode.rawValue)
                    .font(.subheadline.bold())
                Text(session.startedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(session.scorePercent)%")
                    .font(.title3.bold())
                    .foregroundStyle(session.passed ? TLCColors.success : TLCColors.danger)
                Text(session.passed ? "Passed" : "Failed")
                    .font(.caption)
                    .foregroundStyle(session.passed ? TLCColors.success : TLCColors.danger)
            }
        }
        .padding(12)
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
