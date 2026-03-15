//
//  StudyView.swift
//  TLCExamAce
//

import SwiftUI
import SwiftData

struct StudyView: View {
    @Environment(AppStateManager.self) private var appState
    @Environment(\.modelContext) private var context
    @State private var viewModel = StudyViewModel()
    @State private var showCategoryPicker = false

    var body: some View {
        NavigationStack {
            if viewModel.isSessionActive {
                studySessionView
            } else {
                categorySelectionView
            }
        }
        .onAppear {
            viewModel.configure(context: context, language: appState.selectedLanguage)
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerSheet(viewModel: viewModel)
        }
    }

    // MARK: - Category Selection
    private var categorySelectionView: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard

                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose a Topic")
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        // All Categories
                        categoryButton(title: "All Topics", icon: "books.vertical.fill", color: TLCColors.primary, count: QuestionBank.shared.allQuestions.count) {
                            viewModel.startSession()
                        }

                        ForEach(QuestionCategory.allCases) { category in
                            let count = QuestionBank.shared.questions(for: category).count
                            categoryButton(title: category.rawValue, icon: category.icon, color: TLCColors.primary, count: count) {
                                viewModel.startSession(category: category)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(TLCColors.surface)
        .navigationTitle("Study Mode")
        .navigationBarTitleDisplayMode(.large)
    }

    private var headerCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "book.fill")
                .font(.system(size: 36))
                .foregroundStyle(TLCColors.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Study Mode")
                    .font(.headline)
                Text("Learn with detailed explanations after each answer.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TLCColors.cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func categoryButton(title: String, icon: String, color: Color, count: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                Text("\(count) questions")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(TLCColors.cardBG)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Study Session
    private var studySessionView: some View {
        VStack(spacing: 0) {
            studyProgressBar

            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 20) {
                        questionCard(question: question)
                        answersSection(question: question)
                        if viewModel.showExplanation {
                            explanationCard(question: question)
                        }
                        navigationButtons
                    }
                    .padding()
                }
            }
        }
        .background(TLCColors.surface)
        .navigationTitle(viewModel.selectedCategory?.rawValue ?? "All Topics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("End") { viewModel.endSession() }
                    .foregroundStyle(TLCColors.danger)
            }
        }
    }

    private var studyProgressBar: some View {
        VStack(spacing: 4) {
            ProgressView(value: viewModel.progress)
                .tint(TLCColors.primary)
            Text("Question \(viewModel.currentIndex + 1) of \(viewModel.currentQuestions.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
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
        VStack(spacing: 10) {
            let options = question.localizedOptions(for: appState.selectedLanguage)
            ForEach(options.indices, id: \.self) { idx in
                AnswerOptionButton(
                    text: options[idx],
                    index: idx,
                    selectedIndex: viewModel.answeredCurrent,
                    correctIndex: question.correctIndex,
                    isRevealed: viewModel.showExplanation
                ) {
                    viewModel.selectAnswer(idx)
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
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(TLCColors.primary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(TLCColors.primary.opacity(0.3), lineWidth: 1))
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if viewModel.currentIndex > 0 {
                Button(action: { viewModel.previousQuestion() }) {
                    Label("Back", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
            }

            if viewModel.answeredCurrent != nil {
                Button(action: { viewModel.nextQuestion() }) {
                    Label(viewModel.isLastQuestion ? "Finish" : "Next", systemImage: viewModel.isLastQuestion ? "checkmark" : "chevron.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}

// MARK: - Category Picker Sheet
struct CategoryPickerSheet: View {
    let viewModel: StudyViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(QuestionCategory.allCases) { category in
                Button {
                    viewModel.startSession(category: category)
                    dismiss()
                } label: {
                    Label(category.rawValue, systemImage: category.icon)
                }
            }
            .navigationTitle("Choose Category")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
