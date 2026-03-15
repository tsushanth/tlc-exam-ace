//
//  SharedComponents.swift
//  TLCExamAce
//
//  Reusable UI components used across multiple views
//

import SwiftUI

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(TLCColors.primary.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundStyle(.white)
            .font(.subheadline.bold())
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(TLCColors.cardBG)
            .foregroundStyle(TLCColors.primary)
            .font(.subheadline.bold())
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(TLCColors.primary.opacity(0.4), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Answer Option Button
struct AnswerOptionButton: View {
    let text: String
    let index: Int
    let selectedIndex: Int?
    let correctIndex: Int
    let isRevealed: Bool
    let onTap: () -> Void

    private var isSelected: Bool { selectedIndex == index }
    private var isCorrect: Bool { index == correctIndex }
    private var hasAnswered: Bool { selectedIndex != nil }

    private var bgColor: Color {
        guard isRevealed || hasAnswered else { return TLCColors.cardBG }
        if isCorrect { return TLCColors.success.opacity(0.12) }
        if isSelected && !isCorrect { return TLCColors.danger.opacity(0.12) }
        return TLCColors.cardBG
    }

    private var borderColor: Color {
        guard isRevealed || hasAnswered else {
            return isSelected ? TLCColors.primary : Color.gray.opacity(0.25)
        }
        if isCorrect { return TLCColors.success }
        if isSelected && !isCorrect { return TLCColors.danger }
        return Color.gray.opacity(0.25)
    }

    private var trailingIcon: String? {
        guard isRevealed || hasAnswered else { return nil }
        if isCorrect { return "checkmark.circle.fill" }
        if isSelected && !isCorrect { return "xmark.circle.fill" }
        return nil
    }

    private var trailingIconColor: Color {
        isCorrect ? TLCColors.success : TLCColors.danger
    }

    var body: some View {
        Button(action: {
            guard !hasAnswered else { return }
            onTap()
        }) {
            HStack(spacing: 14) {
                // Index label
                Text(["A", "B", "C", "D"][safe: index] ?? "\(index + 1)")
                    .font(.caption.bold())
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .frame(width: 28, height: 28)
                    .background(isSelected ? TLCColors.primary : Color.gray.opacity(0.15))
                    .clipShape(Circle())

                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                if let icon = trailingIcon {
                    Image(systemName: icon)
                        .foregroundStyle(trailingIconColor)
                        .font(.title3)
                }
            }
            .padding(14)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: isSelected || (isRevealed && isCorrect) ? 1.5 : 1))
        }
        .disabled(hasAnswered)
        .animation(.easeOut(duration: 0.2), value: isRevealed)
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let category: QuestionCategory

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.caption2)
            Text(category.rawValue)
                .font(.caption2.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(TLCColors.primary.opacity(0.1))
        .foregroundStyle(TLCColors.primary)
        .clipShape(Capsule())
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: Difficulty

    private var color: Color {
        switch difficulty {
        case .easy: return TLCColors.success
        case .medium: return TLCColors.warning
        case .hard: return TLCColors.danger
        }
    }

    var body: some View {
        Text(difficulty.label)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - Score Ring
struct ScoreRingView: View {
    let score: Double
    let size: CGFloat
    let lineWidth: CGFloat

    private var color: Color {
        switch score {
        case 0.7...: return TLCColors.success
        case 0.5..<0.7: return TLCColors.warning
        default: return TLCColors.danger
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: score)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.8), value: score)
            Text("\(Int(score * 100))%")
                .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Safe Array Subscript
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
