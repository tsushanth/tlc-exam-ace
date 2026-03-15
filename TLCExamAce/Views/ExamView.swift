//
//  ExamView.swift
//  TLCExamAce
//

import SwiftUI
import SwiftData

struct ExamView: View {
    var initialMode: ExamMode = .practice

    @Environment(AppStateManager.self) private var appState
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.modelContext) private var context

    @State private var viewModel = ExamViewModel()
    @State private var selectedMode: ExamMode = .practice
    @State private var selectedLicense: LicenseType = .all
    @State private var selectedCategory: QuestionCategory? = nil
    @State private var isExamActive: Bool = false
    @State private var showModeSelector: Bool = true

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.showResults {
                    ResultsView(engine: viewModel.engine) {
                        viewModel.reset()
                        isExamActive = false
                        showModeSelector = true
                    }
                } else if isExamActive {
                    activeExamView
                } else {
                    examSetupView
                }
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView()
        }
        .onAppear {
            viewModel.configure(context: context, storeKit: storeKit)
            selectedMode = initialMode
        }
    }

    // MARK: - Setup View
    private var examSetupView: some View {
        ScrollView {
            VStack(spacing: 20) {
                examModeSelector
                licenseTypeSelector
                categorySelector
                startButton
            }
            .padding()
        }
        .background(TLCColors.surface)
        .navigationTitle("Practice Exam")
        .navigationBarTitleDisplayMode(.large)
    }

    private var examModeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exam Mode")
                .font(.headline)

            ForEach(ExamMode.allCases, id: \.self) { mode in
                ExamModeCard(mode: mode, isSelected: selectedMode == mode, isPremiumLocked: requiresPremium(mode) && !storeKit.isPremium) {
                    selectedMode = mode
                }
            }
        }
    }

    private var licenseTypeSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("License Type")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(LicenseType.allCases, id: \.self) { type in
                        LicenseTypePill(type: type, isSelected: selectedLicense == type) {
                            selectedLicense = type
                        }
                    }
                }
            }
        }
    }

    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Category (Optional)")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    CategoryPill(title: "All", icon: "books.vertical", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(QuestionCategory.allCases) { cat in
                        CategoryPill(title: cat.rawValue, icon: cat.icon, isSelected: selectedCategory == cat) {
                            selectedCategory = cat
                        }
                    }
                }
            }
        }
    }

    private var startButton: some View {
        Button {
            startExam()
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Start \(selectedMode.rawValue)")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(.top, 8)
    }

    // MARK: - Active Exam
    private var activeExamView: some View {
        VStack(spacing: 0) {
            examHeader
            ScrollView {
                VStack(spacing: 20) {
                    if let question = viewModel.engine.currentQuestion {
                        questionCard(question: question)
                        answersSection(question: question)
                        if viewModel.engine.showExplanation {
                            explanationCard(question: question)
                        }
                    }
                    navControls
                }
                .padding()
            }
        }
        .background(TLCColors.surface)
        .navigationTitle(selectedMode.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Quit") {
                    viewModel.engine.finishExam()
                    viewModel.showResults = true
                }
                .foregroundStyle(TLCColors.danger)
            }
        }
    }

    private var examHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Q \(viewModel.engine.currentIndex + 1) / \(viewModel.engine.totalCount)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                if selectedMode == .timed {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .foregroundStyle(viewModel.engine.timeRemaining < 300 ? TLCColors.danger : TLCColors.primary)
                        Text(viewModel.engine.timeRemainingFormatted)
                            .font(.caption.bold().monospacedDigit())
                            .foregroundStyle(viewModel.engine.timeRemaining < 300 ? TLCColors.danger : .primary)
                    }
                }
                Text("\(viewModel.engine.correctCount) correct")
                    .font(.caption.bold())
                    .foregroundStyle(TLCColors.success)
            }
            ProgressView(value: viewModel.engine.progress)
                .tint(TLCColors.primary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(TLCColors.cardBG)
    }

    private func questionCard(question: Question) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CategoryBadge(category: question.category)
                DifficultyBadge(difficulty: question.difficulty)
                Spacer()
            }
            Text(question.localizedText(for: appState.selectedLanguage))
                .font(.body.bold())
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func answersSection(question: Question) -> some View {
        let options = question.localizedOptions(for: appState.selectedLanguage)
        return VStack(spacing: 10) {
            ForEach(options.indices, id: \.self) { idx in
                AnswerOptionButton(
                    text: options[idx],
                    index: idx,
                    selectedIndex: viewModel.engine.selectedAnswerForCurrent,
                    correctIndex: question.correctIndex,
                    isRevealed: viewModel.engine.showExplanation || (selectedMode == .practice && viewModel.engine.selectedAnswerForCurrent != nil)
                ) {
                    viewModel.submitAnswer(idx)
                }
            }
        }
    }

    private func explanationCard(question: Question) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Explanation", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(TLCColors.primary)
            Text(question.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(TLCColors.primary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(TLCColors.primary.opacity(0.3), lineWidth: 1))
    }

    private var navControls: some View {
        HStack(spacing: 12) {
            if viewModel.engine.currentIndex > 0 {
                Button { viewModel.engine.previousQuestion() } label: {
                    Label("Back", systemImage: "chevron.left").frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
            }

            if viewModel.engine.selectedAnswerForCurrent != nil {
                Button { viewModel.advance() } label: {
                    Label(viewModel.engine.isLastQuestion ? "Finish" : "Next",
                          systemImage: viewModel.engine.isLastQuestion ? "checkmark" : "chevron.right")
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    // MARK: - Helpers
    private func requiresPremium(_ mode: ExamMode) -> Bool {
        mode == .timed || mode == .weakAreas
    }

    private func startExam() {
        viewModel.startExam(mode: selectedMode, licenseType: selectedLicense, category: selectedCategory)
        if !viewModel.showPaywall {
            isExamActive = true
        }
    }
}

// MARK: - Supporting Sub-Views
struct ExamModeCard: View {
    let mode: ExamMode
    let isSelected: Bool
    let isPremiumLocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : TLCColors.primary)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? TLCColors.primary : TLCColors.primary.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(mode.rawValue)
                            .font(.subheadline.bold())
                            .foregroundStyle(isSelected ? TLCColors.primary : .primary)
                        if isPremiumLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(TLCColors.accent)
                        }
                    }
                    Text(mode.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(TLCColors.primary)
                }
            }
            .padding(14)
            .background(isSelected ? TLCColors.primary.opacity(0.08) : TLCColors.cardBG)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? TLCColors.primary : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

struct LicenseTypePill: View {
    let type: LicenseType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(type.rawValue)
                .font(.caption.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? TLCColors.primary : TLCColors.cardBG)
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption)
                Text(title).font(.caption.bold())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? TLCColors.primary : TLCColors.cardBG)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}
